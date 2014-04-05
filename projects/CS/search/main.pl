#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3 *table/;
use FindBin qw($Bin);
use lib "$Bin/../Common";
use misclib;
use 5.004;

# Projects: Job Tracking System
# File:     main.pl
# By:       Phuoc Diec
# Date:     May 28, 1999

# Description:
# This file will display a welcome message when a user first login.
# If a menu choice is made and passed via cgi post, it can list all
# requests that have been assigned to the user or everybody depending
# on the users request. What the program does depends of the contents
# of the parameters 'request' and 'who' which are enumerated on the
# table below:

#   REQUEST    WHO    SUBROUTINE EXECUTED

#   active     user   request_user_active
#   active     all    request_all_active
#  finished    user   request_user_finished
#  finished    user   request_all_finished
#   <none>    <none>  welcome_user

# Successful request are displayed in tabular form.
# If no requests found, An error message is displayed instead.

# ChangeLog:
# 06/06/2000 Prasanth Kumar
# - Change passed parameters to 'request' and 'who' instead of
#   arbitrary constants.
# - Start breaking up program into separate subroutines to be
#   executed instead of one long if statement.
# - Read DB username/password from files for added security.
# 06/07/2000 Prasanth Kumar
# - Remove redundant SJSU logo from header and move
#   "Job Tracking System" title to menu window.
# - Sort 'all' request by responder then requester ascending.
# - Change column arrangment in print_all_table() to match
#   sorting precedence.
# 06/08/2000 Prasanth Kumar
# - Both print_user_table() and print_all_table() call the
#   changeStatus.pl script for job details.
# 06/09/2000 Prasanth Kumar
# - Changed some table headers.
# - Added count of query results to output.
# 06/16/2000 Prasanth Kumar
# - Start quoting all html parameters to remove warnings.
# 06/29/2000 Prasanth Kumar
# - Start using ../Common/misclib.pm
# 08/09/2000 Prasanth Kumar
# - Change sorting order of RequestAll* queries to do by
#   personassigned then datereceived.
# 08/11/2000 Prasanth Kumar
# - Change some table tag strings to use CGI functions instead.
# - Use new encode_url function from misclib.
# - Add newlines to make html code look nicer.
# 08/14/2000 Prasanth Kumar
# - Fix prepare statements to not interpolate parameters.
# 09/13/2000 Prasanth Kumar
# - Determine login id using remote_user() function.
# 12/05/2000 Prasanth Kumar
# - Add keyword search function RequestAllKeyword.
# 12/21/2000 Prasanth Kumar
# - Add arbitrary sorting capability to table output.
#   ie. form_url() and valid_order() functions.
# 12/22/2000 Prasanth Kumar
# - Print out number of active entries on welcome screen.
# - Clean up source code

########## SET UP A PATH TO DATABASE FOR ENVIRONMENT VARIABLES ##########
BEGIN
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

########## PRINT HEADER AND START FORMATTING HTML ##########
print header(-expires=>'+10s'),
    start_html(-title=>"Job Tracking Display", -bgcolor=>"#ffffff");

########## PROCESS REQUEST ##########

# open connection to database
my $dbh = open_database("/home/httpd/.jobDBAccess");

# get id of authenticated user
my $user_id = remote_user();

# get value of parameters passed in from browser
if (param()) {
    
    my $request = param("request");
    my $who = param("who");
    my $search = param("search");

    # determine which subroutine to execute based of passed parameters
    if ($who eq 'user' && $request eq 'active') {
	request_user_active($user_id, $dbh);
    } elsif ($who eq 'all' && $request eq 'active') {
	request_all_active($dbh);
    } elsif ($who eq 'user' && $request eq 'finished') {
	request_user_finished($user_id, $dbh);
    } elsif ($who eq 'all' && $request eq 'finished') {
	request_all_finished($dbh);
    } elsif ($who eq 'all' && $request eq 'keyword') {
	request_all_keyword($dbh, $search);
    } else {
	invalid_parameters();
    }
} else {
    welcome_user($user_id, $dbh);
}

$dbh->disconnect;

print end_html;
exit 0;

########## WELCOME THE USER ###########
sub welcome_user($$) {
# Purpose: prints a welcome message to the user.
# Input: user id and database handle
# Output: none

    my ($user_id, $dbh) = @_;
    my ($sth, $ary_ref, $num_items);
    
    print hr, h1({-align=>'center'}, "Welcome $user_id"), hr, "\n";

    # count user active entries in the database
    $sth = $dbh->prepare(qq{
	SELECT datereceived
	    FROM jobManage
		WHERE status ='Active'
		    AND personassigned = ?}); 
    $sth->execute($user_id) or die "executing: $sth->errstr";

    $ary_ref = $sth->fetchall_arrayref;
    $num_items = $#{$ary_ref}+1;

    print h4({-align=>'center'},
	     "You have $num_items active request(s)."), "\n";

    $sth->finish;
}   

##########  INVALID PARAMETERS ###########
sub invalid_parameters {
# Purpose: prints a error message to the user.
# Input: none
# Output: none

    print hr, h1({-align=>'center'},
		     "An invalid choice was made!"), hr, "\n";
}

##########  CONSTRUCT FORM URL ###########
sub form_url($) {
# Purpose: returns a url with the current form
#   parameters and also append the order field
#   parameter to it.
# Input: value of order field
# Output: url string

    my ($value) = @_;
    my ($old_value, $url);
    
    if ($old_value = param("order")) {
	param("order", $value);
	$url = self_url;
	param("order", $old_value);
    } else {
	param("order", $value);
	$url = self_url;
	Delete("order");
    }

    return $url;
}

##########  INVALID PARAMETERS ###########
sub valid_order($$) {
# Purpose: determines if the parameter value passed
#   in is a valid ordering sequence and passes back the 
#   sql select ordering components to achieve this. Also
#   accepts a default parameter value if the one passed
#   in is not valid
# Input: order field value and default order value
# Output: reference to array of ordering components of
#   the form (orderfield1, orderdir1, orderfield2, orderdir2)

    my ($field, $default) = @_;

    # orderfield1, orderdir1, orderfield2, orderdir2
    my %fieldlist = ( datereceived => [ "datereceived", "DESC",
					"clientname", "ASC" ],
		      responder => [ "personassigned", "ASC",
				     "datereceived", "DESC" ],
		      title => [ "title", "ASC",
				 "datereceived", "DESC" ],
		      requester => [ "clientname", "ASC",
				     "datereceived", "DESC" ],
		      priority => [ "priority", "ASC",
				    "datereceived", "DESC" ]);
    
    if (defined $field and defined $fieldlist{$field}) {
	return $fieldlist{$field};
    } elsif (defined $fieldlist{$default}) {
	return $fieldlist{$default};
    }
    
    return $fieldlist{"datereceived"};
}

########## RETRIEVE USER ACTIVE REQUESTS #########
sub request_user_active($) {
# Purpose: requests all of the users active jobs in the database
#   and outputs it in table form.
# Input: user id, database handle
# Output: none
    
    my ($user_id, $dbh) = @_;
    my $o_ref;

    # determine sorting order of query
    $o_ref = valid_order(param('order'), 'daterecieved');

    # select only user active entries in the database
    $sth = $dbh->prepare(qq{
	SELECT TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS'),
	TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
	title, TO_CHAR(datereceived, 'MM-DD-YYYY'),
	clientname, priority
	    FROM jobManage
		WHERE status ='Active'
		    AND personassigned = ?
			ORDER BY $o_ref->[0] $o_ref->[1],
			$o_ref->[2] $o_ref->[3]}); 
    $sth->execute($user_id) or die "executing: $sth->errstr";

    print_user_table($sth, "$user_id\'s Active Requests");
}

