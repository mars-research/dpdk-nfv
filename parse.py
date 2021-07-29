#!/usr/bin/python3
import sys
import csv
import itertools

with open(sys.argv[1]) as f:
  content = f.readlines()

m = {}

for line in content:
  col, row, val = tuple(map(str.rstrip, line.rstrip().split(',')))
  row = int(row)
  if row not in m:
    m[row] = {}
  m[row][col] = val

row_header = m.keys()
col_header = ['batch_size'] + list(set(itertools.chain.from_iterable(map(dict.keys, m.values()))))
for r in row_header:
  m[r]['batch_size'] = r
with open(sys.argv[1] + '.csv', 'w') as f:
  writer = csv.DictWriter(f, col_header)
  writer.writeheader()
  for row in m.values():
    writer.writerow(row)
