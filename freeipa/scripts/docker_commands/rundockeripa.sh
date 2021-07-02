#!/bin/bash

echo -n "Password for Admin and DS user:"
read -s password
docker run --restart=always --dns DNS  -p IP:80:80 -p IP:443:443 -p IP:389:389 -p IP:636:636 -p IP:88:88 -p IP:464:464 -p IP:88:88/udp -p IP:464:464/udp -p IP:123:123/udp --name IPANAME -ti -h ipa.domain.com --read-only  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /ipadata:/data:Z --sysctl net.ipv6.conf.all.disable_ipv6=0 freeipa/freeipa-server:centos-8 -U --no-ntp -r DOMAIN.COM -n domain.com --ds-password=$password --admin-password=$password
#replace the keywords with real info. Can take password as input. DO NOT USE SPECIAL CHARACTERS- FreeIPA DS does not like it.