########## RETRIEVE USERS FINISHED REQUESTS #########
sub request_user_finished($) {
# Purpose: requests all of the users finished jobs in the database
#   and outputs it in table form.
# Input: user id, database handle
# Output: none

    my ($user_id, $dbh) = @_;
    my $o_ref;

    # determine sorting order of query
    $o_ref = valid_order(param('order'), 'daterecieved');

    # select only user finished entries in the database
    $sth = $dbh->prepare(qq{
	SELECT TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS'),
	TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
	title, TO_CHAR(datereceived, 'MM-DD-YYYY'),
	clientname, priority
	    FROM jobManage
		WHERE status ='Finished'
		    AND personassigned = ?
			ORDER BY $o_ref->[0] $o_ref->[1],
			$o_ref->[2] $o_ref->[3]}); 
    $sth->execute($user_id) or die "executing: $sth->errstr";

    print_user_table($sth,"$user_id\'s Finished Requests");
}

########## RETRIEVE ALL ACTIVE REQUESTS ##########
sub request_all_active($) {
# Purpose: requests all active jobs in the database
#   and outputs it in table form.
# Input: database handle
# Output: none

    my ($dbh) = @_;
    my $o_ref;

    # determine sorting order of query
    $o_ref = valid_order(param('order'), 'responder');

    # select all active entries in the database
    $sth = $dbh->prepare(qq{
	SELECT TO_CHAR(datereceived,'MM-DD-YYYY-HH24-MI-SS'),
	priority, TO_CHAR(datereceived,'MMDDYYYYHH24MISS'),
	personassigned, clientname, title
	    FROM jobManage
		WHERE status = 'Active'
		    ORDER BY $o_ref->[0] $o_ref->[1],
		    $o_ref->[2] $o_ref->[3]}); 
    $sth->execute or die "executing: $sth->errstr";

    print_all_table($sth, "All Active Requests");
}

########## RETRIEVE ALL FINISHED REQUESTS ##########
sub request_all_finished($) {
# Purpose: requests all of the finished jobs in the database
#   and outputs it in table form.
# Input: database handle
# Output: none

    my ($dbh) = @_;
    my $o_ref;

    # determine sorting order of query
    $o_ref = valid_order(param('order'), 'responder');

    # select all finished entries in the database
    $sth = $dbh->prepare(qq{
	SELECT TO_CHAR(datereceived,'MM-DD-YYYY-HH24-MI-SS'),
	priority, TO_CHAR(datereceived,'MMDDYYYYHH24MISS'),
	personassigned, clientname, title
	    FROM jobManage
		WHERE status = 'Finished'
		    ORDER BY $o_ref->[0] $o_ref->[1],
		    $o_ref->[2] $o_ref->[3]}); 
    $sth->execute or die "executing: $sth->errstr";

    print_all_table($sth, "All Finished Requests");
}

########## KEYWORD SEARCH ##########
sub request_all_keyword($$) {
# Purpose: find all jobs with matching keywords
#   in their title, comments or resolution field
#   and outputs it in table form.
# Input: database handle and search values
# Output: none

    my ($dbh, $search) = @_;
    my ($keywords, $o_ref);

    # determine sorting order of query
    $o_ref = valid_order(param('order'), 'responder');

    print start_form();
    print h3({-align=>'center'}, "Keyword Search"), "\n";

    print hidden(-name=>"request", -default=>'keyword'), "\n";
    print hidden(-name=>"who", -default=>'all'), "\n";

    print start_table({-border=>0, -align=>'center',
		       -cellpadding=>0}), "\n";
    print Tr(td(textfield(-name=>'search', -size=>32,
			  -default=>$search, -maxlength=>32)),
	     td(submit(-name=>'Search'))), "\n";
    print end_table, end_form, "\n";

    if ($search) {
	# break down search string into wildcard keywords
	$keywords = uc $search;
	$keywords =~ tr/ /%/s;
	$keywords = "%" . $keywords . "%"; 
    
	# select all finished entries in the database
	$sth = $dbh->prepare(qq{
	    SELECT TO_CHAR(datereceived,'MM-DD-YYYY-HH24-MI-SS'),
	    priority, TO_CHAR(datereceived,'MMDDYYYYHH24MISS'),
	    personassigned, clientname, title
		FROM jobManage
		    WHERE upper(title) LIKE ?
			OR upper(comments) LIKE ?
			    OR upper(resolution) LIKE ?
				ORDER BY $o_ref->[0] $o_ref->[1],
				$o_ref->[2] $o_ref->[3]}); 
	$sth->execute($keywords, $keywords, $keywords)
	    or die "executing: $sth->errstr";
	
	print_all_table($sth);
    }
}

