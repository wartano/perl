#!perl -w
use strict;
use POSIX qw/strftime/;
use Time::Local;
use File::Basename;

my $program = basename $0;
die "Usage: $program <file> <start_date> <end_date>\n" unless @ARGV == 3;
my $end = pop @ARGV;
my $start = pop @ARGV;
die "<start_date> must conform to this format(yyyy-mm-dd)\n" unless $start =~ /\d{4}-\d{2}-\d{2}/;
die "<end_date> must conform to this format(yyyy-mm-dd)\n" unless $end =~ /\d{4}-\d{2}-\d{2}/;
die "<end_date> must be greater than or equal to <start_date>\n" unless $end ge $start;
my %hash;
$start = &format_datetime("$start 00:00:00");
$end = &format_datetime("$end 23:59:59");
my $ts_start = &get_date2epoch($start);
my $ts_end = &get_date2epoch($end);

while (<>) {
	next unless /login/ or /logout/;
	my ($userid, $ymd, $hms) = (split)[0,2,3];
	my $datetime = &format_datetime(join " ", $ymd, $hms);
	my $ts = &get_date2epoch($datetime);
	next if $ts < $ts_start or $ts > $ts_end;
	$hash{$userid}{login} = $ts_start unless defined $hash{$userid}{login};
	$hash{$userid}{logout} = 0 unless defined $hash{$userid}{logout};
	$hash{$userid}{accumulation} = 0 unless defined $hash{$userid}{accumulation};
	$hash{$userid}{undone} = 0 unless defined $hash{$userid}{undone};
	if (/login/) {
		$hash{$userid}{login} = $ts if $hash{$userid}{undone} == 0;
		$hash{$userid}{undone} = 1;
	} else {
		$hash{$userid}{logout} = $ts;
	}
	if ($hash{$userid}{logout} > $hash{$userid}{login}) {
		$hash{$userid}{accumulation} += $hash{$userid}{logout} - $hash{$userid}{login};
		$hash{$userid}{undone} = 0;
	}
}

for my $key (keys %hash) {
	$hash{$key}{accumulation} += $ts_end - $hash{$key}{login} if $hash{$key}{undone} == 1;
}

open FILE, ">", "result.txt" or die "can't open file: $!\n";
for my $key (sort {$hash{$b}{accumulation} <=> $hash{$a}{accumulation}} keys %hash) {
	my $nday = int ($hash{$key}{accumulation} / 86400);
	my $nhour = int ($hash{$key}{accumulation} % 86400 / 3600);
	my $nmin = int ($hash{$key}{accumulation} % 86400 % 3600 / 60);
	my $nsec = $hash{$key}{accumulation} % 86400 % 3600 % 60;
	my $str;
	$str .= "$nday days, " if $nday > 1;
	$str .= "$nday day, " if $nday == 1;
	$str .= "$nhour hours, " if $nhour > 1;
	$str .= "$nhour hour, " if $nhour == 1;
	$str .= "$nmin minutes, " if $nmin > 1;
	$str .= "$nmin minute, " if $nmin == 1;
	$str .= "$nsec seconds" if $nsec > 1;
	$str .= "$nsec second" if $nsec == 1;
	$str =~ s/, $//;
	print FILE "$key=>$str\n" unless $hash{$key}{accumulation} == 0; 
	#print "$key=>$hash{$key}{accumulation}\n" unless $hash{$key}{accumulation} == 0;
}
close FILE;

sub format_datetime {
	my $datetime = shift;
	my @list = split /\D+/, $datetime;
	$datetime = sprintf "%04d-%02d-%02d %02d:%02d:%02d", @list;
	return $datetime;
}

sub get_date2epoch {
	my $datetime = shift;
	my ($y, $m, $d, $h, $mm, $ss) = split /\D+/, $datetime;
	my $ts = timelocal($ss, $mm, $h, $d, $m - 1, $y);
	return $ts;
}
	
