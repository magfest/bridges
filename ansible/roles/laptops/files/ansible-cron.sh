#!/bin/bash
#
# Hopefully this works.
#
url='https://github.com/magfest/bridges.git'
checkout='prod'
directory='/opt/ansible'
logfile='/var/log/ansible-pull-update.log'

mkdir ${directory}

sudo ansible-pull -o -C ${checkout} -d ${directory} -i localhost -U ${url} 2>&1 | sudo tee -a ${logfile}
