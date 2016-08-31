#!/usr/bin/env perl
#
#
#
use warnings;
use strict;
use vars;

my $hosts_file = $ARGV[0];
my $fh;
open($fh, "<", $hosts_file) or die "Unable to open $hosts_file. $!\n";
my (%host2lid, %pairs);

while(my $line = <$fh>){ 
   chomp $line;
   my($name, $lid) = split(',', $line);  
   $host2lid{$name} = $lid;
}

close($fh) or die "Unable to close $hosts_file. $!\n";

my $pair_count = 0;
foreach my $src (keys %host2lid){
   foreach my $dest (keys %host2lid){
      if($src ne $dest){
         my $hop_count = `ibtracert $host2lid{$src} $host2lid{$dest}|wc -l`;
         my @i = ($src,$dest,$hop_count - 2);
	 $pairs{$pair_count++} = \@i;    
     }
  }
} 

my $fh1;
open($fh1, ">", "hops.csv") or die "$!\n";

print $fh1 "from_host,to_host,hop\n";
foreach my $pair (values %pairs){
   print $fh1 @$pair[0] . "," . @$pair[1] . "," . @$pair[2] . "\n";
}

close($fh1) or die "$!\n";
