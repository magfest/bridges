#!/bin/bash
#
# Hopefully this works.
#
url='https://github.com/magfest/bridges.git'
checkout='prod'
directory='/opt/ansible'
logfile='/var/log/ansible-pull-update.log'

mkdir ${directory}

ansible-pull -o -C ${checkout} -d ${directory} -i localhost -U ${url} 2>&1 | tee -a ${logfile}
