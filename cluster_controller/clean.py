"""
Cleans project directory
"""

import shutil
import json
import sys
with open(sys.argv[1],'r') as f:
   config =  json.load(f)
PROJECT_DIR = config['PROJECT_DIR']
shutil.rmtree(PROJECT_DIR)