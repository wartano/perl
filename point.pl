#!perl -w
use strict;
use File::Basename;
my $name = basename $0;
die "Usage: $name <old_file> <new_file>\n" unless @ARGV == 2;
my %hash;
while (<>) {
	my ($id, $point) = split;
	push @{$hash{$id}}, $point;
}

my %hash1;
for my $key (keys %hash) {
	$hash{$key}->[1] = 0 unless defined $hash{$key}->[1];
	my $difference = abs ($hash{$key}->[1] - $hash{$key}->[0]);
	$hash1{$key} = $difference;
}

open FILE, ">", "result.txt" or die "can't open file: $!\n";
for my $key (sort {$hash1{$b} <=> $hash1{$a}} keys %hash1) {
	print FILE "$key\t$hash1{$key}\n";
}
close FILE;
