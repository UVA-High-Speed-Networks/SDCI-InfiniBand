#!/usr/bin/env bash
##
# Copyright (C) 2015 University of Virginia. All rights reserved.
#
# @file      parse_gptl_timings.sh  
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
# @brief   Parses GPTL (General Purpose Timing Library) output and extract the 
#          max boundary exchange times. 

d=$1
for f in $(echo ${d}/*_HommeTime); do
	this=$(basename $f)
	job_id=${this:0:6}
	total=(`grep bndry_exchange $f | head -n1 | grep -oE '[0-9]+(\.)*[0-9]*(e\+*[0-9]*)*'`)
	by_rank=(`grep bndry_exchange $f | sed 1d | awk -F '  +' '{printf "%d,%f,%f,%f\n",$4,$6,$7,$8}'`)
	verbose=0
	if [[ $verbose -eq 0 ]]
		then
			echo ${total[1]},${total[2]},${total[3]},${total[4]},${total[5]},${total[7]},${total[8]} 
	else
		echo 'rank','count','walltotal','max','min'
		len=${#by_rank[@]}
		for i in `seq 0 $(($len - 1))`
		   do
			echo $i,${by_rank[$i]}
		   done
	fi
done
