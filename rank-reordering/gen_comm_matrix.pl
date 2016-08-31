#!/usr/bin/env perl
##
# Copyright (C) 2015 University of Virginia. All rights reserved.
#
# @file     gen_comm_matrix.pl 
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
# @brief. Construct comm matrix from prv file 

use strict;
use warnings;
use vars;

if ((scalar @ARGV) != 2){
    print "Usage: $0 number of tasks/ranks in MPI application missing\n";
    print "		  $1 paraver file. no .prv\n";
    exit 0;
}

my $nranks=$ARGV[0];
my $prv_file= $ARGV[1];
my $comm_file="comm.mat";
my %mat;


open(my $PRV,'<',$prv_file) or die "$!\n";
open(my $COMM,'>',$comm_file) or die "$!\n";

my @prv_records=<$PRV>;

foreach (@prv_records){
    if ($_ =~/^3:/){
		my @f=split(/:/,$_);
		if ( exists($mat{"$f[0]$f[1]"}) ) {   $mat{"$f[0]$f[1]"} += $f[2];  }
		else 							  {   $mat{"$f[0]$f[1]"}  = $f[2];  }
    }
}

my $size;
for ( my $i=1; $i <= $nranks ; ++$i ){
	for ( my $j=1; $j <= $nranks ; ++$j ) {

		if ( ! exists($mat{"$i$j"}) ) { $size=0; 		    }
		else 						  { $size=$mat{"$i$j"}; }

		if ( $j == $nranks) { print $COMM "$size\n"; }
		else 				    { print $COMM "$size ";  } 
	}
}

print "Completed\n";

close($PRV) or die "$!\n";
close($COMM) or die "$!\n";
