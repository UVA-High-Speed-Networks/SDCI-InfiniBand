#!/usr/bin/env perl

use strict;
use warnings;

my %map;
my $date = $ARGV[0];
open(my $MAP,'<','ibdiagnet_aguid.txt') or die "$!\n";
while(<$MAP>){
   chomp $_;
   my @line = split(',',$_);
   $map{$line[0]} = $line[1];
}
close($MAP) or die "$!\n";
my $new_file="portXmitWait_" . $date . "_translated.txt";
my $portXwait="portXmitWait_" . $date . "_ordered.txt";

open(my $NEW,'+>',$new_file) or die "$!\n";
open(my $PortXmit,'<',$portXwait) or die "$!\n";

while(<$PortXmit>){
   chomp $_;
   s/(0x000\w+)/$map{$1}/ge;
   my @l = split(',',$_);
   $map_translated{$l[0]} = $l[1];
   print $NEW "$_\n";

}

close($PortXmit) or die "$!\n";
close($NEW) or die "$!\n";

