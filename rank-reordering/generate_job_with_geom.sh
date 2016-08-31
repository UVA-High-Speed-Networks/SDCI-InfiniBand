#!/usr/bin/env bash
##
# Copyright (C) 2016 University of Virginia. All rights reserved.
#
# @file      generate_job_with_geom.sh 
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
# @brief  Generates job submission script with different algorithmic task geometries.  
# task geoms: folded_rank, rr, rr_socket, smp        
# To submit a job using this script, bsub < <(generate_job_with_geom.sh)

#folded_rank
#geom="\"{ (0,16,32,48,64,80,81,65,49,33,17,1,2,18,34,50) \
#(66,82,83,67,51,35,19,3,4,20,36,52,68,84,85,69) \
#(53,37,21,5,6,22,38,54,70,86,87,71,55,39,23,7) \
#(8,24,40,56,72,88,89,73,57,41,25,9,10,26,42,58) \
#(74,90,91,75,59,43,27,11,12,28,44,60,76,92,93,77) \
#(61,45,29,13,14,30,46,62,78,94,95,79,63,47,31,15) }\""

##rr
#geom="\"{ (0,16,32,48,64,80,1,17,33,49,65,81,2,18,34,50) \
#(66,82,3,19,35,51,67,83,4,20,36,52,68,84,5,21) \
#(37,53,69,85,6,22,38,54,70,86,7,23,39,55,71,87) \
#(8,24,40,56,72,88,9,25,41,57,73,89,10,26,42,58) \
#(74,90,11,27,43,59,75,91,12,28,44,60,76,92,13,29) \
#(45,61,77,93,14,30,46,62,78,94,15,31,47,63,79,95) }\""

##rr_socket
#geom="\"{ (0,8,1,9,2,10,3,11,4,12,5,13,6,14,7,15) \
#(16,24,17,25,18,26,19,27,20,28,21,29,22,30,23,31) \
#(32,40,33,41,34,42,35,43,36,44,37,45,38,46,39,47) \
#(48,56,49,57,50,58,51,59,52,60,53,61,54,62,55,63)
#(64,72,65,73,66,74,67,75,68,76,69,77,70,78,71,79)
#(80,88,81,89,82,90,83,91,84,92,85,93,86,94,87,95) }\""

#####smp
geom="\"{ (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) \
(16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31) \
(32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47) \
(48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63) \
(64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79) \
(80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95) }\""

node_list="\"node1 node2 node3 node4 node5 node6\""

cat << EOF 
#!/bin/bash

#BSUB -a poe
#BSUB -P PROJECT_CODE 

#BSUB -q queue 
#BSUB -W 00:05
#BSUB -x

#BSUB -J app 

#BSUB -o app.stdout.%J
#BSUB -e app.stderr.%J

#BSUB -n 96
#BSUB -R "span[ptile=16]" 
#BSUB -m $(echo "${node_list}")

export LSB_TASK_GEOMETRY=$(echo "${geom}")

app=/path/to/MPI/application/exe
mpirun.lsf \${app} < input.nl 

EOF
