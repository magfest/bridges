#!/usr/bin/env python3
import os
import sys
import time
import json
import flask
import jinja2
import random
import string
import logging
import os.path
import requests
import functools
import threading
from airtable import airtable
from flask import request
from collections import namedtuple

# Big TODOs:
# - Use model classes for the airtable stuff instead of json/dicts
# - Document minimum required airtable schema
# - Use something better for config defaults / the config in general
# - Requirements / packaging

log = logging.getLogger("voip-provision")

TEMPLATE_DEFAULTS = {
    "yealink.cfg": {
        "type": "phone_mac_config",
        "src_path": "yealink.cfg.j2",
        "phone_types": ["Yealink T20", "Yealink T20P", "Yealink T22P", "Yealink T26P", "Yealink T28P", "Yealink T38G"],
        "http_path": "/yealink-t2x/<mac>.cfg"
    },
    "asterisk.extensions.phones": {
        "type": "full_config",
        "src_path": "ast_extensions_phones.jinja",
        "write_path": "/etc/asterisk/extensions_phones.conf"
    },
    "asterisk.extensions.incoming": {
        "type": "full_config",
        "src_path": "ast_extensions_incoming.jinja",
        "write_path": "/etc/asterisk/extensions_incoming.conf"
    },
    "asterisk.extensions.outgoing": {
        "type": "full_config",
        "src_path": "ast_extensions_outgoing.jinja",
        "write_path": "/etc/asterisk/extensions_outgoing.conf"
    },
    "asterisk.sip": {
        "type": "full_config",
        "src_path": "ast_sip.jinja",
        "write_path": "/etc/asterisk/include_users.conf"
    },
    "asterisk.queues": {
        "type": "full_config",
        "src_path": "ast_queues.jinja",
        "write_path": "/etc/asterisk/include_queues.conf"
    }
}

CONFIG_DEFAULTS = {
    "airtable": { "base_id": None, "api_key": None},
    "asterisk": {
        "reload_command": "systemctl reload asterisk",
        "reload_url": None
    },
    "templates": TEMPLATE_DEFAULTS,
    "user_data": "/var/voip-provision/users.json",
    "airtable_cache": "/var/voip-provision/cache.json",
    "template_dir": "/etc/voip-provision/templates",
    "firmware_dir": "/etc/voip-provision/firmware",
    "http": {
        "enable": False,
        "debug": False,
        "listen": "127.0.0.1",
        "port": 8080
    },
    "update_interval": 60,
    "logging": {
        "console_level": "info",
        "file_level": "debug",
        "file_path": "/var/log/voip-provision.log",
        "syslog_level": "debug",
        "syslog_path": None
    }
}

class TtlCache:
    def __init__(self, timeout):
        self.__timeout = timeout
        self.__cache = None
        self.__updated = 0

    def evict(self):
        self.__updated = 0

    def __call__(self, fn):
        @functools.wraps(fn)
        def _cachefunc(*args, **kwargs):
            if time.time() - self.__timeout >= self.__updated:
                log.debug("cache expired, calling %s to renew", fn)
                self.__cache = fn(*args, **kwargs)
                self.__updated = time.time()
            return self.__cache
        return _cachefunc

