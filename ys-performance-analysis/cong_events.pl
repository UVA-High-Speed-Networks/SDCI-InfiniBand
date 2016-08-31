#!/usr/bin/env perl


# Compute length of congestion events
# based on threshold values

use warnings;
use strict;

my $thresh = 0.00000000002;
my $output = "events_durations_thresh_$thresh.csv";
my $main_f = $ARGV[0];
my $ports_f  = $ARGV[1];

open(my $OUTPUT,'+>',$output) or die "cannot create file '$output'. $!\n";
open(my $MAIN,'<:encoding(UTF-8)' ,$main_f) or die "cannot open file $!\n";
open(my $PORTS,'<:encoding(UTF-8)',$ports_f) or die "cannot open file $!\n";

my @ports   = <$PORTS>;
foreach my $p (@ports){
    chomp($p);
    print "Starting port $p\n";
    my @p_ = split(",",$p);
    my @per_port = ();
    while(<$MAIN>){
        chomp($_);
        if( $_ =~ /^.+,$p_[0],$p_[1],.+$/ ){
            my @l_ = split(",",$_);
            push @per_port,\@l_;
        }
    }

    my $duration = 0;
    my $len = @per_port;
	my $sw_lid;
	my $sw_port;
    for my $i (1..$len-1){
        my $xmitw = $per_port[$i]->[5] - $per_port[$i-1]->[5];
		my $intval = $per_port[$i]->[1] - $per_port[$i-1]->[1] - 0.125 - ($per_port[$i-1]->[2] / 2);
		my $max = ($intval / 22) * 10**9;
		my $percent = $xmitw / $max; 

		$sw_lid = $per_port[$i]->[3]; 
		$sw_port = $per_port[$i]->[4]; 
		
        
		if ($percent >= $thresh){
            $duration += $intval;
        }
        else {

          if ($duration != 0) { print $OUTPUT $sw_lid . "," . $sw_port . "," . $thresh . "," . $duration . "\n"; }
          $duration = 0;
        } 
    }
    if ($duration != 0) { print $OUTPUT $sw_lid . "," . $sw_port . "," . $thresh . "," . $duration . "\n"; }

}
close($OUTPUT) or die "cannot close file '$output'.$!\n";
