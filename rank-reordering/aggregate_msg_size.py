#!/usr/bin/env python
##
# Copyright (C) 2015 University of Virginia. All rights reserved.
#
# @file     aggregate_msg_size.py 
# @author    Fabrice Mizero <fm9ab@virginia.edu>
# @version   1.0
#
# @section   LICENSE
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details at http://www.gnu.org/copyleft/gpl.html
#
# @brief   Aggregate all comms in paraver file. 

import sys

def aggregate_comms(comms):
	agg = 0
	with open(comms,'r') as COMMS:
		for record in COMMS:
			r = record.strip().split(' ')
			agg += sum(map(int, r))	
		return agg

def main():
	comms = sys.argv[1]
	if len(comms) < 2:
		raise RuntimeError("Usage: python *.py comms.csv")
		
	print("Total message size: %d Bytes" % aggregate_comms(comms))

if __name__ == "__main__":
	sys.exit(main())
