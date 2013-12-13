#!perl -w
use strict;
use Mail::Sender;
use Archive::Zip qw(:ERROR_CODES :CONSTANTS);
chdir "d:\\FTP\\weekly_task\\" or die "cannot change work directory:$!\n";
my($sec,$min,$hour,$mday,$mon,$year)=localtime;
$year+=1900;
$mon+=1;
my$file_name=sprintf "%4d%02d%02d.zip",$year,$mon,$mday;
my$zip=Archive::Zip->new();
$zip->addTree("d:\\FTP\\weekly_task",undef);
$zip->writeToFileNamed("d:\\FTP\\weekly_task\\$file_name");
my$sender=new Mail::Sender
	{smtp=>'xxx',from=>'xxx@xxx'};
$sender->MailFile({to=>'xxx@xxx',
	subject=>'tasks',
	msg=>"weekly task",
	file=>"$file_name"});
$sender->Close();
unlink <d:\\FTP\\weekly_task\\*>;
