#!/usr/bin/env python
'''
Measure per-port wait duration.
Each monitoring period last for 20 min.
During each 20 min, a random switch port was chosen. Using perfquery,
we find/read the PortXmitWait counter values. PortXmitWait counter
values are evaluated in ticks. 1 tick =  22 ns
'''
import os
import sys
import re

all = {}
infile = sys.argv[1]
wait = 0
delta_t = 0
times = []
xwaits = []
count = 0

with open(infile,'r') as CONG:
	for line in CONG:
		if count > 0 and count % 100 == 0:
			all[(sw,port)] = [xwaits,times]
			times = []
			xwaits = []
		l = line.strip()
		l_ = l.split(',')
		sw=l_[3]
		port=l_[4]
		xwaits.append(int(l_[5]))
		times.append(float(l_[2]))
		count = count + 1

for k,v in all.iteritems():
	for i in xrange(1,len(v[0])-1):
		if i % 100 == 0:
			continue
		if v[0][i-1] > v[0][i]:
			continue	
		delta_t = (v[1][i] + v[1][i-1]) * 0.5 + (0.1*1e9)
		wait_t = (v[0][i] - v[0][i-1]) * 22
		percent = (wait_t/delta_t)*100
		if percent < 100:
			print "%s,%s,%.3f,%d,%.3f" % (k[0],k[1],delta_t,wait_t,percent)

#for k,v in all.iteriterms():
#	for i in xrange(1,len(v[0])-1):
#		delta_t.append(((v[1][i] + v[1][i-1]) * 0.5 + 0.1))
#		wait.append((v[0][i] - v[0][i-1]) * 22 * 1000000)
#	all[k].append(wait)
#	all[k].append(delta_t)
