import sys
import glob
import os
import json
import csv
import collections

dir = sys.argv[1]

files =  [(root, files) for root, subdirs, files in os.walk(dir) if files and not subdirs]

for i in range(len(files)):
  dir, filename = files[i]
  assert(len(filename) == 1)
  filename = filename[0]
  path = os.path.join(dir, filename)
  category = dir.split('/')[-2]
  files[i] = (category, path)

m = {}
headers = collections.OrderedDict()

for category, path in files:
  with open(path, 'r') as f:
    js = json.load(f)
    m[category] = {'category':  category}
    m[category].update(js['threads'][0]['regions'][0]['run_nfs'])
    headers.update(map(lambda x: (x, None), m[category].keys()))

with open(os.path.join(sys.argv[1], 'out.csv'), 'w') as f:
    writer = csv.DictWriter(f, headers.keys())
    writer.writeheader()
    for row in m.values():
      writer.writerow(row)



