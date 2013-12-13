#!/usr/bin/perl
use warnings;
use strict;
use File::Basename;
use Proc::PID::File;
use Log::Dispatch::FileRotate;
use POSIX qw(strftime setsid);

my $program = basename $0;

if (Proc::PID::File->running(dir=>"/var/run")) {
        print "Daemon is running already...\n";
        exit(0);
} else {
        print "Daemon started - $0\n";
}

chdir '/' or die "Can't chdir to /: $!";
umask 0;
open STDIN, "<", "/dev/null" or die "Can't read /dev/null: $!";
open STDOUT, ">", "/dev/null" or die "Can't write to /dev/null: $!";
open STDERR, ">", "/dev/null" or die "Can't write to /dev/null: $!";
defined(my $pid = fork) or die "Can't fork: $!";
exit if $pid;
setsid or die "Can't start a new session: $!";

my $PID = $$;
#print "Daemon started - processid: $PID\n";

open F, ">", "/var/run/$program.pid" or die "Can't open pid $!";
print F $PID;
close F;

my $log = Log::Dispatch::FileRotate->new(
        name => "file1",
        min_level => "info",
        filename => "/var/log/$program.log",
        mode => "append",
        TZ => "PST",
#        DatePattern => 'yyyy-MM-dd',
);

$log->log( level => "info", message => &get_epoch2date(time)." - Daemon started - processid: $PID\n" );

while (1) {
        my $master = `df -h | grep /dev/drbd1`;
        if ($master) {
                &restart;
        }
        sleep 20;
}

sub restart {
        my $dhcpd = `ps -efa | grep dhcpd | grep -v grep`;
        my $nfs = `/etc/init.d/nfs status | grep running | wc -l`;
        my $master = `df -h | grep /dev/drbd1`;
        return unless $master;
        unless ($dhcpd) {
                chomp (my @output1 = `/etc/init.d/dhcpd start 2>&1`);
                for my $output (@output1) {
                        $log->log( level => "info", message => &get_epoch2date(time)." $output\n" );
                }
        }
        unless ($nfs == 3) {
                chomp (my @output2 = `/etc/ha.d/resource.d/nfs restart 2>&1`);
                for my $output (@output2) {
                        $log->log( level => "info", message => &get_epoch2date(time)." $output\n" );
                }
        }
}

sub get_epoch2date {
    my $timestamp = shift;
    return strftime "%Y-%m-%d %H:%M:%S", localtime($timestamp);
}
