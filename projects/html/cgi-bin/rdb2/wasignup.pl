#!/usr/bin/perl

require 5.004;
use strict;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;

my $query = new CGI;

{
	if ($query->request_method eq 'GET')
	{
		&doGet();
	}
	else
	{
		&doPost();
	}
}

sub doGet
{
	#Validating request:
	my $fname = $query->param("first_name");
    my $lname = $query->param("last_name");
    my $ssn = $query->param("ssn");

	print $query->header;
	print "<html>";

	if ($fname eq '' or $lname eq '' or $ssn eq '')
	{
		print "<BODY BACKGROUND='/rdb2/img/lightgrey.gif'>";
		print "<P><br><h3>Please fill in the following fields correcly</h3><P>";
		print "<form action='/cgi-bin/rdb2/wasignup.pl' METHOD=get>";
		print "<P>Last Name: <input TYPE='text' NAME='last_name' VALUE='$lname' SIZE='18' MAXLENGTH=32></P>";
		print "<P>First Name: <input TYPE='text' NAME='first_name' VALUE='$fname' SIZE='18' MAXLENGTH=32></P>";
		print "<P>&nbsp;</P>";
		print "<P>Social Security Number: <input TYPE='text' NAME='ssn' VALUE='$ssn' SIZE='18' MAXLENGTH=32></P>";
		print "<P>Please click on Start when you are ready: <input TYPE='submit' NAME='start' value='Start'></P> </form></BODY>";
	}
	else
	{
		print "<frameset cols='100,*' frameborder='yes'>\n";
		print "<frame name='toolBar'  src='/rdb2//img/bar.html' marginheight='0' marginwidth='0' frameborder=yes>";
		print "<frame name='workArea' src='/cgi-bin/rdb2/waAssess.pl?last_name=$lname&first_name=$fname&ssn=$ssn' marginheight='4' marginwidth='4' frameborder='yes'>\n";
		print "</frameset>\n";
		print "<noframes> <p>This product requires frames</p></noframes>\n";

	#	print "Location: /cgi-bin/waAssess.pl\n\n";
	}

	print $query->end_html;
}
