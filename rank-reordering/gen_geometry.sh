#!/bin/bash
##
# Copyright (C) 2015 University of Virginia. All rights reserved.
#
# @file     gen_geometry.sh 
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
# @brief Creates random task geometries for N rank job on a hardware topology
# with NCORE cores per node. A task geometry is used to map MPI task/rank to a physical core.
# default NCORE = 16

declare -i N=$1
declare -i NCORE=$2

rand_seq=($(seq 0 $N | shuf | tr '\n' ' '))
echo "\"{ (`echo ${rand_seq[@]:0:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:16:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:32:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:48:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:64:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:80:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:96:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:112:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:128:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:144:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:160:16} | tr ' ' ,`) \\
(`echo ${rand_seq[@]:176:16} | tr ' ' ,`) }\""
