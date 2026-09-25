#!/usr/bin/env python3

# aggregate STAR mapping results from a directory into one file

import sys
import argparse
import helpers

# handle arguments and variables
parser = argparse.ArgumentParser(description='aggregates logs from STAR run')
parser.add_argument('directory', help='directory to search (can contain subdirectories)')
parser.add_argument('--search', help='string used to search for files (if none specified all files will be listed)')
parser.add_argument('--exclude', nargs='+', action='extend', help='directories not to parse')
args = parser.parse_args()

directory_path = args.directory
search_string = args.search
exclude_paths = args.exclude

# set the default name of log files if search not specified
if not search_string: search_string = 'Log.final.out'

STARSTATS = {}
STARSTATS['Samples'] = []

for file in helpers.find_files(directory_path, search_string, exclude_paths):
	
	# get the name of this sample, either by folder or file name
	sample = (f'{file.parent.name}/{file.name}')
	# remove the search string and any surrounding slashes
	sample = sample.strip(search_string)
	sample = sample.strip('/')

	# add this sample to a list in STARSTATS dictionary
	if sample in STARSTATS['Samples']: sys.exit('error: identical sample name detected, perhaps try renaming folders or using --exclude')
	STARSTATS['Samples'].append(sample)

	with open(file, 'rt') as fp:
		for line in fp:
			
			# clean up the line by removing whitespace and splitting it into list
			line = line.rstrip()
			items = line.split('\t')

			# go to next line if less than 2 items, which indicate descriptive lines
			if len(items) < 2: continue

			# clean up the stat item and assign variables
			stat = items[0].lstrip().rstrip(' |')
			value = items[1]

			# make a list for each stat, then append this value to it
			if stat not in STARSTATS: STARSTATS[stat] = []
			STARSTATS[stat].append(value)

# print the header line composed of all keys
for key in STARSTATS.keys(): print(key, end='\t')
print()

# iterate over the number of samples in the dict
for sample in range(0, len(STARSTATS['Samples'])):

	# print the value for each stat that corresponds to the index of this sample
	for value in STARSTATS.values(): 
		print(value[sample], end='\t')
	print()
