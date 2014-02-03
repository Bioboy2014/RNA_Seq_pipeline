import os
import subprocess

for dir in os.listdir('.'):
    os.chdir(dir)
    subprocess.call('rename "accepted_hits" "' + dir + '" *', shell=True) 
    os.chdir("..")

