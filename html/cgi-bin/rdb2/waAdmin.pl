#!/usr/bin/perl

require 5.004;
use strict;

use CGI;
use CGI::Carp qw/fatalsToBrowser/;
use DBI;

my $query = new CGI;

{
	if ($query->request_method eq 'GET')
	{
		&doGet();
	}
}

sub doGet
{
	#Validating request:
	#-------------------
	# 1. If svyId == NEW then create a new survey
	# 2. else must have a svyId to display information for.

		showAdmin();
}

#Display the Survey specific section of this page

sub showAdmin
{
	my(@name, $nm, $val);
	my(@name_key, $name_value);
	my(%sub_list);
	my($userfile, $adminfile, $td);
	my($correct_ans, $wrong_ans);
	my($sql, $case, $nmCrsr, $wrong_ans, $correct_ans, $printquest);
	my($ansText, $ansId, $ansVal, $qstText, $qstRef, $qstAns, $qstCat);
	my($wrong_cnt, $correct_cnt);
	my($query_val, $line);

	$adminfile = "data/admin_file";

	open(aFile, "$adminfile");	# Open for reading


    print $query->header;

    print $query->start_html("Admin Report");
   print "<BODY BACKGROUND='/rdb2/img/lightgrey.gif'>";

	print "<br><h2><center>Student Assessment Score Report</h2>";

	while($line = <aFile>)
	{
		print $line;
	}
	
	print "</BODY></html>";
}
