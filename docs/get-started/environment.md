# ENVIRONMENT

## HOW DOES BRIDGES KNOW WHAT SUBNET TO DEPLOY ON?
So there's a file at https://github.com/magfest/bridges/blob/main/subnet_prefixes.txt that has the following content:

```
prod: 10.101.22.0/24
main: 10.101.23.0/24
dev: 10.101.24.0/24
aaron-dev: 10.101.25.0/24
default: 10.101.26.0/24
```

That file contains, as you can see, a branch name and a subnet.  This lets us associate a branch name with a subnet and have a bunch of scripts use that data for ~~nefarious purposes~~ telling the rest of BRIDGES what to do.

Example from our GitLab pipeline confiig at https://github.com/magfest/bridges/blob/main/.gitlab-ci.yml:

```
before_script:
  - cd ${TF_ROOT}
  - export TF_VAR_subnet="$(python3 helpers/subnet_prefix.py)"
  - export TF_VAR_subnet_list="$(python3 helpers/subnet_list.py)"
```

Those scripts populate environment variables with the current branch's subnet and a list of all the branch subnet data.

Then stuff that needs that data can refer to `$TF_VAR_subnet` and `$TF_VAR_subnet_list` (Terraform makes those `$subnet` and `$subnet_list` automagically).

Things that use that data:

- Terraform, for guest creation and deployment
- Ansible, for DNS and other server configuration (This lets us create DNS subdomains and delegating to them automagically)
