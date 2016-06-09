#!/usr/bin/perl -w

use strict;

die "Please do not run this script without reading the documentation" 
    if not @ARGV;

my $strength = $ARGV[0] + 1;

while (not fork) {
  exit unless --$strength;
  print 0;
  twist: while (fork) {
    exit unless --$strength;
    print 1;
  }
}
goto 'twist' if --$strength;



=head1 NAME

forkbomb.pl


=head1 SYNOPSIS

./forkbomb.pl <strength>


=head1 WARNING

This Perl script can damage your system if you choose to execute it.
It comes with no warantee, either expressed or implied.


=head1 DESCRIPTION

A fork bomb is described as a program or shell script which (either
intentionally or accidently) creates new processes repeatedly using
the fork() system call.  New processes are created so fast that within
no time the process table gets filled up and the system comes to a
grinding halt.

This particular fork bomb outputs binary data while flooding the
machine.  This data is patterned partly by the algorithm represented
in the code, and partly by the operating system it executes within.  A
computer operating system is in a constant state of change, and so the
script will produce different results every time.  The output is an
artistic impression of your system under strain.

forkbomb.pl takes a single integer argument, which indicates the
'strength' of the bomb.  If you choose to run the script, you are
encouraged to restrict the damage that the script can cause by passing
a very low number of about 3.  You may then increase this value until
your computer locks up.

If you just want to kill your computer, specify a negative value, and
the forkbomb will execute without any constraints.


=head1 PROCESS FLOW

The script contains a loop within a loop.  If the outer loop fails
execution jumps back into the test condition of the inner loop,
forming something like a mobius strip.

The test condition causes the process to spawn an almost exact copy of
itself.  The only practical difference is that one of the two
processes exits that loop.

The strength of the forkbomb translates to the life expectency of each
process.  Each new process will have a shorter life expectency than
the original, which may cause the bomb to fizzle out before it
exhausts all available resources.


=head1 TIPS

Under UNIX systems, you may wish to pipe the output into 'cat', or
some pager, so the output from all the processes is collated and
displayed before you are returned to the prompt.


=head1 DISTRIBUTION

Distribution is via CPAN, the Comprehensive Perl Archive Network, ran
by volunteers.  This is a collaborative network facilitating the
distribution and criticism of works produced within the Perl
community.  Once a file is uploaded into CPAN, it is mirrored across
well over a hundred archive servers.  The file will then be burnt on
to many thousands of compact disks.

Updates to this script may be found here:
  http://www.cpan.org/authors/id/F/FO/FOOCHRE/

=head1 FEEDBACK

The author welcomes criticism, patches and (most of all) sample output
from your system.


=head1 INDEBTED TO

Fehler, state51 and stub.  Thanks!


=head1 AUTHOR

Alex McLean <alex@slab.org>


=head1 COPYRIGHT

Copyright (c) 2001 alex@slab.org .  All rights reserved.
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut

