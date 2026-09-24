# if pointed to a directory with many logs from STAR run, will aggregate important results into a CSV file

import os
import argparse
import 

parser = argparse.ArgumentParser(description='aggregates logs from STAR run')
parser.add_argument('directory', help='directory containing logs (can be containing subdirectories)')
parser.add_argument('--exclude', nargs='+', action='extend', help='directories not to parse')
args = parser.parse_args()

directory_path = args.directory
exclude_paths = args.exclude

def find_files(directory, search, exclude):

	# keep a list of the files that meet search criteria
	found_files = []

	# recursively walk through each subdirectory
	for current, dirs, files in os.walk(directory):
		exclusion_flag = False
		# if the current directory has an excluded directory, mark it for exclusion
		if exclude:
			for path in exclude:
				# if path not in current: print(current, dirs, files)
				if path in current: exclusion_flag = True
		# else: print(current, dirs, files)

		# if current directory is marked for exclusion, go to next cycle
		if exclusion_flag == True: continue
		
		# add any found files to the overall list
		for file in files:
			if search not in file: continue
			found_file = os.path.join(current, file)
			found_files.append(found_file)

	return found_files

print(find_files(directory_path, 'Log.final.out', exclude_paths))