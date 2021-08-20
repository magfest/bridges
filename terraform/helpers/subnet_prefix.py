#!/usr/bin/env python3
# Outputs string with correct subnet prefix based on
# the current git branch.
# ATS
import subprocess
import re
import sys

results = subprocess.run(
    ["git", "branch", "--show-current"],
    stdout=subprocess.PIPE,
    text=True)

if results.returncode:
    print("Git branch command returned non-0 exit code", file=sys.stderr)
    exit(1)

branch = str(results.stdout.strip())
if bool(re.search(r"\s", branch)):
    print("No whitespace in branch names! Bad!", file=sys.stderr)
    exit(1)

root_directory = str(subprocess.run(
    ["git", "rev-parse", "--show-toplevel"],
    stdout=subprocess.PIPE,
    text=True).stdout.strip())

mapping_file = f"{root_directory}/subnet_prefixes.txt"
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
