#!/usr/bin/perl -w

use strict;

my $fn = $ARGV[0];
open(my $svgfh, "<$fn")
    or die "couldn't open $fn: $!";
my $svg;
{
    local $/;
    undef $/;
    $svg = <$svgfh>
}
close $svgfh;
$svg =~ s!<svg\s+(.*?)>!<svg $1 shape-rendering="crispEdges">!s;

open($svgfh, ">$fn")
    or die "couldn't open $fn for writing: $!";
print $svgfh $svg;
close($svgfh);

0;
