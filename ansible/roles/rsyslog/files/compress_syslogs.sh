#!/bin/bash

# compress syslogs older than 2 days
/bin/nice find /syslogs/ -type f -mtime +2 ! -name \*.gz -size +1 -exec gzip -v -f -9 {} \;
