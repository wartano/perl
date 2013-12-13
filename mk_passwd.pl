#!perl -w
use strict;
use String::MkPasswd qw(mkpasswd);
use List::Util qw(shuffle);
open FILE,">","password.txt" or die "cannot open file:$!\n";
for(1..10){
	(my$password=mkpasswd(
		-length     => 16,
		-minnum     => 4,
		-minlower   => 4,
		-minupper   => 4,
		-minspecial => 4,
		-distribute => 1,
	))=~s/[^:,.-\w]/-/;
	$password=~s/[^:,.-\w]/:/;
	$password=~s/[^:,.-\w]/,/;
	$password=~s/[^:,.-\w]/./;
	$password=join '',shuffle(split //,$password);
	print FILE "$password\n";
}
close FILE;
