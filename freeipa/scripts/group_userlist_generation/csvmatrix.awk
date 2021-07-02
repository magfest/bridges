#!/usr/bin/awk -f
#Awk Script to generate a more useable output from a maxtix style CSV
#heathers 4/23/21

#Example:

#Input CSV with format
#NULL,cat1,cat2
#item1,x,,
#item2,x,x

#output
#cat1|item1
#cat2|item1
#cat2|item2

#Grabs the first header line to it's own array
{
    if(NR==1)
        split($0,header,",")
    else
    {
	#splits the next line (eg itemx,x,x,... into an array
	#if the line array has an x in the same position as the header array, output the header name and the user name where x was found
        split($0,line,",")
        for (i in line)  
        {
		if (line[i] == "x")
			print header[i] "|" line[1] 
			
        }
    }
}
