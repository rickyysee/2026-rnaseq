#!/usr/bin/env python3

# aggregate STAR mapping results from a directory into one file

import os
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

for file in helpers.find_files(directory_path, search_string, exclude_paths): print(file)