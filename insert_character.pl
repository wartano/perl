#!perl -w
use strict;
use DBI;

my($sec,$min,$hour,$mday,$mon,$year)=localtime;
$year+=1900;
$mon+=1;
my$date=sprintf "%4d-%02d-%02d",$year,$mon,$mday;


my(@charinfo,@iteminfo,@searchdetail);
chdir "D:\\FTP\\Qn_query" or die "cannot change work directory:$!";
opendir DIR,"." or die "cannot open current directory:$!";
while(my$file=readdir DIR){
	if($file=~/(\d+q_Char.*)/){
		push@charinfo,$1;
	}elsif($file=~/(\d+q_Item.*)/){
		push@iteminfo,$1;
	}elsif($file=~/(\d+q_searchDetail.*)/){
		push@searchdetail,$1;
	}
}
closedir DIR;


my@code_list;
open FILE,"<","D:\\Apache Software Foundation\\Apache2.2\\cgi-bin\\code.txt" or die "cannot open file:$!";
while(<FILE>){
	chomp;
	push@code_list,$_;
}
close FILE;


my$dbh=DBI->connect("DBI:mysql:database=analysis;host=localhost;port=3306", "root", "123456");
my$sql=qq!INSERT INTO summary (ItemName,ItemNum,Date,AreaNum) VALUES (?,?,?,?)!;
my$sth=$dbh->prepare($sql);
for(@searchdetail){
	open SEARCH,"<","D:\\FTP\\Qn_query\\$_" or die "cannot open file:$!";
	while(<SEARCH>){
		chomp;
		$sth->execute(split);
	}
	close SEARCH;
}


for(@charinfo){
	my@detail;
	my$area=$1 if /(\d+q)/;
	open CHAR,"<","D:\\FTP\\Qn_query\\$_" or die "cannot open file:$!";
	while(<CHAR>){
		next if $.==1;
		chomp;
		push@detail,[(split/,/,$_),$date,$area];
	}
	close CHAR;
	for(@detail){
		$sql=qq!INSERT INTO charinfo (PTAccount,ActerName,Age,Sex,Guild,CreateDate,LastOnlineDate,HaoRan,TotalEnergy,MagicEnergy,NonMagicEnergy,FirstLayerMagic,SecondLayerAttackMagic,SecondLayerOtherMagic,ZhangFeng,ZhenQi,Date,AreaNum) VALUES ("$_->[0]","\Q$_->[1]\E","$_->[2]","$_->[3]","$_->[4]","$_->[5]","$_->[6]","$_->[7]","$_->[8]","$_->[9]","$_->[10]","$_->[11]","$_->[12]","$_->[13]","$_->[14]","$_->[15]","$_->[16]","$_->[17]")!;
		$sth=$dbh->prepare($sql);	
		$sth->execute();
	}
}



my$sentence=join ",",@code_list;
my$count=scalar@code_list+3;
my$part="?".(",?" x $count);
$sql=qq!INSERT INTO iteminfo (PTAccount,ActerName,$sentence,Date,AreaNum) VALUES ($part)!;
$sth=$dbh->prepare($sql);	
for(@iteminfo){
	my$area=$1 if /(\d+q)/;
	open ITEM,"<","D:\\FTP\\Qn_query\\$_" or die "cannot open file:$!";
	while(<ITEM>){
		next if $.==1;
		chomp;
		$sth->execute((split /,/,$_),$date,$area);
	}
	close ITEM;
}
$dbh->disconnect;
