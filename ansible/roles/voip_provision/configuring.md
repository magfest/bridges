# Phone Configuration Notes

Note: Our phone models do not use `.boot` files for configuration, this is only available
for newer phone modelswith firmware X.83.x+. This means no `static.xxx` parameters.

Phone feature matrix

Model Name      PoE?    Screen      Firmware    Config File
---------------+-------+-----------+-----------+----------------
Yealink T20     No      2-line B&W  9.73.193.40 y000000000007.cfg
Yealink T20P    Yes     2-line B&W  9.73.193.40 y000000000007.cfg
Yealink T22P    Yes     Full B&W    7.73.193.50 y000000000005.cfg
Yealink T26P    Yes     Full B&W    6.73.193.50 y000000000004.cfg
Yealink T28P    Yes     Full B&W    2.73.193.50 y000000000000.cfg
Yealink T38G    Yes     Full Color  38.70.1.33

# Provisioning Templates
There are several sets of template files that control phone and asterisk configuration.

## Phone Templates
The generic model templates are generated through ansible templating, using the settings from `phones.yaml`,
which configures the template to be used ("type"), the result filename ("filename"), and the type-specific
firmware file to be downloaded for that model. Then, the phone is directed to get its MAC-specific config from
the provisioner server, which should run alongside the asterisk server.

The MAC-specific phone configuration templates are served from the provisioner server,
using data gathered from airtable, automatically. The data passed to the templates will match this format:

 - `credentials`: The credentials for this phone
 - `credentials.username`: An automatically-generated SIP username for this phone to use
 - `credentials.password`: An automatically-generated SIP password for this phone to use
 - `credentials.desc`: A display name for the phone. Uses first non-empty field in order of `Caller ID`, `Name`, and `Extension`
 - `extensions`: The list of all extensions currently configured and not hidden from the phonebook, sorted by sort order then name
 - `extensions.extension`: The dial number for this extension, as a string
 - `extensions.label`: A display name for this extension. Uses the same strategy as for `credentials.desc`.
 - `extensions.active`: Whether or not this extension has any phones assigned to it
 - `extensions.sort_order`: A manually-set sort order for this extension, used to order groups of extensions in the phone book. If not specified, this will always be 1000. Also, the return value is sorted already.
 - `extensions.incoming_number`: Optional. If present, the external phone number used to directly dial into this extension.
 - `extensions.long_description`: Optional. If present, a long description of this extension for use in phone directories.

    {
        "credentials": [
            {
                "username": "generated-sip-username",
                "password": "generated-sip-password",
                "desc": "Extension caller ID, name, or number"
            }
        ],
        "extensions": [
            {
                "extension": "100",
                "label": "Extension caller ID, name, or number",
                "active": true,
                "sort_order": 1000,
                "incoming_number": "18005551100",
                "long_description": "An optional long description intended for use in phone directories"
            }
        ]
    }

##
Settings we want to set

## maybe only for boot files ^^ ?
Specific to each firmware
firmware.url =
