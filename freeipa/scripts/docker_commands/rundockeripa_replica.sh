#!/bin/bash

echo -n "Password for Admin and DS user:"
read -s password

docker run --restart=always --dns DNS  -p IP:80:80 -p IP:443:443 -p IP:389:389 -p IP:636:636 -p IP:88:88 -p IP:464:464 -p IP:88:88/udp -p IP:464:464/udp -p IP:123:123/udp --name IPANAME_replica -ti -h ipa2.domain.com --read-only  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /ipadata:/data:Z --sysctl net.ipv6.conf.all.disable_ipv6=0 freeipa/freeipa-server:centos-8 ipa-replica-install --setup-ca --principal admin --admin-password $password --server ipa.domain.com --domain domain.com
# Only run this once you have a server running! the --server there should point to the original server
