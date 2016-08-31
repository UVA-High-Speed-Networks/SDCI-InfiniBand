#!/usr/bin/env python
'''
Measure per-port wait duration.
Each monitoring period last for 20 min.
During each 20 min, a random switch port was chosen. Using perfquery,
we find/read the PortXmitWait counter values. PortXmitWait counter
values are evaluated in ticks. 1 tick =  22 ns on FDR
'''
import os
import sys
import re

all = {}
switches = sys.argv[1]
waits = sys.argv[2]

with open(switches,'r') as SWITCHES:
	for line in SWITCHES:
		l = line.strip()
		l_ = l.split(',')
		sw_lid=l_[0]
		name=l_[1]
		loc=l_[2]
		all[sw]=(name,loc)


with open(waits,'r') as WAITS:
	for line in WAITS:
		l = line.strip()
		l_ = l.split(',')
		sw=l_[0]
		port=l_[1]
		rest=l_[2:]
		
		name = all[sw][0]
		loc = all[sw][1] 
		ac_loc = 'undef'
		if loc[0] == 'L' and name == 'g': ac_loc='gladeLeaf'
		elif loc[0] == 'L' and name == 'c': ac_loc='DAVLeaf'
		elif loc[0] == 'S' and name == 'g': ac_loc='gladeSpine'
		elif loc[0] == 'S' and name == 'c': ac_loc='DAVSpine'
		elif loc[0] == 'S': ac_loc='Spine'
		elif loc[0] == 'T': ac_loc='TOR'
		elif loc[0] == 'L': ac_loc='Leaf'
		
		if ac_loc[0] == 'u': continue
		if port > 18 and ac_loc[0] != 'S': direction='up'
		else direction='down' 

		print sw,port,ac_loc,direction,rest 
