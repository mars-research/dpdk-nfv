import sys
import csv
import itertools

with open(sys.argv[1]) as f:
  content = f.readlines()

latency = {}
throughput = {}
m = {
  'latency': {},
  'throughput': {},
}

for line in content:
  ty, col, row, val = tuple(map(str.strip, line.strip().split(',')))
  row = int(row)
  val = int(val)
  ty_m = m[ty]
  if row not in ty_m:
    ty_m[row] = {}
  ty_m[row][col] = f'{val/1E6 : .2f}' if ty == 'throughput' else val

col_headers = {}
for ty in m:
  ty_m = m[ty]
  row_header = ty_m.keys()
  col_headers[ty] = ['batch_size'] + list(set(itertools.chain.from_iterable(map(dict.keys, ty_m.values()))))
  for r in row_header:
    ty_m[r]['batch_size'] = r

with open(sys.argv[1] + '.csv', 'w') as f:
  for ty in m:
    writer = csv.DictWriter(f, col_headers[ty])
    writer.writeheader()
    for row in m[ty].values():
      writer.writerow(row)
    f.write('\n')

