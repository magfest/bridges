#!/usr/bin/env python3
# Outputs list of all branches with subnets.
# Hacked together by Adam Dorsey (yesrod)
# Based on subnet_prefix.py by Aaron Saderholm (sader)
import os
import sys
import json

mapping_file = f"{os.getenv('CI_PROJECT_DIR')}/subnet_prefixes.txt"

subnets = {}
with open(mapping_file) as myfile:
    for line in myfile:
        name, var = line.partition(":")[::2]
        subnets[name.strip()] = str(var).strip()

print(json.dumps(subnets))
