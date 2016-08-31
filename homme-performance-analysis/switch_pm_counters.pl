#!/usr/bin/env perl
#
#
use strict;
use vars;
use warnings;

my $nodefile = 'hosts_LIDs.txt';
my $job_id=`echo $LSB_JOBID`;
system(mkdir $job_id);

my (@nodelist, %pairs, $pair_count=0);
open(my $LIDs, "<", $nodefile) or die "Unable to open $nodefile. $!\n";
while(my $node = <$LIDs>){
   chomp($node);
   push(@nodelist, $node);
}
close($LIDs) or die "Unable to close $nodefile. $!\n";

foreach my $src (@nodelist){
   foreach my $dest (@nodelist){
      if($src != $dest){
         my @i = ($src,$dest);
	 $pairs{$pair_count++} = \@i;    
     }
  }
}

foreach my $pair (values %pairs){
   system("echo 'Switch Performance Counters: From lid:$pair[0] to lid:$pair[1]' >> $job_id/sw_pm_counters.txt");
   my @paths = `ibtracert_v2.sh $pair[0] $pair[1]`;

   foreach my $line (@paths){
      my @path = split(' ', $line);
      system("perfquery -Gx $path[0] $path[1] >> $job_id/sw_pm_counters.txt");
      system("perfquery -Gx $path[0] $path[2] >> $job_id/sw_pm_counters.txt");
      system("ibqueryerrors -G $path[0]|grep '$path[1]:'|head -n 1 >> $job_id/sw_pm_counters.txt");
      system("ibqueryerrors -G $path[0]|grep '$path[2]:'|head -n 1 >> $job_id/sw_pm_counters.txt");
      system("echo >> $job_id/sw_pm_counters.txt");
   }
   system("echo '************************************************************************************' >> $job_id/sw_pm_counters.txt");
}
