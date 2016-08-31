#!/usr/bin/perl

sub gen_topo
{
    if (`sudo ibnetdiscover -g > $topo_file`) {
		die "Execution of ibnetdiscover failed: $!\n";
	}
	return($topo_file);	
}

sub get_remote_ports
{
	my $topo = $_[0];
	
	open IBNET_TOPO, "<$topo"
	  or die "Failed to open ibnet topology: $!\n";
	my $in_switch  = "no";
	my $desc       = "";
	my $guid       = "";
	my $loc_sw_lid = "";

	my $loc_port = "";
	my $line     = "";

	while ($line = <IBNET_TOPO>) {
		if ($line =~ /^Switch.*\"S-(.*)\"\s+#.*\"(.*)\".* lid (\d+).*/) {
			$guid       = $1;
			$desc       = $2;
			$loc_sw_lid = $3;
			$in_switch  = "yes";
		}
		if ($in_switch eq "yes") {
			my $rec = undef;
			
			print "Current switch lid: " . $loc_sw_lid . "\n";
	
			if ($line =~
/^\[(\d+)\]\s+\"[HSR]-(.+)\"\[(\d+)\](\(.+\))?\s+#.*\"(.*)\"\.* lid (\d+).*/
			  )
			{
				$loc_port = $1;
				my $rem_guid      = $2;
				my $rem_port      = $3;
				my $rem_port_guid = $4;
				my $rem_desc      = $5;
				my $rem_lid       = $6;
				$rec = {
					loc_guid      => "0x$guid",
					loc_port      => $loc_port,
					loc_ext_port  => "",
					loc_desc      => $desc,
					loc_sw_lid    => $loc_sw_lid,
					rem_guid      => "0x$rem_guid",
					rem_lid       => $rem_lid,
					rem_port      => $rem_port,
					rem_ext_port  => "",
					rem_desc      => $rem_desc,
					rem_port_guid => $rem_port_guid
				};
			}
		}
		if ($line =~ /^Ca.*/ || $line =~ /^Rt.*/) { $in_switch = "no"; }
	}
	close IBNET_TOPO;
}


sub main{

get_remote_ports($ARGV[0]);

}
main
