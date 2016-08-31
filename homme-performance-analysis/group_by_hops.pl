#!/usr/bin/env perl
#
#Group delays from .csv files by hop count
#

use warnings;
use strict;
use vars;

my $cron_captures='/glade/p/work/fabmiz/mpi_pingpong/pingpong_cron_captures';
my $job_dir = $ARGV[0];
my @path2csv = split('/', $ARGV[0]);

my (@src,@dest,@delays);

open(my $h2h, "<", "$cron_captures/$path2csv[0]/$path2csv[1]/host2host_hops.txt") or die "Can't open $cron_captures/$path2csv[0]/$path2csv[1]/host2host_hops.txt. $!\n";
         while(my $line = <$h2h>){
	   chomp $line;
           my @i = split(' ', $line);
           push(@src, $i[0]); push(@dest, $i[1]); push(@delays, $i[2]);
         }
close($h2h) or die "$cron_captures/$path2csv[0]/$path2csv[1]/host2host_hops.txt. $!\n";

#print "src_arr: $#src \ndest_arr: $#dest \ndelays_arr: $#delays \n";
if($#src != $#dest || $#src != $#delays){
   print "Error...reading from host2host_hops.txt.\n";
   exit 40;
}

open(my $csv, "<", "$cron_captures/$job_dir") or die "Can't open .csv file: $cron_captures/$job_dir. $!\n"; 
open(my $fh0, '>>', "$cron_captures/$path2csv[0]/$path2csv[1]/0_hop_delays.txt") or die "Can't open $cron_captures/$path2csv[0]/$path2csv[1]/0_hop_delays.txt. $!\n";
open(my $fh2, '>>', "$cron_captures/$path2csv[0]/$path2csv[1]/2_hop_delays.txt") or die "Can't open $cron_captures/$path2csv[0]/$path2csv[1]/2_hop_delays.txt. $!\n";
open(my $fh4, '>>', "$cron_captures/$path2csv[0]/$path2csv[1]/4_hop_delays.txt") or die "Can't open $cron_captures/$path2csv[0]/$path2csv[1]/4_hop_delays.txt. $!\n";
open(my $fh6, '>>', "$cron_captures/$path2csv[0]/$path2csv[1]/6_hop_delays.txt") or die "Can't open $cron_captures/$path2csv[0]/$path2csv[1]/6_hop_delays.txt. $!\n";

      print ">>>>Saving 0,2,4,6 Hop(s) delays. $cron_captures/$job_dir \n";
      while(my $line = <$csv>){
           chomp $line;
           my @comm_line = split(",", $line);
           if($#comm_line != 6){ next; }
           if($comm_line[2] eq $comm_line[3]){ 
               print $fh0 $comm_line[6]."\n";
               next;
           }
   
           foreach my $i (0..$#src){
                 if($src[$i] eq $comm_line[2] && $dest[$i] eq $comm_line[3]){
                    if($delays[$i] == 2){
                        print $fh2 $comm_line[6]."\n";}
                    elsif($delays[$i] == 4){
                        print $fh4 $comm_line[6]."\n";}
                    elsif($delays[$i] == 6){
                        print $fh6 $comm_line[6]."\n"; }
                    else { print "Error. Possible hop count on YS: 0,2,4,6 \n"; }
                    
                 }
            }
       }

      print ">>>>Done saving hop delays \n $cron_captures/$job_dir \n";
close($csv) or die "Can't close .csv file: $cron_captures/$job_dir. $!\n";
close($fh0) or die "Can't close $cron_captures/$path2csv[0]/$path2csv[1]/0_hop_delays.txt. $!\n";
close($fh2) or die "Can't close $cron_captures/$path2csv[0]/$path2csv[1]/2_hop_delays.txt. $!\n";
close($fh4) or die "Can't close $cron_captures/$path2csv[0]/$path2csv[1]/4_hop_delays.txt. $!\n";
close($fh6) or die "Can't close $cron_captures/$path2csv[0]/$path2csv[1]/6_hop_delays.txt. $!\n";

