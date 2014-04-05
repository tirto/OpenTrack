#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use 5.004;

# Projects: Job Tracking System
# File:     main.pl
# By:       Phuoc Diec
# Date:     May 28, 1999

# Description:
# This file will display a welcome message when a user first login. If
# a menu choice is made and passed via cgi post, it can list all requests
# that have been assigned to the user or everybody depending on the users
# request. What the program does depends of the contents of the parameters
# 'request' and 'who' which are enumerated on the table below:

#   REQUEST    WHO    SUBROUTINE EXECUTED

#   active     user   RequestUserActive
#   active     all    RequestAllActive
#  finished    user   RequestUserFinished
#  finished    user   RequestAllFinished
#   <none>    <none>  WelcomeUser

# Successful request are displayed in tabular form.
# If no requests found, An error message is displayed instead.

# ChangeLog:
# 06/06/2000 Prasanth Kumar
# - Change passed parameters to 'request' and 'who' instead of
#   arbitrary constants.
# - Start breaking up program into separate subroutines to be executed
#   instead of one long if statement.
# - Read DB username/password from files for added security.
# 06/07/2000 Prasanth Kumar
# - Remove redundant SJSU logo from header and move
#   "Job Tracking System" title to menu window.
# - Sort 'all' request by responder then requester ascending.
# - Change column arrangment in PrintAllTable() to match sorting
#   precedence.
# 06/08/2000 Prasanth Kumar
# - Both PrintUserTable() and PrintAllTable() call the changeStatus.pl
#   script for job details.
# 06/09/2000 Prasanth Kumar
# - Changed some table headers.
# - Added count of query results to output.
# 06/16/2000 Prasanth Kumar
# - Start quoting all html parameters to remove warnings.

########## SET UP A PATH TO DATABASE FOR ENVIRONMENT VARIABLES ##########
BEGIN
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

########## GET USERID FROM ENVIRONMENT VARIABLE ##########
$userID = $ENV{REMOTE_USER};

########## PRINT HEADER AND START FORMATTING HTML ##########
print header(-expires=>'now'),
    start_html(-title=>"Job Tracking Display", -bgcolor=>"#ffffff");

########## PROCESS REQUEST ##########

# Get database login and password from file so they are
# not visible in the perl script and easier to maintain.
open(FILE, "/home/httpd/.jobDBAccess") or die "no password file .jobDBAccess";
chop($DBlogin = <FILE>);
chop($DBpassword = <FILE>);

# Open connection to database
$dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword,
		    {PrintError=>1, RaiseError=>1}) or die "connecting : $DBI::errstr";

# Get value of parameters passed in from browser
if (param()) {
    
    my $request = param("request");
    my $who = param("who");

    # Determine which subroutine to execute based of passed parameters
    if ($who eq 'user' && $request eq 'active') {
	RequestUserActive($userID, $dbh);
    } elsif ($who eq 'all' && $request eq 'active') {
	RequestAllActive($dbh);
    } elsif ($who eq 'user' && $request eq 'finished') {
	RequestUserFinished($userID, $dbh);
    } elsif ($who eq 'all' && $request eq 'finished') {
	RequestAllFinished($dbh);
    } else {
	InvalidParameters();
    }
} else {
    WelcomeUser($userID);
}

$dbh->disconnect;

print end_html;

########## END OF MAIN ##########

########## WELCOME THE USER ###########
sub WelcomeUser {
# Purpose: prints a welcome message to the user.
# Input: userID
# Output: none

    my $userID = shift(@_);

    print '<HR>', h1({-align=>'center'}, "Welcome $userID"), '<HR>';

} # End WelcomeUser

##########  INVALID PARAMETERS ###########
sub InvalidParameters {
# Purpose: prints a error message to the user.
# Input: none
# Output: none

    print '<HR>', h1({-align=>'center'}, "An invalid choice was made!"), '<HR>';

} # End WelcomeUser

########## RETRIEVE USER ACTIVE REQUESTS #########
sub RequestUserActive {
# Purpose: requests all of the users active jobs in the database
#   and outputs it in table form.
# Input: userID, database handle
# Output: none
    
    my ($userID, $dbh) = @_;

    # select only user active entries in the database
    $sth = $dbh->prepare(qq{SELECT
				TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS'),
				TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
				title,
				TO_CHAR(datereceived, 'MM-DD-YYYY'),
				clientname, priority
				    FROM jobManage
					WHERE status ='Active'
					    AND personassigned = '$userID'
					    ORDER by datereceived DESC}); 
    $sth->execute or die "executing: $sth->errstr";

    PrintUserTable($sth, "$userID\'s Active Requests");

} # End RequestuserActive

########## RETRIEVE USERS FINISHED REQUESTS #########
sub RequestUserFinished {
# Purpose: requests all of the users finished jobs in the database
#   and outputs it in table form.
# Input: userID, database handle
# Output: none

    my ($userID, $dbh) = @_;

    # select only user finished entries in the database
    $sth = $dbh->prepare(qq{SELECT
				TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS'),
				TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
				title,
				TO_CHAR(datereceived, 'MM-DD-YYYY'),
				clientname, priority
				    FROM jobManage
					WHERE status ='Finished'
					    AND personassigned = '$userID'
						ORDER by datereceived DESC}); 
    $sth->execute or die "executing: $sth->errstr";

    PrintUserTable($sth,"$userID\'s Finished Requests");
    
} # End RequestUserFinished

