#!/usr/bin/env python3

# calculate the average mapping time in a given STAR log file

from datetime import datetime
import argparse

parser = argparse.ArgumentParser(description='simple script to calculate average mapping time in a concatenated file of STAR output logs')
parser.add_argument('input', help='input log file to search for times')
args = parser.parse_args()

file = args.input

# specify format of times
fmt = '%Y %b %d %H:%M:%S'
current_year = datetime.now().year

times = []
start = end = None
# load in the specified file
with open(file, 'rt') as fp:
	for line in fp:
		line = line.rstrip()

		# get the start and end time and add current year
		if 'Started mapping on' in line:
			line = line.split('\t')
			start = line[1]
			start = f'{current_year} {start}'
		if 'Finished on' in line:
			line = line.split('\t')
			end = line[1]
			end = f'{current_year} {end}'

		# when start and end time found, format and subtract the times
		if start and end:
			t1 = datetime.strptime(start, fmt)
			t2 = datetime.strptime(end, fmt)
			time = t2 - t1

			# append this time in seconds to times list
			times.append(time.seconds)
			start = end = None

#  print out each individual time in minutes
for time in times: print(time / 60)

# calculate average in different formats
"""sum = 0
for time in times: sum += time
mean_s = sum / len(times)
mean_m = mean_s / 60
mean_h = mean_m / 60

print(f'seconds: {mean_s:.3f}')
print(f'minutes: {mean_m:.3f}')
print(f'hours:   {mean_h:.3f}')"""