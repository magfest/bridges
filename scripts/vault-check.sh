#!/bin/bash
if ( cat ansible/inventory/group_vars/all/vault.yaml | grep -q "\$ANSIBLE_VAULT;" ); then
      exit 0
else
ansible-vault encrypt --vault-password-file .vault-password ansible/inventory/group_vars/all/vault.yaml
exit 0
fi