########## RETRIEVE ALL ACTIVE REQUESTS ##########
sub RequestAllActive {
# Purpose: requests all active jobs in the database
#   and outputs it in table form.
# Input: database handle
# Output: none

    my $dbh = shift(@_);

    # select all active entries in the database
    $sth = $dbh->prepare(qq{SELECT
				TO_CHAR(datereceived,'MM-DD-YYYY-HH24-MI-SS'),
				priority,
				TO_CHAR(datereceived,'MMDDYYYYHH24MISS'),
				personassigned, clientname, title
				    FROM jobManage
					WHERE status = 'Active'
					    ORDER by personassigned ASC,
					    clientname ASC});
    $sth->execute or die "executing: $sth->errstr";

    PrintAllTable($sth, "All Active Requests");

} # End RequestAllFinished  

########## RETRIEVE ALL FINISHED REQUESTS ##########
sub RequestAllFinished {
# Purpose: requests all of the finished jobs in the database
#   and outputs it in table form.
# Input: database handle
# Output: none

    my $dbh = shift(@_);

    # select all finished entries in the database
    $sth = $dbh->prepare(qq{SELECT
				TO_CHAR(datereceived,'MM-DD-YYYY-HH24-MI-SS'),
				priority,
				TO_CHAR(datereceived,'MMDDYYYYHH24MISS'),
				personassigned, clientname, title
				    FROM jobManage
					WHERE status = 'Finished'
					    ORDER by personassigned ASC,
					    clientname ASC});
    $sth->execute or die "executing: $sth->errstr";

    PrintAllTable($sth, "All Finished Requests");

} # End RequestAllFinished  

######### PRINT USER TABLE ##########
sub PrintUserTable {
# Purpose: prints a table with data from a query passed in.
#   query row must be in specific order for it to make sense.
# Input: select handle, table title
# Output: none

    my $sth = shift(@_);
    my $tableTitle = shift(@_);

    # Fetch queried rows all at once so we can count them.
    my $ary_ref = $sth->fetchall_arrayref;
    my $numOfItems = $#{$ary_ref}+1;

    print h3({-align=>'center'}, $tableTitle);
    print h4({-align=>'center'}, "Entries found: $numOfItems");
    
    print '<table border=0 align=center cellspacing=4 cellpadding=4 bgcolor="#ffffff">',
    Tr({-bgcolor=>"#aaccff", -align=>'center'}, td("Request ID"),
       td("Title of Request"), td("Request Date"), td("Requester"), td("Priority"));

    for ($i = 0; $i < $numOfItems; $i++) {

	# Copy a particular row from the query reference array
	# into a row array
	$tmp_row = $ary_ref->[$i];
	@row = ();
	for $j (0..$#{$tmp_row}) {
	    $row[$j] = $tmp_row->[$j];
	}

	# Substitute spaces of strings with char '+', %20, for passing to cgi
	$tmpClient = $row[4];
	$tmpClient =~ s/\s/%20/g;
	
	# This *assumes* a particular row ordering for the passed in
	# database query. Format each request for displaying on the table 
	# 'date' and 'name' are passed to changeStatus since they are needed
	# for changeStatus to get the right requests to display
	print Tr(td(a({-href=>"changeStatus.pl?date=$row[0]&name=$tmpClient"},
		      "$row[1]")), td("$row[2]"),td("$row[3]"),td("$row[4]"),td("$row[5]"));
    }
    
    # If no request has been listed, display no request found
    if ($numOfItems == 0) {
	print Tr({-bgcolor=>"#ffffff"}, td("No request found"));
    }
    
    print '</table>';
    
} # End PrintUserTable

########## PRINT ALL TABLE ##########
sub PrintAllTable {
# Purpose: prints a table with data from a query passed in.
#   query row must be in specific order for it to make sense.
# Input: select handle, table title
# Output: none

    my $sth = shift(@_);
    my $tableTitle = shift(@_);

    # Fetch queried rows all at once so we can count them.
    my $ary_ref = $sth->fetchall_arrayref;
    my $numOfItems = $#{$ary_ref}+1;

    print h3({-align=>'center'}, $tableTitle);
    print h4({-align=>'center'}, "Entries found: $numOfItems");
    
    print '<table border=0 align=center cellspacing=4 cellpadding=4>';
    print Tr({-bgcolor=>"#aaccff", -align=>'center'}, td("Request ID"),
	     td("Responder"), td("Requester"), td("Title of Request"));

    for ($i = 0; $i < $numOfItems; $i++) {

	# Copy a particular row from the query reference array
	# into a row array
	$tmp_row = $ary_ref->[$i];
	@row = ();
	for $j (0..$#{$tmp_row}) {
	    $row[$j] = $tmp_row->[$j];
	}

        # Substituting spaces with %20 for cgi
	$tmpClient = $row[4];
	$tmpClient =~ s/\s/%20/g;

	# This *assumes* a particular row ordering for the passed in
	# database query. Format each request for displaying on the table 
	# 'date' and 'name' are passed to changeStatus since they are needed
	# for changeStatus to get the right requests to display
	print Tr(td(a({-href=>"changeStatus.pl?date=$row[0]&name=$tmpClient"},
		      "$row[2]")), td("$row[3]"),td("$row[4]"),td("$row[5]"));
    }

    # If no request has been listed, display no request found
    if ($numOfItems == 0) {
	print Tr({-bgcolor=>"#ffffff"}, td("No request found!"));
    }

    print '</table>';
} # End PrintAllTable
