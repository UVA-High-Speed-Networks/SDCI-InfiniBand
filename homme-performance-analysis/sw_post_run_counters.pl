#!/usr/bin/env perl
#Records switches pm counters after job terminates. 
#
use strict;
use vars;
use warnings;

my $job_id = `echo -n $ENV{LSB_JOBID}`;
my $paths_file = "$job_id/paths.txt";
open(my $fh, "<", $paths_file) or die "Unable to open $paths_file. $!\n";

   while(my $line = <$fh>){
      chomp $line;
      my @path = split(' ', $line);
      system("ibqueryerrors -G $path[0]|egrep '$path[1]:'|head -n 1 >> $job_id/post_run_sw_XmitWaits.txt");
      system("ibqueryerrors -G $path[0]|egrep '$path[2]:'|head -n 1 >> $job_id/post_run_sw_XmitWaits.txt");
     
      #system("perfquery -Gx $path[0] $path[1] >> $job_id/sw_post_run_counters.txt");
      #system("perfquery -Gx $path[0] $path[2] >> $job_id/sw_post_run_counters.txt");
      
   }
close($fh) or die "Unable to close $paths_file. $!\n"; 
