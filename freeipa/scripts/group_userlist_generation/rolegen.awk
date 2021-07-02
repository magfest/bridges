#!/usr/bin/awk -f
{
    if(NR==1)
        split($0,header,",")
    else
    {
        split($0,line,",")
        for (i in line)  
        {
		if (line[i] == "x")
			print header[i] "|" line[1] 
			
        }
    }
}
