#!/bin/bash
#
# Hopefully this works.
#
if [ "$1" == "--force" ]; then
    FORCE="-o"
else
    FORCE=""
fi

function change_branch_to_main {
  checkout="main"
  cd /opt/ansible/repo
  git checkout main
  git pull
  echo "main" > ${directory}/branch
  SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
  echo "Changing branch back to main - rerunning ${SCRIPTPATH}"
  bash ${SCRIPTPATH}
  exit
}

url='https://github.com/magfest/bridges.git'
directory='/opt/ansible'
FILE=/opt/laptops/repo/ansible/playbook.yaml
if [[ -f "$FILE" ]]; then
    echo "$FILE exists ... comfiguring from laptop repo"
    directory='/opt/laptops'
else

checkout="$(cat ${directory}/branch)"

if [ "$checkout" == "prod" ]; then
  change_branch_to_main
fi

if [ "$checkout" == "" ]; then
    change_branch_to_main
fi

while ! ping -c1 google.com; do sleep 3; done

ansible-galaxy install -r ${directory}/requirements.yaml
ansible-galaxy collection install -r ${directory}/requirements.yaml
ansible-pull ${FORCE} -C ${checkout} -d ${directory}/repo -i localhost, -U ${url} --tags "laptops" --vault-password-file ${directory}/vault-password ansible/playbook.yaml 2>&1 | tee -a ${logfile}
