import argparse
from pyzabbix import ZabbixAPI
import sys
import urllib3
import yaml

parser = argparse.ArgumentParser()
group = parser.add_argument_group('Zabbix API')
group.add_argument('-s', '--server', default='https://zabbix.magevent.net/zabbix', help='Zabbix web interface URL')
group.add_argument('-u', '--username', required=True, help='Zabbix username')
group.add_argument('-p', '--password', required=True, help='Zabbix password')
group.add_argument('--verify', action=argparse.BooleanOptionalAction, default=False, help='Verify SSL certificate')
group = parser.add_argument_group('Zabbix parameters')
group.add_argument('-g', '--host-group', required=True, help='Name of Zabbix host group to add hosts to')
group.add_argument('-t', '--template', action='append', help='Name of Zabbix templates to link to hosts (can be specified multiple times)')
group.add_argument('-r', '--recreate', action=argparse.BooleanOptionalAction, default=False, help='Delete and re-create hosts that already exist')
group = parser.add_argument_group('Inputs')
group.add_argument('-y', '--yaml', required=True, help='dns.yaml file name') # TODO: Make this accept URLs for convenience
group.add_argument('-m', '--match-prefix', required=True, help='Host name prefix to match against DNS file')
group.add_argument('-d', '--dry-run', action=argparse.BooleanOptionalAction, default=False, help='Dry run (do not create or update hosts)')
args = parser.parse_args()

#
# Read hosts from YAML
#

with open(args.yaml, "r") as stream:
    dns_yaml = yaml.safe_load(stream)

if dns_yaml is None or dns_yaml['magevent_net_hosts'] is None:
    print("YAML file does not seem to be valid")
    sys.exit()

dns_entries = list(filter(lambda entry: entry['name'].startswith(args.match_prefix) and entry['type'] == 'A', dns_yaml['magevent_net_hosts']))
if len(dns_entries) == 0:
    print("No hosts matched")
    sys.exit()

#
# Connect to Zabbix and gather IDs
#

zapi = ZabbixAPI(server=args.server, detect_version=False)
if not args.verify:
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    zapi.session.verify = False
zapi.login(args.username, args.password)
print("Connected to Zabbix API version %s" % zapi.api_version())

host_groups = zapi.hostgroup.get(output="groupid", filter={"name": args.host_group})
if len(host_groups) != 1:
    print("Host group not found or ambiguous")
    sys.exit()
print("Using host group ID %s" % host_groups[0]['groupid'])

template_ids = []
if not args.template is None:
    for template_name in args.template:
        templates = zapi.template.get(output="templateid", filter={"name": template_name})
        if len(templates) != 1:
            print("Template %s not found or ambiguous" % template_name)
            sys.exit()
        template_ids.append(templates[0])
    print("Using template IDs %s" % ','.join(map(lambda t: t['templateid'], template_ids)))

#
# Iterate DNS entries
#
for entry in dns_entries:
    print("---")
    print("Processing host %s" % entry['name'])

    existing_hosts = zapi.host.get(output="hostid", filter={"name": entry['name']})
    if len(existing_hosts) != 0:
        if args.recreate:
            if args.dry_run:
                print (" Host already exists, deleting (skipped, dry-run)")
            else:
                print(" Host already exists, deleting...")
                zapi.host.delete(existing_hosts[0]['hostid'])
        else:
            print(" Host already exists, skipping")
            continue

    if args.dry_run:
        print(" Creating host (skipped, dry-run)")
    else:
        print(" Creating host...")
        result = zapi.host.create(
            host=entry['name'],
            groups=host_groups,
            templates=template_ids,
            interfaces=[{
                "main": 1,
                "type": 2, #SNMP
                "ip": entry['ip'],
                "dns": "",
                "useip": 1,
                "port": 161,
                "details": {"version": 2, "community": '{$SNMP_COMMUNITY}'}
            }]
        )
        print (" ...done, host ID: %s" % result['hostids'][0])
