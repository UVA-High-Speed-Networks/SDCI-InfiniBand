#!/usr/bin/perl

use Data::Dumper qw(Dumper);

$paths = $ARGV[0];
%path_hosts = ();
$count=0;

open IBNET_TOPO,"<$paths" or die "Unable to open $paths. $!\n";
while ($line = <IBNET_TOPO>) {
	$sw="";
	#if ( $line =~ /^From.*\".*;(ys.*:SX6036).*\".*$/){ #TOR switches
	#if ( $line =~ /^From.*\".*;(ys.*\/L.*).*\".*$/){ #Leaf switches
	if ( $line =~ /^From.*\".*;(ca00ib1a.*\/L.*).*\".*$/){ #Caldera leaf switches
	#if ( $line =~ /^From.*\".*;(ca00ib1a.*\/S.*).*\".*$/){ #Caldera spine switches

	#if ( $line =~ /^From.*\".*;(ys.*:SX6536\/L29).*\".*$/){
	#if ( $line =~ /^From.*/){
		$in_paths="yes";
		$sw = $1;
		#print $line . "\n";
		next;
	}
	elsif ($line =~ /^To.*/) { 
		if($in_paths eq "yes"){
		$path_hops{$count} += 1;
		#print "count: " . $count . "\n";
		$count = 0;
	    }	
		$in_paths = "no";
	}

	if ($in_paths eq "yes"){
		$count+=1;
	}
	


}

print Dumper(\%path_hops);
close IBNET_TOPO or die "Unable to close $paths. $!\n";
