#!/usr/bin/perl -w
# copy_number_to_JSON.pl --- convert copy number data file into a json data formatted file
# Author: Zehir <zehira@LPTH0108>
# Created: 16 Oct 2013
# Version: 0.01

use warnings;
use strict;
use lib("/Users/zehira/Software/JSON-2.59/lib");
use JSON;

my %geneHash;


my $file = $ARGV[0];


my (%cnHash);
my ($y1, $y2) = (0, 0);
open IN, "<", $file || die $!;
while (<IN>) {
    chomp;
    next if(/^sample/);
    my @line = split("\t");
    push @{$cnHash{$line[0]}}, $_;
}
close IN;

foreach my $key (sort keys %cnHash){
    #sample	norm_used	region	lr	NExons	chr	fc	p.adj	sig
    my @vars = @{$cnHash{$key}};
    my $i = 1;
    my @data;
    foreach (@vars){
	    my @line = split("\t", $_);
	    my $sample = $line[0];
	    my $normal = $line[1];
	    my $region = $line[3];
	    my $lr =$line[4];
	    my $NExons = $line[5];
	    my $chr = $line[6];
	    my $fc = $line[7];
	    my $padj = $line[8];
	    my $sig = $line[9];
	    my $sigIntragenic = $line[10];
	    my $cyt = $line[11];
	    my ($gene, $txID, $exon, $boundaries) = ("", "", "", "");
	    if($line[12]){
	    	($gene, $txID, $exon, $boundaries, undef, undef) = split(":", $line[12]); #STK11:NM_000455:exon1:19:1206913:1207202
	    }
	    my $type;
	    if($gene eq "Tiling"){
	    	$type="Tiling";
	    }else{
	    	$type ="Gene";
	    }
	    next if($lr =~ /NA/);
	    push @data, {region => $region, x => $i, lr => $lr, pval => $padj, sig => $sig, fc => $fc, chr =>$chr, sigIntragenic => $sigIntragenic, gene => $gene, txID => $txID, exon => $exon, boundary => $boundaries, cytoband => $cyt, type => $type};
	    $i++;
    }
    my $j = new JSON;
	my $allowed = "T";
	$j = $j->allow_blessed([$allowed]);
	$j = encode_json \@data;
	my $output = $key;
	$output .= ".CN.json";
	open OUT, ">", $output;
	print OUT $j;
	close OUT;
    
}



sub calculateY{
	my $dat = $_[0];
	my @data = @$dat;
	my @sortedData = sort @data;
	my $y1 = $sortedData[0];
	my $y2 = $sortedData[-1];
	return ($y1, $y2);
}


__END__

=head1 NAME

copy_number_to_JSON.pl - Describe the usage of script briefly

=head1 SYNOPSIS

copy_number_to_JSON.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for copy_number_to_JSON.pl, 

=head1 AUTHOR

Zehir, E<lt>zehira@LPTH0108E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Zehir

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