class VoipProvisioner:
    def __init__(self, config):
        self.config = config
        self.jinja = jinja2.Environment(
            loader=jinja2.FileSystemLoader(config.get("template_dir", CONFIG_DEFAULTS["template_dir"]))
        )

        self.jinja.globals.update(JINJA_GLOBALS)
        self.__running = False
        self.__thread = None

    def get_user_data_file(self):
        return self.config.get("user_data", CONFIG_DEFAULTS["user_data"])

    def get_user_data(self):
        try:
            with open(self.get_user_data_file()) as f:
                return json.load(f)
        except IOError:
            log.warning("No user data file found, returning empty set (expected on first run)")
            return {}

    def save_user_data(self, user_data):
        with open(self.get_user_data_file(), 'w') as f:
            json.dump(user_data, f)

    @TtlCache(10)
    def get_airtable(self):
        #raise ValueError()
        log.info("Fetching records from airtable")
        base_id = self.config.get("airtable", {}).get("base_id")
        api_key = self.config.get("airtable", {}).get("api_key")

        if base_id is None:
            log.error("Config field 'airtable.base_id' is not set!")
        if api_key is None:
            log.error("Config field 'airtable.api_key' is not set!")

        if not base_id or not api_key:
            raise ValueError("Invalid airtable configuration")

        at = airtable.Airtable(base_id, api_key)

        phones = list(at.iterate("Phones"))
        extensions = list(at.iterate("Phone Extensions"))
        rooms = list(at.iterate("Rooms"))
        departments = list(at.iterate("Departments"))

        log.info("Loaded %d phones, %d extensions, %d rooms, and %d departments from airtable", len(phones), len(extensions), len(rooms), len(departments))

        all_data = {"phones": phones, "extensions": extensions, "rooms": rooms, "departments": departments}
        self.save_cached_extensions(all_data)
        return all_data

    def resolve_record(self, record_id):
        for record_list in self.get_airtable().values():
            for record in record_list:
                if record.get("id") == record_id:
                    return record
        return None

    def get_airtable_cache_file(self):
        return self.config.get("airtable_cache", CONFIG_DEFAULTS["airtable_cache"])

    def get_cached_extensions(self):
        with open(self.get_airtable_cache_file()) as f:
            return json.load(f)

    def save_cached_extensions(self, extensions):
        if extensions:
            log.debug("Cached airtable data to file")
            with open(self.get_airtable_cache_file(), 'w') as f:
                json.dump(extensions, f)
        else:
            log.info("Not caching empty result from airtable")

    def get_extensions(self):
        try:
            return self.get_airtable()
        except Exception as e:
            log.exception("Failed to load data from airtable: %s", e)
            log.warning("Continuing with last cached response")
            return self.get_cached_extensions()

    def find_phone_by_mac(self, mac):
        for phone in self.get_extensions().get("phones"):
            if mac and phone["fields"].get("MAC Address", "").upper() == mac.upper():
                return phone
        log.warning("Could not find phone with mac '%s'. Returning None", mac)
        return None

    def find_extension(self, number):
        """Return info for the extension number given, or None if it does not exist"""
        for ext in self.get_extensions().get("extensions"):
            if ext["fields"].get("Extension") == number:
                return ext
        return None

    def resolved(self, seq):
        for obj_id in seq:
            yield self.resolve_record(obj_id)

    def reload_asterisk(self):
        ast_config = self.config.get("asterisk", CONFIG_DEFAULTS["asterisk"])
        reload_command = ast_config.get("reload_command", CONFIG_DEFAULTS["asterisk"]["reload_command"])
        reload_url = ast_config.get("reload_url", CONFIG_DEFAULTS["asterisk"]["reload_url"])

        if reload_command:
            log.debug("Reloading asterisk using command: %s", reload_command)
            os.system(reload_command)

        if reload_url:
            log.debug("Reloading asterisk by POSTing URL: %s", reload_url)
            requests.post(reload_url)

    def start(self):
        if not self.__running and not self.__thread:
            log.debug("Starting run thread...")
            self.__running = True
            self.__thread = threading.Thread(target=self.run, name="voip-provision-updater", daemon=False)
            self.__thread.start()
        else:
            log.debug("Not starting run thread: already started!")

    def stop(self):
        self.__running = False
        self.__thread.join()
        self.__thread = None

    def run(self):
        """Run the main loop for the updater. Continuously checks airtable every {config.update_interval}
        seconds and, if there have been any changes, updates all config files.
        """

        interval = self.config.get("update_interval", CONFIG_DEFAULTS["update_interval"])
        next_update = 0
        last_update = None
        while self.__running:
            try:
                new_data = self.get_extensions()

                if new_data != last_update:
                    log.info("Airtable change detected, re-syncing templates")
                    self.resync()
                    last_update = new_data
                else:
                    log.debug("No changes detected. Sleeping for %d seconds...", interval)
            except KeyboardInterrupt:
                log.info("Shutting down updater due to keyboard interrupt...")
                self.__running = False
            except Exception as e:
                log.exception("Exception encountered while running updater: %s", e)

            next_update = time.time() + interval

            while self.__running and time.time() < next_update:
                time.sleep(1)

        log.info("Stopping updater thread")

    def resync(self):
        """Re-write any generated files after data has changed, and tell Asterisk to reload"""
        log.info("Re-syncing files")

        for name, template_info in dict(self.config.get("templates", CONFIG_DEFAULTS["templates"])).items():
            # bring in the defaults in a weird way here
            template_info.update({k: v for k, v in CONFIG_DEFAULTS["templates"].get(name, {}).items() if k not in template_info})
            if template_info.get("write_path"):
                # this is a template that expects to be written to a file
                if template_info["type"] == "phone_mac_config":
                    for phone in self.get_extensions().get("phones", []):
                        if phone.get("MAC Address"):
                            with open(template_info["write_path"].format(mac=phone.get("MAC Address")), "w") as f:
                                log.debug("Writing template %s to file %s", name, f.name)
                                self.render_phone_mac_config(
                                    mac=phone["MAC Address"],
                                    template_name=template_info["src_path"],
                                    stream=True
                                ).dump(f, encoding=template_info.get("encoding"))
                elif template_info["type"] == "phone_generic_config":
                    with open(template_info["write_path"], "w") as f:
                        log.debug("Writing template %s to file %s", name, f.name)
                        self.render_phone_generic_config(
                            template_name=template_info["src_path"],
                            stream=True
                        ).dump(f, encoding=template_info.get("encoding"))
                elif template_info["type"] == "full_config" or template_info["type"] == "page":
                    with open(template_info["write_path"], "w") as f:
                        log.debug("Writing template %s to file %s", name, f.name)
                        self.render_asterisk_template(
                            template_name=template_info["src_path"],
                            stream=True
                        ).dump(f, encoding=template_info.get("encoding"))

        log.debug("Done re-syncing files")

        self.reload_asterisk()

    def get_credentials(self, phone_mac):
        # find the phone's assigned extension if any
        log.debug("Retrieving credentials for phone with mac %s", phone_mac)
        phone = self.find_phone_by_mac(phone_mac)

        if not phone:
            return None

        phone_exts = list(self.resolved(phone["fields"].get("Assigned Extension", [])))
        if not phone_exts:
            log.warning("Attempt to get credentials for phone with no assignments: %s (MAC %s)", phone["fields"].get("ID"), phone_mac)
            return []

        user_data = self.get_user_data()

        phone_creds = user_data.get(phone_mac, [])

        assigned_extensions = [ext["fields"]["Extension"] for ext in phone_exts]
        found = []
        added = []

        for ext in assigned_extensions:
            # In case the phone has multiple assigned extensions, select the credentials that match this extension
            found_creds = list(filter(lambda cred: cred.get("extension") == ext, phone_creds))
            if len(found_creds):
                found.append(ext)
            else:
                log.info("Generating new credentials for phone: %s (MAC %s) at extension %s", phone["fields"].get("ID"), phone_mac, ext)
                phone_creds.append({"username": gen_username(ext, phone_mac), "password": gen_password(), "extension": ext})
                added.append(ext)

        if added:
            user_data[phone_mac] = phone_creds
            self.save_user_data(user_data)
            self.resync()

        return phone_creds

    def is_extension_active(self, extension):
        # TODO
        return False

    def get_configured_credentials(self):
        """Returns all the credentials and phonebook needed to generate the asterisk SIP config"""
        phonebook = self.get_phonebook(include_hidden=True, sort_by_extension=True)

        # Augment the phonebook with other info
        # Extensions config needs:
        # ring_users: ["username1", "username2"]
        # use_queue: False
        # alt_extensions: ["special-extension-1"]

        def augment_ext(ext):
            raw_ext = self.find_extension(ext["extension"])
            ext["ring_users"] = [
                list(map(lambda cred: cred.get("username"),
                        filter(lambda cred: cred.get("extension") == ext,
                                self.get_credentials(phone["fields"].get("MAC Address")))))
                for phone in self.resolved(raw_ext["fields"].get("Phones", []))
            ]

            ext["use_queue"] = bool(raw_ext["fields"].get("Queue"))
            ext["alt_extensions"] = [alt.strip() for alt in raw_ext.get("Alternate Extensions", "").split(",") if alt.strip()]
            return ext

        def map_credential(mac, cred):
            return {
                "extension": cred["extension"],
                "username": cred["username"],
                "password": cred["password"],
                "mac": mac.upper()
            }

        return {
            "extensions": list(map(augment_ext, phonebook)),
            "credentials": [map_credential(mac, cred) for mac, creds in self.get_user_data().items() for cred in creds],
            "default_extension": next(filter(lambda ext: ext.get("is_default"), phonebook), None)
        }

    def get_phonebook(self, include_hidden=False, active_only=False, sort_by_extension=False):
        """Returns the phone book. Contains no credentials.
        If active_only is True, only phones that have registered will be included.
        If sort_by_extension is True, the list will be ordered by numeric extension.
        Otherwise, the list will be ordered by sort order (default 1000), then by label, which is Caller ID, or if empty: Name, or if empty: Extension
        """

        def map_extension(ext):
            result = {
                "extension": ext["fields"]["Extension"],
                # Prefer caller ID, if that's empty or none use Name, if that's empty or none use Extension
                "label": ext["fields"]["Caller ID"] or ext["fields"]["Name"] or ext["fields"]["Extension"],
                "active": len(ext["fields"].get("Phones", [])) > 0,
                "sort_order": 1000,
                "hidden": not ext["fields"].get("Phonebook", False)
            }

            if ext["fields"].get("Default Outgoing Number"):
                result["is_default"] = True

            if ext["fields"].get("Incoming Number"):
                result["incoming_number"] = ext["fields"]["Incoming Number"]

            if ext["fields"].get("Phonebook Description"):
                result["long_description"] = ext["fields"]["Phonebook Description"]

            if ext["fields"].get("Phonebook Sort Order"):
                try:
                    result["sort_order"] = int(ext["fields"].get("Phonebook Sort Order"))
                except:
                    pass

            return result

        phonebook = map(map_extension, self.get_extensions().get("extensions"))

        if not include_hidden:
            phonebook = filter(lambda entry:not entry.get("hidden", True), phonebook)

        if active_only:
            phonebook = filter(lambda entry:entry.get("active", False), phonebook)

        # Sort so that entries are ordered first by "Phonebook Sort Order" field, with a default of 1000,
        # and then by name, or
        return sorted(phonebook, key=lambda ext: (ext.get("sort_order"), ext.get("label")))

    def render_phone_mac_config(self, mac, template_name=None, stream=False):
        # get the phone's type
        # then find the right template
        if template_name is None:
            log.debug("Searching for correct template for phone with mac %s", mac)
            phone = self.find_phone_by_mac(mac)
            if not phone:
                raise FileNotFoundError("File not found")
            matching_templates = [template for name, template in TEMPLATE_FILES.items() if phone.get("Type") in template.get("phone_types", [])]

            if len(matching_templates) != 1:
                log.error("Expected to find 1 but got %d matching templates for phone type %s", len(matching_templates), phone.get("Type"))
                raise ArgumentError("Cannot find suitable template for phone of type {}".format(phone.get("Type")))

            template_name = next(matching_templates)

        #{ credentials: [{username, password, desc}], extensions: [{extension, label}] }
        template_paremeters = {
            "credentials": provisioner.get_credentials(mac),
            "extensions": provisioner.get_phonebook()
        }

        if stream:
            return self.jinja.get_template(template_name).stream(**template_parameters)
        else:
            return self.jinja.get_template(template_name).render(**template_parameters)

    def render_asterisk_template(self, template_name, stream=False):
        if stream:
            return self.jinja.get_template(template_name).stream(**self.get_configured_credentials())
        else:
            return self.jinja.get_template(template_name).render(**self.get_configured_credentials())

