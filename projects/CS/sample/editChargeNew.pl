#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3 *table *center/;
use FindBin qw($Bin);
use lib "$Bin/../Common";
use misclib;
use datelib;
use 5.004;

# Project: Job Tracking System
# File:    editCharge.pl
# By:      Prasanth Kumar
# Date:    Oct 28, 1999

# Description:
# Handles addition/modification/deletion of charges associated
# with a job request.

# ChangeLog:
# 11/07/2000 Prasanth Kumar
# - start file
# 11/21/2000 Prasanth Kumar
# - fixed check buttons to work properly
#   (need 'eq' instead of '=')
# - Added update functionality
# 11/29/2000 Prasanth Kumar
# - trap error on sql execute statements by
#   using exception handling
# 11/30/2000 Prasanth Kumar
# - sort the values shown in the pulldown menu
# - do cascade deletion of charges table with
#   reference to the jobmanage table
# 12/06/2000 Prasanth Kumar
# - fix link back error
# 12/13/2000 Prasanth Kumar
# - factor out date code into datelib module
# 12/19/2000 Prasanth Kumar
# - the days, months and years lists go into
#   datelib also

BEGIN
{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

########## PRINT HEADER AND START TO FORMATING HTML ##########
print header(-expires=>'+10s'),
    start_html(-title=>"Job Tracking Display",
	       -bgcolor=>"#ffffff"), "\n";

########## PROCESS REQUESTS ##########
$request_id = param('request_id') || '';
$charge_id = param('charge_id') || '';
$user_name = param('name') || '';

# get id of authenticated user
my $userID = remote_user();

# open connection to database
my $dbh = open_database("/home/httpd/.jobDBAccess");

# get the department, payment types and user lists
$dept_table = get_dept_table($dbh);
$paytype_table = get_paytype_table($dbh);
$user_table = get_user_table($dbh);

# display the charge
if (param('Add')) {
    add_charge($dbh);
} elsif (param('Update')) {
    update_charge($dbh);
} elsif (param('Delete')) {
    delete_charge($dbh);
} elsif ($charge_ref = get_charge_entry($dbh, $request_id, $charge_id))
{
    display_charge($dbh, $charge_ref);    
} else {
    print status_message("Job request doesn't exist!");
}

$dbh->disconnect;

print end_html;
exit 0;

########## DISPLAY THE JOB ##########
sub display_charge($$) {
# Purpose: prints out the details of the job in tabular form.
# Input: database handle and filled charge record
# Output: none
    
    my ($dbh, $charge_ref) = @_;
    my ($order_month, $order_day, $order_year);

    ($order_month, $order_day, $order_year) =
	split(/-/, $charge_ref->{'order_date'});
    
    print start_form({-action=>"/cgi-bin/prasanth/editCharge.pl"});
    print h3({-align=>'center'}, "Charge View"), "\n";

    print hidden(-name=>'request_id', -default=>$request_id), "\n";
    print hidden(-name=>'charge_id', -default=>$charge_id), "\n";
    print hidden(-name=>'name', -default=>$user_name), "\n";
    
    print start_table({-border=>0, -align=>'center',
		       -cellpadding=>0}),"\n",
    Tr(td('Request ID'),td($charge_ref->{'request_id'})),"\n",
    Tr(td('Order Date'),
       td(popup_menu(-name=>'request_month',
		     -labels=>$the_months,
		     -values=>[ sort { $a <=> $b } keys %{$the_months} ],
		     -default=>int($order_month)),
	  popup_menu(-name=>'request_day',
		     -values=>$the_days,
		     -default=>int($order_day)),
	  popup_menu(-name=>'request_year',
		     -values=>$the_years,
		     -default=>$order_year))), "\n",
    Tr(td('Invoice Number'),
       td(textfield(-name=>'invoice', -size=>16,
		    -default=>$charge_ref->{'invoice'},
		    -maxlength=>16))),"\n",
    Tr(td('Description'),
       td(textfield(-name=>'description', -size=>40,
		    -default=>$charge_ref->{'description'},
		    -maxlength=>64))),"\n",
    Tr(td('Vendor'),
       td(textfield(-name=>'vendor', -size=>32,
		    -default=>$charge_ref->{'vendor'},
		    -maxlength=>32))),"\n",
    Tr(td('Charge Amount'),
       td(textfield(-name=>'amount', -size=>9,
		    -default=>$charge_ref->{'amount'},
		    -maxlength=>9))),"\n",
    Tr(td('Department'),
       td(popup_menu(-name=>'department',
		     -default=>$charge_ref->{'dept'},
		     -labels=>$dept_table,
		     -values=>[ sort { $a <=> $b }
				keys %$dept_table ]))),"\n",
    Tr(td('Payment Type'),
       td(popup_menu(-name=>'paytype',
		     -default=>$charge_ref->{'paytype'},
		     -labels=>$paytype_table,
		     -values=>[ sort { $a <=> $b }
				keys %$paytype_table ]))), "\n",
    Tr(td('Payer'),
       td(popup_menu(-name=>'payer',
		     -default=>$charge_ref->{'payer'},
		     -values=>[ sort keys %$user_table ]))), "\n";
    if ($charge_ref->{'received'} eq 'Y') {
	print Tr(td('Item Received?'),
		 td(checkbox(-name=>'received',
			     -checked=>'checked',
			     -value=>'Y',
			     -label=>''))),"\n";
    } else {
	print Tr(td('Item Received?'),
		 td(checkbox(-name=>'received',
			     -value=>'Y',
			     -label=>''))),"\n";
    } 
    if ($charge_ref->{'accounted'} eq 'Y') {
	print Tr(td('Accounted for?'),
		 td(checkbox(-name=>'accounted',
			     -checked=>'checked',
			     -value=>'Y',
			     -label=>''))),"\n";
    } else {
	print Tr(td('Accounted for?'),
		 td(checkbox(-name=>'accounted',
			     -value=>'Y',
			     -label=>''))),"\n";
    }
    print end_table, "\n";

    print start_table({-border=>0, -align=>'center',
		       -cellpadding=>5, -width=>'30%'}), "\n";
    if (defined $charge_ref->{'charge_id'}) {
	print Tr(td({-align=>'center'}, submit(-name=>'Update')), "\n",
		 td({-align=>'center'}, submit(-name=>'Delete')), "\n",
		 td({-align=>'center'}, reset())), "\n";
    } else {
	print Tr(td({-align=>'center'}, submit(-name=>'Add')), "\n",
		 td({-align=>'center'}, reset())), "\n";
    }
    print end_table, end_form, "\n";

} # End JobDisplay

########## CALCULATE THE DEPARTMENT LIST ##########
sub get_dept_list($) {

    my $dbh = shift;
    my ($sth, $array_ref, @dept_ref);

    $sth = $dbh->prepare(qq{SELECT * FROM staffdept ORDER BY id});
    $sth->execute or die "executing: $sth->errstr";
    $array_ref = $sth->fetchall_arrayref;

    # convert from ref-array of ref-array ref to a
    # ref-array data structure
    for $i ( 0 .. $#{$array_ref} ) {
	$dept_ref[0]->[$i] = $array_ref->[$i][0];
	$dept_ref[1]->[$i] = $array_ref->[$i][1];
    }
    $sth->finish;
    return @dept_ref;
}

########## GET THE DEPARTMENT TABLE ##########
sub get_dept_table($) {

    my $dbh = shift;
    my ($sth, $array_ref, @dept_ref);

    $sth = $dbh->prepare(qq{SELECT * FROM staffdept ORDER BY id});
    $sth->execute or die "executing: $sth->errstr";
    while (@row = $sth->fetchrow_array) {
	$dept_ref->{$row[0]} = $row[1];
    }
    $sth->finish;
    return $dept_ref;
}

########## GET THE PAYMENT TYPE TABLE ##########
sub get_paytype_table($) {

    my $dbh = shift;
    my ($sth, $array_ref, @paytype_ref);

    $sth = $dbh->prepare(qq{SELECT * FROM paymenttype ORDER BY payid});
    $sth->execute or die "executing: $sth->errstr";
    while (@row = $sth->fetchrow_array) {
	$paytype_ref->{$row[0]} = $row[1];
    }
    $sth->finish;
    return $paytype_ref;
}

########## GET THE USER TABLE ##########
sub get_user_table($) {

    my $dbh = shift;
    my ($sth, $array_ref, @user_ref);

    $sth = $dbh->prepare(qq{SELECT DISTINCT name, fullname
				FROM assignlist ORDER BY name});
    $sth->execute or die "executing: $sth->errstr";
    while (@row = $sth->fetchrow_array) {
	$user_ref->{$row[0]} = $row[1];
    }
    $sth->finish;
    return $user_ref;
}

########## GET CHARGE ENTRY ##########
sub get_charge_entry($$) {

    my ($dbh, $request_id) = @_;
    my ($sth, $row_ref, @row);

    # request_id is a required field
    return undef unless defined $request_id;
    
    # see if job request_id is in the database
    $sth = $dbh->prepare(qq{
	SELECT TO_CHAR(datereceived, 'MMDDYYYYHH24MISS')
	    FROM jobManage
		WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = ?});
    $sth->execute($request_id);
    $row_ref = $sth->fetchall_arrayref;
    $numOfItems = $#{$row_ref}+1;
    $sth->finish;
    
    if ($numOfItems == 0) {
	# not a valid request_id
	return undef;
    }
    
    # see if the charge_id is in the database (ie update)
    $sth = $dbh->prepare(qq{
	SELECT
	    TO_CHAR(request_id, 'MMDDYYYYHH24MISS'),
	    TO_CHAR(charge_id, 'MMDDYYYYHH24MISS'),
	    TO_CHAR(order_date, 'MM-DD-YYYY'),
	    invoice, description, vendor, amount,
	    department, payer, paytype,
	    received, accounted
		FROM charges
		    WHERE TO_CHAR(request_id, 'MM-DD-YYYY-HH24-MI-SS') = ?
			AND TO_CHAR(charge_id, 'MM-DD-YYYY-HH24-MI-SS') = ?});
    $sth->execute($request_id, $charge_id);
    if (@row = $sth->fetchrow_array) {
	# an existing charge
	param('request_id',$row[0]);
	param('charge_id',$row[1]);
	param('order_date',$row[2]);
	param('invoice',$row[3]);
	param('description',$row[4]);
	param('vendor',$row[5]);
	param('amount',$row[6]);
	param('dept',$row[7]);
	param('payer',$row[8]);
	param('paytype',$row[9]);
	param('received',$row[10]);
	param('accounted',$row[11]);	 
    } else {
	param('request_id',$row_ref->[0][0]);
	Delete('charge_id');
	param('order_day', this_day());
	param('order_month', this_month());
	param('order_year', this_year());
	param('invoice',"");
	param('description',"(none)");
	param('vendor',"(none)");
	param('amount',0.00);
	param('dept',5);
	param('payer','Ben');
	param('paytype',1);
	param('received',' ');
	param('accounted',' ');	
    }

    $sth->finish;
	      
	      
}

########## ADD A CHARGE ##########
sub add_charge($) {

    my ($dbh) = @_;
    my ($sth, @row, $received, $accounted);

    # unchecked boxes and not returned in param so
    # assign a space to indicate an unchecked state
    $received = param('received') || ' ';
    $accounted = param('accounted') || ' ';
    
    $sth = $dbh->prepare(qq{
	INSERT INTO CHARGES
	    (request_id, charge_id, order_date,
	     invoice, description, vendor,
	     amount, department, payer,
	     paytype, received, accounted) VALUES
		 (TO_DATE(?, 'MM-DD-YYYY-HH24-MI-SS'),
		  sysdate, TO_DATE(?, 'MM-DD-YYYY'),
		  ?,?,?,?,?,?,?,?,?)});						
    eval { $sth->execute(param('request_id'),
			 date_string(param('request_month'),
				     param('request_day'),
				     param('request_year')),
			 param('invoice'), param('description'),
			 param('vendor'), param('amount'),
			 param('department'), param('payer'),
			 param('paytype'), $received,
			 $accounted) };
    if ($@) {
	Delete('Add');
	status_message('Failed Adding Charge!');
    } else {
	status_message('Suceeded!',
		       encode_url("changeStatus.pl",
				  date=>param('request_id'),
				  name=>$user_name), "Back to Job View");
    }
    $sth->finish;
}

########## UPDATE A CHARGE ##########
sub update_charge($) {

    my ($dbh) = @_;
    my ($sth, @row, $received, $accounted);

    # unchecked boxes and not returned in param so
    # assign a space to indicate an unchecked state
    $received = param('received') || ' ';
    $accounted = param('accounted') || ' ';
    
    $sth = $dbh->prepare(qq{
	UPDATE CHARGES SET
	    order_date = TO_DATE(?, 'MM-DD-YYYY'),
	    invoice = ?, description = ?, vendor = ?,
	    amount = ?, department =?, payer = ?,
	    paytype = ?, received = ?, accounted = ?
		WHERE TO_CHAR(request_id, 'MM-DD-YYYY-HH24-MI-SS') = ?
		    AND TO_CHAR(charge_id, 'MM-DD-YYYY-HH24-MI-SS') = ?});
    eval { $sth->execute(date_string(param('request_month'),
				     param('request_day'),
				     param('request_year')),
			 param('invoice'), param('description'),
			 param('vendor'), param('amount'),
			 param('department'), param('payer'),
			 param('paytype'), $received, $accounted,
			 param('request_id'), param('charge_id')) };
    if ($@) {
	Delete('Update');
	status_message('Failed Updating Charge!');
    } else {
	status_message('Suceeded!',
		       encode_url("changeStatus.pl",
				  date=>param('request_id'),
				  name=>$user_name), "Back to Job View");
    }
    $sth->finish;
}

########## DELETE A CHARGE ##########
sub delete_charge($) {

    my ($dbh) = @_;
    my $sth;

    $sth = $dbh->prepare(qq{
	DELETE FROM charges WHERE
	    TO_CHAR(request_id, 'MM-DD-YYYY-HH24-MI-SS') = ?
		AND TO_CHAR(charge_id, 'MM-DD-YYYY-HH24-MI-SS') = ?});
    eval { $sth->execute(param('request_id'),
			 param('charge_id')) };
    if ($@) {
	Delete('Delete');
	status_message('Failed Deleting Charge!');
    } else {
	status_message('Suceeded!',
		       encode_url("changeStatus.pl",
				  date=>param('request_id'),
				  name=>$user_name), "Back to Job View");
    }
    $sth->finish;
}

########## PRINT A STATUS MESSAGE ##########
sub status_message($;$$) {
# Purpose: prints a status message and provides a link back to
#   another page (ie the form of previous view.)
# Input: message string, link url and link name
# Output: none

    my ($message, $link_url, $link_name) = @_;
    
    print h1({-align=>'center'}, $message), "\n";
    if ($link_url and $link_name) {
	print h3({-align=>'center'},
		 a({-href=>$link_url}, $link_name)), "\n";
    } else {
	print h3({-align=>'center'},
		 a({href=>url(-query=>1),
		    onMouseClick=>"history.go(-1); return false"},
		   "Return Back")), "\n";
    }
}
