#!/usr/bin/env perl
#Records Switch pm counters before job run.
#
use strict;
use vars;
use warnings;

my $dir=$ARGV[0];
my $job_id= `echo -n $ENV{LSB_JOBID}`;
my $nodefile = "$dir/$job_id/hosts_LIDs.txt";

my (@nodelist, %pairs);
open(my $LIDs, "<", $nodefile) or die "Unable to open $nodefile. $!\n";
while(my $node = <$LIDs>){
   chomp($node);
   push(@nodelist, $node);
}
close($LIDs) or die "Unable to close $nodefile. $!\n";

my $pair_count = 0;
foreach my $src (@nodelist){
   foreach my $dest (@nodelist){
      if($src != $dest && abs($src-$dest) != 1){
         my @i = ($src,$dest);
	 $pairs{$pair_count++} = \@i;    
     }
  }
}
foreach my $pair (values %pairs){
   #system("echo 'Switch Performance Counters: From lid:@$pair[0] to lid:@$pair[1]' >> $dir/$job_id/Switch_PortXmitWaits.txt");
   system("ibtracert_v2.sh @$pair[0] @$pair[1] >> $dir/$job_id/routes.txt");
}

system("cat $dir/$job_id/routes.txt | sort -u |uniq > $dir/$job_id/paths.txt");

my $paths_file = "$dir/$job_id/paths.txt";
open(my $fh, "<", $paths_file) or die "Unable to open $paths_file. $!\n";   
while(my $line = <$fh> ){
      chomp($line);
      my @path = split(' ', $line);
#      system("perfquery -Gx $path[0] $path[1] >> $dir/$job_id/sw_pre_run_counters.txt");
      system("ibqueryerrors -G $path[0]|egrep '$path[1]:'|head -n 1 >> $dir/$job_id/pre_run_sw_XmitWaits.txt");
#      system("perfquery -Gx $path[0] $path[2] >> $dir/$job_id/sw_pre_run_counters.txt");
      system("ibqueryerrors -G $path[0]|egrep '$path[2]:'|head -n 1 >> $dir/$job_id/pre_run_sw_XmitWaits.txt");
}

close($fh) or die "Unable to close $paths_file. $!\n"
