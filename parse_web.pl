#!perl -w
use strict;
use LWP::Simple;

while (1) {
	my @result = &get_data;
	print for @result;
	sleep 1;
}


sub get_data {
	my $content = get("http://www.zhijinwang.com/etf/");
	warn "Couldn't get it!\n" unless defined $content;

	
	my ($desire) = $content =~ qr/∞ªÀæ.*?(\d+-\d+-\d+.*∞ªÀæ)/s;
	my $date = &present_date;
	my @list = $desire =~ /($date.*?∞ªÀæ)/gs;
	my @result;

	for (@list) {
		my @fields = /(\d+-\d+-\d+(?:\s+\d+:\d+:\d+)?).*>(.*?∂÷)<.*>(.*?√¿‘™)</s;
		for my $field (@fields) {
			next if $field =~ /\d+-\d+-\d+\s+\d+:\d+:\d+/;
			$field =~ s/\s+//g;
		}
		push @result, sprintf "%-19s\t%20s\t%20s\n", @fields;
	}
	
	return @result;
}

sub present_date {
	my ($sec, $min, $hour, $mday, $mon, $year) = localtime;
	$year += 1900;
	$mon += 1;
	my $date = sprintf "%d-%d-%d", $year, $mon, $mday;
	
	return $date;
}
