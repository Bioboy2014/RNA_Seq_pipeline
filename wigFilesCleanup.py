!# /usr/bin/env python

import os
import subprocess

filelist = [ f for f in os.listdir(".") if not f.endswith(".gz") ]
for f in filelist:
    os.remove(f)

subprocess.call('gunzip *', shell=True)
subprocess.call('rename "_mode_3_standard" "" *',  shell=True)

for file in os.listdir('.'):
    with open(file, 'r') as openFile:
        # read a list of lines into data
        data = openFile.readlines()
        data[2] = data[2].replace("_duplicates_standard_len_mode_3", "")
        data[2] = data[2].replace("_FL:mode_3_dupe_rds_inc", "")
        if file.find('negative') != -1:
            data[2] = data[2].replace("50,50,150", "200,100,0")
        if file.find('positive') != -1:
            data[2] = data[2].replace("50,50,150", "0,100,200")
        
    with open(file, 'w') as openFile:
        openFile.writelines( data )

subprocess.call('gzip *', shell=True)
