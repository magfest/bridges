# DNS

DNS is configured by ansible.

The file for DNS records can be found at:

`ansible/inventory/group_vars/all/dns.yaml`

## HOW DO I ADD/REMOVE/EDIT A DNS ENTRY?

TL;DR: edit https://github.com/magfest/bridges/blob/main/ansible/inventory/group_vars/all/dns.yaml

Or use this! https://github.dev/magfest/bridges/blob/main/ansible/inventory/group_vars/all/dns.yaml

There's a big variable in that file named `magevent_net_hosts`.  This variable is a list of Ansible dicts, where each dict contains relevant data for one DNS entry.

Dynamic ones look like this:
```
  - { name: "dhcp1", ip: "{{ branch_subnet_trimmed }}.4", type: "A" }
```

That `branch_subnet_trimmed` variable takes the subnet data previously mentioned and trims it down to the first 3 octets of the subnet, something like `10.101.22`, so we end up with (using the above example) `10.101.22.4`.

Static ones are even easier:
```
  - { name: "freeipa", ip: "10.101.22.11", type: "A" }
```

The DNS servers being modified are the internal servers that run on the event rack.  This code does not (yet) edit the external zone hosted on Amazon.

You can add external entries if you need them though:
```
  - { name: "food", ip: "157.245.3.204", type: "A" }
```
