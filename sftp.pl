#!/bin/env perl

#####################################################
###This perl script is used to fetch patch files####
#####################################################

use warnings;
use strict;
use Net::SFTP::Foreign;

die "Usage: sftp.pl <file 1> <file 2> ... <file n>\n" unless @ARGV > 0;
my @files = @ARGV;
my %args = (
    host=>'xxx',
    port=>'4469',
    user=>'xxx'
);
#my $path = '/home/chrootusers/home/guoshi';
my $sftp = Net::SFTP::Foreign->new(%args);
$sftp->error and die "Unable to stablish SFTP connection: " . $sftp->error;
#$sftp->setcwd($path) or die "unable to change cwd: " . $sftp->error;
for (@files) {
    eval {
        $sftp->get("$_", "./$_") or die "get $_ failed: ".$sftp->error;
    };
    print "An error occured :$@" if $@;
}
