#!/bin/bash

#Change the containers name to whatever is desired
#This assumes you have stopped the original container and backed up your data before running. COuld add her but probably better to do by hand.
docker pull freeipa/freeipa-server:centos-8
docker rm freeipa-new

docker run -e DEBUG_NO_EXIT=1 --restart=always --dns 10.99.99.6  -p 10.99.99.20:80:80 -p 10.99.99.20:443:443 -p 10.99.99.20:389:389 -p 10.99.99.20:636:636 -p 10.99.99.20:88:88 -p 10.99.99.20:464:464 -p 10.99.99.20:88:88/udp -p 10.99.99.20:464:464/udp -p 10.99.99.20:123:123/udp --name freeipa-new -dti -h ipa.example.test --read-only  -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /ipadata:/data:Z --sysctl net.ipv6.conf.all.disable_ipv6=0 freeipa/freeipa-server:centos-8 