######### PRINT USER TABLE ##########
sub print_user_table($;$) {
# Purpose: prints a table with data from a query passed in.
#   query row must be in specific order for it to make sense.
# Input: select handle, table title
# Output: none

    my ($sth, $title) = @_;
    my ($ary_ref, $num_items, @row, $tmp_row);

    # fetch queried rows all at once so we can count them.
    $ary_ref = $sth->fetchall_arrayref;
    $num_items = @$ary_ref;
    
    print h3({-align=>'center'}, $title), "\n";
    print h4({-align=>'center'}, "Entries found: $num_items"), "\n";
    
    print start_table({-border=>'1', -align=>'center', -bgcolor=>'#ffffff',
		       -cellpadding=>'5', -cellspacing=>'0'}), "\n";

    print Tr({-bgcolor=>"#cceeff", -align=>'center'}, "\n",
	     td(a({-href=>form_url("datereceived")}, "Request ID")), "\n",
	     td(a({-href=>form_url("title")}, "Title of Request")), "\n",
	     td(a({-href=>form_url("datereceived")}, "Request Date")), "\n",
	     td(a({-href=>form_url("requester")}, "Requester")), "\n",
	     td(a({-href=>form_url("priority")}, "Priority"))), "\n";

    for ($i = 0; $i < $num_items; $i++) {

	# copy a particular row from the query reference array
	# into a row array
	$tmp_row = $ary_ref->[$i];
	@row = ();
	for $j (0..$#{$tmp_row}) {
	    $row[$j] = $tmp_row->[$j];
	}

	print Tr(td(a({-href=>encode_url('changeStatus.pl',
					 date=>$row[0],
					 name=>$row[4])}, "$row[1]")),
		 td("$row[2]"),td("$row[3]"),td("$row[4]"), td("$row[5]"));
	print "\n";
    }
    
    # if no request has been listed, display no request found
    if ($num_items == 0) {
	print Tr({-bgcolor=>"#ffffff", -align=>'center'},
		 td({-colspan=>4}, "No request found!"));
    }
    
    print end_table(), "\n";
}

########## PRINT ALL TABLE ##########
sub print_all_table($;$) {
# Purpose: prints a table with data from a query passed in.
#   query row must be in specific order for it to make sense.
# Input: select handle, table title
# Output: none

    my ($sth, $title) = @_;
    my ($ary_ref, $num_items, @row, $tmp_row);
    
    # fetch queried rows all at once so we can count them.
    $ary_ref = $sth->fetchall_arrayref;
    $num_items = @$ary_ref;

    if (defined $title) {
	print h3({-align=>'center'}, $title), "\n";
    }
    print h4({-align=>'center'}, "Entries found: $num_items"), "\n";

    print start_table({-border=>'1', -align=>'center', -bgcolor=>'#ffffff',
		       -cellpadding=>'5', -cellspacing=>'0'}), "\n";

    print Tr({-bgcolor=>"#cceeff", -align=>'center'}, "\n",
	     td(a({-href=>form_url("datereceived")}, "Request ID")), "\n",
	     td(a({-href=>form_url("responder")}, "Responder")), "\n",
	     td(a({-href=>form_url("requester")}, "Requester")), "\n",
	     td(a({-href=>form_url("title")}, "Title of Request"))), "\n";

    for ($i = 0; $i < $num_items; $i++) {

	# copy a particular row from the query reference array
	# into a row array
	$tmp_row = $ary_ref->[$i];
	@row = ();
	for $j (0..$#{$tmp_row}) {
	    $row[$j] = $tmp_row->[$j];
	}

	print Tr(td(a({-href=>encode_url('changeStatus.pl',
					 date=>$row[0], name=>$row[4])},
		      "$row[2]")), td("$row[3]"),td("$row[4]"),td("$row[5]"));
	print "\n";
    }

    # if no request has been listed, display no request found
    if ($num_items == 0) {
	print Tr({-bgcolor=>"#ffffff", -align=>'center'},
		 td({-colspan=>4}, "No request found!")), "\n";
    }

    print end_table(), "\n";
}
