#!/usr/bin/env perl
#
use warnings;
use strict;
use vars;
use List::Util qw( min max );
use Data::Dumper;
my $delay_file = $ARGV[0];
my $ping_file = $ARGV[1];
open(my $CSV,'<',$delay_file) or die "Unable to open $delay_file. $!\n";
my @delays = <$CSV>;
my %pair2hop;
foreach (@delays){
	chomp $_;
	my($src, $dest, $hop) = split(',', $_);  
	$pair2hop{($src,$dest)} = $hop; 
}
close($CSV) or die "Unable to close $delay_file. $!\n";

open(my $PING,'<',$ping_file) or die "Unable to open $ping_file. $!\n";
my @pings = <$PING>;
close($PING) or die "Unable to close $ping_file. $!\n";
my $size;
my $hop;
my %min_pings;
%min_pings = (
	0 => [],
	2 => [],
	4 => [],
	6 => [],
);

foreach (@pings){
	chomp $_;
	my @fields = split(',', $_);  
    $size = $fields[0];
	$hop = $pair2hop{($fields[3],$fields[4])};
	push @{ $min_pings{$hop} },$fields[7];
}
foreach my $key (keys %min_pings){
	print $size . "," . $key . "," . min(@{ $min_pings{$key} }) . "\n";   
}
