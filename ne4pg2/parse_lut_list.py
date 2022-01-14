#!/usr/bin/env python3
import re
inputfile = 'LUT_LUH2_HIST_LUH1f_list.txt'
outputfile = 'LUT_LUH2_HIST_LUH1f_list_parsed.txt'
inputdata_root = '/sems-data-store/ACME/inputdata'

# Open input and output files and read and write lines one by one
with open(outputfile, 'w') as f_out:
    with open(inputfile) as f_in:
        for line_in in f_in.readlines():
            # Get existing path and year
            path_in  = line_in.split()[0]
            year     = line_in.split()[1]

            # Replace existing inputdata root with location on our machine (specified above)
            path_out = re.sub('.*\/inputdata', inputdata_root, path_in)
            
            # The land surface data tool expects the year to start at exactly column 197
            line_out = f'{path_out.ljust(195)} {year}\n'
            f_out.write(line_out)
