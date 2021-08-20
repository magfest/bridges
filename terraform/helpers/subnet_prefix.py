#!/usr/bin/env python3
# Outputs string with correct subnet prefix based on
# the current git branch.
# ATS
import os
import sys

branch = os.getenv("CI_COMMIT_BRANCH")
mapping_file = f"{os.getenv('CI_PROJECT_DIR')}/subnet_prefixes.txt"

subnets = {}
with open(mapping_file) as myfile:
    for line in myfile:
        name, var = line.partition(":")[::2]
        subnets[name.strip()] = str(var).strip()

if branch in subnets:
    print(subnets[branch])
    exit(0)
else:
    print(f"Could not find branch {branch} in {mapping_file}", file=sys.stderr)
    exit(1)
