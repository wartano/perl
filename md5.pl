#!perl -w
use strict;
use File::Find;
use Digest::MD5;
my%md5;
my@directories=qw/./;
find(\&wanted,@directories);
sub wanted{
	if(-f and $_ ne 'modify_xml.exe' and $_ ne'file_md5.txt'){
		open FILE,"<",$_ or die "Can't open '$_':$!";
		binmode(FILE);
		$File::Find::name=~s/^\.\///;
		#$File::Find::name=~s/\//\\/g;
		$md5{$File::Find::name}=[Digest::MD5->new->addfile(*FILE)->hexdigest,$_];
		close FILE;
	}
}
open FILE,">","file_md5.txt";
for(keys%md5){
	print FILE qq[			<updata filename="$md5{$_}->[1]" md5="$md5{$_}->[0]">$_</updata>\n];
}
close FILE;
