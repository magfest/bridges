# zabbix-mass-create-hosts

Mass creates hosts based on `dns.yaml` entries.

You specify:
* Zabbix credentials
* A prefix (e.g. "c8p") to match hosts from the DNS file against
* A Zabbix host group
* Zabbix template ID(s)

## Installation
```
pip install pyzabbix pyyaml
```

## Usage
Try `python main.py -h` for full usage.

Example usage: `python main.py -u Admin -p xxx -g "Event Switches" -t "MAG - Event Switch" -y path/to/dns.yaml -m c8p --dry-run`

The script will not touch already existing hosts by default, specify `--recreate` to delete and recreate them with the specified parameters.
(Probably a good idea to test with `--dry-run` first.)

## Disclaimer
I don't usually write Python, feel free to fix/improve stuff
