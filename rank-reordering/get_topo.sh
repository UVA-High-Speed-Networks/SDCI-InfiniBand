#!/usr/bin/env bash
##
# Copyright (C) 2016 University of Virginia. All rights reserved.
#
# @file      get_topo.sh  
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
# @brief   Determines hardware topology of compute nodes using HWLOC 

#BSUB -a poe
#BSUB -P PROJECT_CODE 

#BSUB -q queue
#BSUB -W 00:01
#BSUB -x

#BSUB -J app

#BSUB -o app.stdout.%J
#BSUB -e app.stderr.%J

#BSUB -n 1
#BSUB -R "span[ptile=1]" 

lstopo-no-graphics -p > ys_compute_node_${LSB_JOBID}p.topo
lstopo-no-graphics -l > ys_compute_node_${LSB_JOBID}l.topo
