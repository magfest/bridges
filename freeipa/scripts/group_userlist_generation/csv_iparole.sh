#!/bin/bash
#Matrix CSV processor
#heathers 4/23/21
#MOdified to generate ansible yml for ingestion
#Reads a file with the format

# NULL,cat1,cat2,cat3
# item1,x,,x
# item2,,x,x

#(EG CSV with data in matrix format)
# and prints data  in a format starting with the group name and a list of all users in that group via x marking

#This AWK script outputs all of the groups with members in a format such as
#cat1|item1
#cat2|item2
#cat3|item1
#cat3|item2

awk -f rolegen.awk $1 | sort > awkout
#gets a list of just the groups from the above output
awk -F "|" '{print $1}' awkout | sort | uniq > header
#Reads the group file, then prints each user in the groub below it with a line break
#can be modified from here to do other formatting, or reformatted to work with other scripts

#clean up any old output before starting (if you didn't save the old output this is on you
rm -f output
echo "group_list:" >> output
while read line; do
	echo "  - group: $line" >> output
	echo "    users:" >> output
	while IFS='|' read -r grp usr; do
		if [ $grp == $line ]; then
			echo "      - $usr" >> output
		fi
	done < awkout
	echo "" >> output
done < header

#Cleanup temp files
rm -f awkout header