def gen_username(exten, mac):
    return exten + "-" + mac[-6:]

def gen_password(length=16):
    return ''.join([random.choice(string.ascii_letters + string.digits) for _ in range(length)])

def safe_identifier(val):
    return ''.join([char for char in val if char in string.ascii_letters or char in string.digits])

def externalize_callerid(callerid):
    if callerid.startswith("MAGFest"):
        return callerid
    return "MAGFest " + callerid

def format_sip_username(username):
    log.debug("formatting username '%s' into 'SIP/%s'", username, username)
    return "SIP/{username}".format(username=username)

def format_sip_username_list(users):
    log.debug("Formatting %s into a list SIP/blah&SIP/foo...", users)
    return "&".join(list(map(format_sip_username, users)))

def parse_log_level(level):
    return {
        "debug": logging.DEBUG,
        "info": logging.INFO,
        "warn": logging.WARNING,
        "warning": logging.WARNING,
        "error": logging.ERROR,
        "critical": logging.CRITICAL
    }.get(level.lower(), logging.INFO)

JINJA_GLOBALS = {
    "enumerate": enumerate,
    "safe_identifier": safe_identifier,
    "externalize_callerid": externalize_callerid,
    "format_sip_username": format_sip_username,
    "format_sip_username_list": format_sip_username_list
}

