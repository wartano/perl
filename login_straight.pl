#!perl
use warnings;
use strict;
use POSIX qw/strftime/;
use Time::Local;

my %hash;
my @qualified;
my $login_days = shift @ARGV;#login n days straight

while (<>) {
	next unless /login/;
	my ($userid, $ymd) = ((split)[0,2]);
	my ($y, $m, $d) = split /-/, $ymd;
	$ymd = sprintf "%04d-%02d-%02d", $y, $m, $d;
	$hash{$userid}{$ymd} = 1;	
}
for my $userid (keys %hash) {
	for (keys %{$hash{$userid}}) {
		my $datetime = $_." 00:00:01";
		my ($y, $m, $d, $h, $mm, $ss) = split /\D+/, $datetime;
		my $ts = timelocal($ss, $mm, $h, $d, $m - 1, $y);
		my $count = &login_check($ts, $userid);
		if ($count == $login_days && ! grep $userid eq $_, @qualified) {
			push @qualified, $userid;
		}
	}
}
open FILE, ">", "result.txt" or die "can't open file: $!\n";
print FILE "$_\t$login_days\n" for @qualified;
close FILE;

sub login_check {
	my ($ts, $userid) = @_;
	my $count;
	for (my $t = $ts; $t >= $t - ($login_days - 1) * 86400; $t -= 86400) {
		my $check = (split ' ', (strftime "%Y-%m-%d %H:%M:%S", localtime($t)))[0];
		if (exists $hash{$userid}{$check}) {
			$count++;
		} else {
			last;
		}
	}
	return $count;
}
