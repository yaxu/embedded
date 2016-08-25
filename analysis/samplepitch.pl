#!/usr/bin/perl -w

use strict;

my $folder = "/home/alex/Dropbox/projects/dirt/samples";

opendir(my $dh, $folder) or die;
my @subfolders = grep { (! /^\./) && -d "$folder/$_" } readdir($dh);
closedir($dh);

my $first = 1;

print "pitches = [\n";

foreach my $subfolder (@subfolders) {
    if (!$first) {
	print ",\n";
    }
    else {
	$first = 0;
    }
    opendir(my $dh, "$folder/$subfolder") or die;
    my @files = grep {/\.wav$/i} readdir($dh);
    closedir($dh);
    print "  (\"$subfolder\",\n    [";
    my @averages;
    foreach my $file (sort @files) {
	my $fn = "$folder/$subfolder/" . quotemeta($file);
	my @output = `aubiopitch $fn`;
	my $n = 0;
	my $total = 0;
	foreach my $line (@output) {
	    if ($line =~ /(\d+(?:.\d+))\s(\d+(?:.\d+))/) {
		my ($time, $value) = ($1, $2);
		if ($value > 0) {
		    $n++;
		    $total += $value;
		}
	    }
	}
	push(@averages, $n ? $total /  $n : 0);
    }
    print(join(", ", @averages));
    print("])")
}
print "\n ]";
