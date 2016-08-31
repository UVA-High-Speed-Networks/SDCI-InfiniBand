#!/usr/bin/env bash
##
# Copyright (C) 2016 University of Virginia. All rights reserved.
#
# @file      compute_edit_cost.sh 
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
# @brief   Compute edit cost (https://en.wikipedia.org/wiki/Edit_distance) from optimal task geometry
#          and any other task geom.  


GEOM=$1
OPT_GEOM=$2
geom=(`cat $GEOM | tr '(|)|{|}' ' ' | tr ' ' ',' | sed 's/,,,/,/g' | sed -E -e 's/(^,|,$)//g' | tr ',' ' '`)
opt_geom=(`cat $OPT_GEOM | tr ',' ' '`)
if [[ ${#geom[@]} -ne ${#opt_geom[@]} ]]; then exit -1;fi

#Example:
#TreeMatch: 0,1,8,9,11,10,4,5,6,13,15,2,12,14,7,3
#Means that proccess 0 is mapped to core 0, 1 to 1 , 2 to 8, ... and 15 to 3

#Treematch
#rank: position, core: element.

#Task geometry
#rank:element, core: position

#Tranform mapping output
declare -a optimal
declare -i total_dist

for i in `seq 0 $((${#opt_geom[@]}-1))`; do optimal[${opt_geom[$i]}]=$i; done 

#find edit distance between optimal and random task_geom
for i in `seq 0 $((${#opt_geom[@]}-1))`; do
	dist=$((${optimal[$i]}-${geom[$i]}))
	if [[ $dist -lt 0 ]] ; then total_dist=$(($total_dist-$dist))
	else total_dist=$(($total_dist+$dist)); fi	
done

echo $total_dist