def main():
    # Decide on the config path
    # Priority is:
    # 1. The path passed as the first argument to the program, if any
    # 2. The path defined in the env variable VOIP_PROVISION_CONFIG
    # 3. /etc/voip-provision/config.json
    config_path = "/etc/voip-provision/config.json"

    if len(sys.argv) > 1:
        config_path = sys.argv[1]
    elif os.environ.get("VOIP_PROVISION_CONFIG"):
        config_path = os.environ.get("VOIP_PROVISION_CONFIG")

    with open(config_path) as conf:
        config = json.load(conf)

    # Configure logging
    logging_config = config.get("logging", CONFIG_DEFAULTS["logging"])

    # default logger logs everything, handlers do the rest
    log.setLevel(logging.DEBUG)

    formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")

    file_path = logging_config.get("file_path", CONFIG_DEFAULTS["logging"]["file_path"])
    if file_path:
        fh = logging.FileHandler(file_path)
        fh.setLevel(parse_log_level(logging_config.get("file_level", CONFIG_DEFAULTS["logging"]["file_level"])))
        fh.setFormatter(formatter)
        log.addHandler(fh)

    ch = logging.StreamHandler()
    ch.setLevel(parse_log_level(logging_config.get("console_level", CONFIG_DEFAULTS["logging"]["console_level"])))
    ch.setFormatter(formatter)
    log.addHandler(ch)

    syslog_path = logging_config.get("syslog_path", CONFIG_DEFAULTS["logging"]["syslog_path"])
    if syslog_path:
        sh = logging.SysLogHandler(address=syslog_path)
        syslog_formatter = logging.Formatter("%(name)s[%(process)d: %(asctime)s %(levelname)s: %(message)s")
        sh.setFormatter(syslog_formatter)
        log.addHandler(sh)

    # Real stuff here

    provisioner = VoipProvisioner(config)

    # If the update interval is configured, start the provisioner
    if provisioner.config.get("update_interval", CONFIG_DEFAULTS["update_interval"]):
        provisioner.start()

    http_config = provisioner.config.get("http", CONFIG_DEFAULTS["http"])

    # TODO move this inside provisioner?
    if http_config.get("enable", CONFIG_DEFAULTS["http"]["enable"]):
        app = flask.Flask(__name__, template_folder=config.get("template_dir", CONFIG_DEFAULTS["template_dir"]))
        # we want the enumerate function in some templates
        app.jinja_env.globals.update(JINJA_GLOBALS)

        for name, template_info in dict(config.get("templates", CONFIG_DEFAULTS["templates"])).items():
            # bring in the defaults in a weird way here too
            template_info.update({k: v for k, v in CONFIG_DEFAULTS["templates"][name].items() if k not in template_info})
            if template_info.get("http_path"):
                if template_info["type"] == "phone_mac_config":
                    path_prefix = "/provision"
                    def view_func(*args, **kwargs):
                        return provisioner.render_phone_mac_config(*args, **kwargs, template_name=template_info["src_path"], mac=mac)
                elif template_info["type"] == "phone_generic_config":
                    path_prefix = "/provision"
                    def view_func(*args, **kwargs):
                        return provisioner.render_phone_generic_config(*args, **kwargs, template_name=template_info["src_path"])
                elif template_info["type"] == "full_config":
                    path_prefix = "/config"
                    def view_func(*args, **kwargs):
                        return provisioner.render_asterisk_template(*args, **kwargs, template_name=template_info["src_path"])
                elif template_info["type"] == "page":
                    path_prefix = ""
                    def view_func(*args, **kwargs):
                        return provisioner.render_asterisk_template(*args, **kwargs, template_name=template_info["src_path"])
                else:
                    log.warning("Unknown template type %s -- skipping route setup", template_info["type"])
                    continue

                app.add_url_rule(path_prefix + template_info.get("http_path"), view_func=view_func)

        if provisioner.config.get("firmware_dir"):
            def serve_firmware(firmware_path):
                return send_from_directory(provisioner.config.get("firmware_dir", CONFIG_DEFAULTS["firmware_dir"]), firmware_path)
            app.add_url_rule("/firmware/<path:firmware_path>", view_func=serve_firmware)

        try:
            app.run(http_config.get("listen", CONFIG_DEFAULTS["http"]["listen"]), http_config.get("port", CONFIG_DEFAULTS["http"]["port"]), debug=http_config.get("debug", CONFIG_DEFAULTS["http"]["debug"]))
        except KeyboardInterrupt:
            log.critical("Shutting down due to keyboard interrupt")
            provisoner.stop()

if __name__ == "__main__":
    main()
