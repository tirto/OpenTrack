#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3 *table *center/;
use FindBin qw($Bin);
use lib "$Bin/../Common";
use misclib;
use datelib;
use 5.004;

# Project: Job Tracking System
# File:    chargeSummary.pl
# By:      Prasanth Kumar
# Date:    Dec 06, 1999

# Description:
# Handles query of charges for a period of time
# catagorized by department charged to.

# ChangeLog:
# 12/06/2000 Prasanth Kumar
# - start file
# 12/12/2000 Prasanth Kumar
# - added various date validation functions
# 12/13/2000 Prasanth kumar
# - validated date stored back into param fields
# - factor out date code into datelib module

BEGIN
{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

########## PRINT HEADER AND START TO FORMATING HTML ##########
print header(-expires=>'+10s'),
    start_html(-title=>"Job Tracking Display", -bgcolor=>"#ffffff"), "\n";

########## PROCESS REQUESTS ##########
$choices = { 1=>'<Custom>', 2=>'Current month', 3=>'Previous month',
	     4=>'Current year', 5=>'Previous year' };

# get id of authenticated user
my $userID = remote_user();

# open connection to database
my $dbh = open_database("/home/httpd/.jobDBAccess");

if (param()) {
    if (param('method') == 1) {
	# custom entry
	# validate start date
	my ($tmp_month, $tmp_day, $tmp_year) =
	    valid_date(param('start_month'),
		       param('start_day'),
		       param('start_year'));
	param('start_month', $tmp_month);
	param('start_day', $tmp_day);
	param('start_year', $tmp_year);

	# validate end date
	($tmp_month, $tmp_day, $tmp_year) =
	    valid_date(param('end_month'),
		       param('end_day'),
		       param('end_year'));
	param('end_month', $tmp_month);
	param('end_day', $tmp_day);
	param('end_year', $tmp_year);  
    } elsif (param('method') == 2) {
	# this month
	param('start_day', 1);
	param('start_month', this_month());
	param('start_year', this_year());
	param('end_day', 31);
	param('end_month', this_month());
	param('end_year', this_year());
    } elsif (param('method') == 3) {
	# previous month
	param('start_day', 1);
	if (this_month() > 1) {
	    param('start_month', this_month() - 1);
	    param('end_month', this_month() - 1);
	    param('end_day', last_day(this_month() - 1, this_year()));
	    param('start_year', this_year());
	    param('end_year', this_year());
	} else {
	    # january rolls back to december
	    param('start_month', 12);
	    param('end_month', 12);
	    param('end_day', last_day(12, this_year() - 1));
	    param('start_year', this_year() - 1);
	    param('end_year', this_year() - 1);
	}
    } elsif (param('method') == 4) {
	# this year
	param('start_day', 1);
	param('start_month', 1);
	param('start_year', this_year());
	param('end_day', last_day(12, this_year()));
	param('end_month', 12);
	param('end_year', this_year());
    } elsif (param('method') == 5) {
	# last year
	param('start_day', 1);
	param('start_month', 1);
	param('start_year', this_year() - 1);
	param('end_day', last_day(12, this_year()));
	param('end_month', 12);
	param('end_year', this_year() - 1);
    }
}

# display the summary of charges
display_charges($dbh);    

$dbh->disconnect;
print end_html;
exit 0;

########## END OF MAIN ##########

########## DISPLAY THE CHARGES BY DEPARTMENT ##########
sub display_charges($) {
# Purpose: prints out a charge summary
# Input: database handle. parameters passed in
#   globally are start_month, start_day, start_year,
#   end_month, end_day, end_year
# Output: none
    
    my ($dbh) = @_;
    my ($sth, @row);
    
    # print the form asking for start date and end date
    print start_form({-action=>"/cgi-bin/prasanth/chargeSummary.pl"});
    print h3({-align=>'center'}, "Charge Summary"), "\n";
    
    print start_table({-border=>0, -align=>'center',
		       -cellpadding=>0}),"\n",
    Tr(td('Query Dates'),
       td(popup_menu(-name=>'method',
		     -default=>1,
		     -labels=>$choices,
		     -values=>[ sort { $a <=> $b }
				keys %$choices ]),
	  submit(-name=>'Query'))),"\n",
    Tr(td('Start Date'),
       td(popup_menu(-name=>'start_month',
		     -labels=>$the_months,
		     -values=>[ sort { $a <=> $b } keys %{$the_months} ],
		     -default=>1),
	  popup_menu(-name=>'start_day',
		     -values=>$the_days,
		     -default=>1),
	  popup_menu(-name=>'start_year',
		     -values=>$the_years,
		     -default=>this_year()))), "\n",
    Tr(td('End Date'),
       td(popup_menu(-name=>'end_month',
		     -labels=>$the_months,
		     -values=>[ sort { $a <=> $b } keys %{$the_months} ],
		     -default=>12),
	  popup_menu(-name=>'end_day',
		     -values=>$the_days,
		     -default=>31),
	  popup_menu(-name=>'end_year',
		     -values=>$the_years,
		     -default=>this_year()))), "\n";
    print end_table, end_form, "\n";

    # if query is pending then search charges database
    # base of start and end date parameters
    if (param('Query')) {
	$sth = $dbh->prepare(qq{
	    SELECT d.description, count(c.amount), sum(c.amount)
		FROM staffdept d, charges c
		    WHERE d.id = c.department
			AND c.order_date >= TO_DATE(?, 'MM-DD-YYYY')
			    AND c.order_date <= TO_DATE(?, 'MM-DD-YYYY')
				GROUP BY d.description
				    ORDER BY d.description});
	
	eval { $sth->execute(date_string(param('start_month'),
					 param('start_day'),
					 param('start_year')),
			     date_string(param('end_month'),
					 param('end_day'),
					 param('end_year'))) };

	if ($@) {
	    print h4({-align=>'center'}, "Error during query!"), "\n";
	} else {
	    my ($num_charges, $total_charges) = (0, 0);

	    print start_table({-border=>1, -align=>'center',
			       -bgcolor=>'#ffffff',
			       -cellpadding=>5,
			       -cellspacing=>1}), "\n";
	    print Tr({-bgcolor=>"#cceeff", -align=>'center'},
		     td("Department"), td("Number of Charges"),
		     td("Total Charges")), "\n";

  	    while (@row = $sth->fetchrow_array) {
  		$row[2]=0.0 unless defined $row[2];
  		print Tr(td($row[0]),
			 td({-align=>'center'}, $row[1]),
			 td(format_dollars($row[2]))), "\n";
		$num_charges = $num_charges + $row[1];
		$total_charges = $total_charges + $row[2];
  	    }

	    if ($sth->rows == 0) {
		print Tr(td({-align=>'center', -colspan=>3},
			    "No charges found for that time period.")), "\n";
	    } else {
		print Tr(td(b('All Departments')),
			 td({-align=>'center'}, b($num_charges)),
			 td(b(format_dollars($total_charges)))), "\n";
	    }
	}
	print end_table, "\n";
	$sth->finish;
    }
} # End JobDisplay
