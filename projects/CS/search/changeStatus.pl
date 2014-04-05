#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3 *table *center/;
use FindBin qw($Bin);
use lib "$Bin/../Common";
use misclib;
use 5.004;

# Project: Job Tracking System
# File:    changeStatus.pl
# By:      Phuoc Diec
# Date:    May 28, 1999

# Description:
# This script displays a single job request in detail. 
# The information is displayed in the following format:
#	Title
#	Date received
#	Requester
#	Room number
#	Building
#	Phone
#	Email
#	Machine Type
#	O/S
#	Description
#	Priority
#	Status
#	Change Status
#	Comments
# User can only change the status and add comments to the requests
# they own.

# The script takes several parameters:
# 'name', 'date', 'update', 'status', and 'comments'.
# 'name' and 'date' parameters are used to retrieve the right request.
# 'update' is used to determine whether to update or just display a
# request.  When 'update' is not passed in, request is diplayed
# otherwise, the request is updated with new status and comments.

# Last update: July 15, 1999
# Add user's popup-assign-list. User can reassign the assignment to
# anyone in his or her list. When the user did reassign, the script
# will send an email with all information from the request form and
# other additional information the person he or she has assigned the
# job to.  Users can also edit the assign list, add or delete entries
# in the list.

# ChangeLog:
# 06/07/2000 Prasanth Kumar
# - Remove redundant SJSU logo and title from the  header as it has been
#   moved to menu window already.
# - Read DB username/password from files for added security.
# - Add 'mailto' capability link on clients email field.
# 06/08/2000 Prasanth Kumar
# - Rearranged html table and text area for more compact appearance.
# - Obtain 'personassigned' from the 'jobManage' database also so
#   it can be used to obtain associated list of assignees and
#   whether to allow changes.
# 06/12/2000 Prasanth Kumar
# - Added 'Request ID' to job details table.
# - Fixed some minor typos.
# - Make code more modular (more subroutines.)
# 06/13/2000 Prasanth Kumar
# - Fix userID case error.
# 06/16/2000 Prasanth Kumar
# - Start quoting all html parameters to remove warnings.
# 06/29/2000 Prasanth Kumar
# - Start using ../Common/misclib.pm
# 08/14/2000 Prasanth Kumar
# - Fix prepare statements to not interpolate parameters.
# 08/18/2000 Prasanth Kumar
# - Add responder field to detail view.
# 09/01/2000 Prasanth Kumar
# - Clean up html tags (strings=>functions).
# - Make tables and comments/resolution fields wider.
# - Start adding charge accounting features.
# 09/13/2000 Prasanth Kumar
# - Determine login id using remote_user() function.
# 11/06/2000 Prasanth Kumar
# - Call editCharges.pl on add/editing of a charge.
# 11/15/2000 Prasanth Kumar
# - Limit listing of charges associated with a job
# - Make sure to close all opened DBI connections

BEGIN
{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

########## PRINT HEADER AND START TO FORMATING HTML ##########
print header(-expires=>'now'),
    start_html(-title=>"Job Tracking Display", -bgcolor=>"#ffffff");

########## PROCESS REQUESTS ##########
my $userName = param('name');
my $date = param('date');
my $update = param('update');

# Open connection to database
my $dbh = open_database("/home/httpd/.jobDBAccess");

# get id of authenticated user
my $userID = remote_user();

# There is no update passed in, retrieves and displays request only
if (!$update) {
    JobDisplay($dbh);
} else {
    JobUpdate($dbh);
}

$dbh->disconnect;

print end_html;
exit 0;

########## END OF MAIN ##########

########## DISPLAY THE JOB ##########
sub JobDisplay {
# Purpose: prints out the details of the job in tabular form.
# Input: database handle
# Output: none
    
    my $dbh = shift(@_);
    
    # Since information of each request is kept in two different table
    # Have to go to each table to get them.
    
    # Retrieve request's information from 'jobRequest' table
    $sth = $dbh->prepare(qq{
	SELECT
	    TO_CHAR(datereceived, 'MM-DD-YYYY'),
	    clientname, roomno, building, phoneno, email,
	    machinetype, operatingsystem, jobdescription,
	    TO_CHAR(datereceived, 'MMDDYYYYHH24MISS')
		FROM jobRequest
		    WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = ?
			AND clientname = ?});
    $sth->execute($date, $userName) or die "executing: $sth->errstr";
    @row = $sth->fetchrow_array;
    $sth->finish;
    
    # Retrieve request's information from 'jobManage' table
    $sth2 = $dbh->prepare(qq{
	SELECT
	    status, priority, title, comments,
	    reassigned, TO_CHAR(datefinished, 'MM-DD-YYYY'),
	    resolution, personassigned
		FROM jobManage
		    WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = ?
			AND clientname = ?});
    $sth2->execute($date, $userName) or die "executing: $sth2->errstr";
    @row2 = $sth2->fetchrow_array;
    $sth2->finish;
    
    # Get the assign list from the database based of person assigned
    $sth3 = $dbh->prepare(qq{
	SELECT name
	    FROM assignList WHERE assigner = ?
		ORDER by name});
    $sth3->execute($row2[7]) or die "executing: $sth3->errstr";
    
    $i = 1;
    while (@row3 = $sth3->fetchrow_array) {
	$list[$i++] = $row3[0];
    }
    $sth3->finish;
    
    $list[0] = 'Nobody';

    # Don't have a blank date finished (looks nicer)
    if (!defined $row2[5]) {
	$row2[5] = '(none)';
    }
    
    # Check if successed to retrieve a request. If successed, go on
    if ($#row == 9) {
	print start_form(-action=>'/cgi-bin/JobTrackHotline/changeStatus.pl'), "\n";
	print h3({-align=>'center'}, "Job Details"), "\n";    
	print start_table({-border=>1, -align=>'center', -width=>'85%',
			   -cellspacing=>0, -cellpadding=>5}), "\n",
        Tr(td({-bgcolor=>'#cceeff'}, 'Job Title'),
	   td({-colspan=>3},"$row2[2]")), "\n",
        Tr(td({-bgcolor=>'#cceeff'}, 'Description'),
	   td({-colspan=>3},"$row[8]")), "\n",
	Tr(td({-bgcolor=>'#cceeff'}, 'Request ID'), td("$row[9]"),
	   td({-bgcolor=>'#cceeff'}, 'Responder'), td("$row2[7]")), "\n",
        Tr(td({-bgcolor=>'#cceeff'}, 'Date Received'),
	   td("$row[0]"), td({-bgcolor=>'#cceeff'}, 'Date Finished'),
	   td("$row2[5]")), "\n",
        Tr(td({-bgcolor=>'#cceeff'}, 'Requester'),
	   td("$row[1]"), td({-bgcolor=>'#cceeff'}, 'Email'),
	   td('<a href="mailto:' . "$row[5]" . '">' . "$row[5]" . '</a>')), "\n",
        Tr(td({-bgcolor=>'#cceeff'}, 'Room Number'),
	   td("$row[2]"), td({-bgcolor=>'#cceeff'}, 'Building'),
	   td("$row[3]")), "\n",        Tr(td({-bgcolor=>'#cceeff'}, 'Phone'),
	   td("$row[4]"), td({-bgcolor=>'#cceeff'}, 'Machine Type'),
	   td("$row[6]")), "\n",
	   Tr(td({-bgcolor=>'#cceeff'}, 'Priority'),
	   td("$row2[1]"), td({-bgcolor=>'#cceeff'}, 'O.S'),
	   td("$row[7]")), "\n";
	print end_table, br, "\n";

	# Charges table
	$sth4 = $dbh->prepare(qq{
	    SELECT
		TO_CHAR(order_date, 'MM-DD-YYYY'),
		invoice, description, amount,
		TO_CHAR(request_id, 'MM-DD-YYYY-HH24-MI-SS'),
		TO_CHAR(charge_id, 'MM-DD-YYYY-HH24-MI-SS')
		    FROM charges
			WHERE TO_CHAR(request_id, 'MM-DD-YYYY-HH24-MI-SS') = ?
			    ORDER BY order_date});
	$sth4->execute($date) or die "executing: $sth->errstr";
	my $charge_ref = $sth4->fetchall_arrayref;
	my $numOfItems = $#{$charge_ref}+1;
	my $total_charges = 0;
	$sth4->finish;
	
	print start_table({-border=>1, -align=>'center', -width=>'85%',
			   -cellspacing=>0, -cellpadding=>5}),
	Tr({-bgcolor=>'#cceeff', -align=>'center'},
	   td('Order Date'), td('Invoice'),
	   td('Description'), td('Amount')), "\n";
	
	for ($i = 0; $i < $numOfItems; $i++) {
	    $tmp_row = $charge_ref->[$i];
	    @row3 = ();
	    for $j (0..$#{$tmp_row}) {
		$row3[$j] = $tmp_row->[$j];
	    }

	    print Tr(td({-align=>'center'},
			a({-href=>encode_url("editCharge.pl",
					     request_id=>$row3[4],
					     charge_id=>$row3[5],
					     name=>$userName)}, $row3[0])),
		     td({-align=>'center'}, $row3[1]),
		     td($row3[2]), td(format_dollars($row3[3]))), "\n";
	    $total_charges = $total_charges + $row3[3];
	}
	
	if ($numOfItems == 0) {
	    print Tr(td({-colspan=>4}, "No charges found"));
	}

	print Tr(td({-colspan=>3},
		    a({-href=>encode_url("editCharge.pl",
					 request_id=>$date,
					 name=>$userName)},
		       "Add a charge")),
		    td(b(format_dollars($total_charges))));
	
	print end_table, br;
	
	# Pull down menu choices for status and reassignment
	print start_table({-border=>0, -align=>'center',
			   -cellspacing=>5, -cellpadding=>0}),
        Tr(td({-align=>'right'},'Status: '),
	   td({-align=>'center'}, popup_menu(-name=>"status",
					     -values=>['Finished', 'Active'],
					     -default=>$row2[0])),
	   td({-align=>'right'}, 'Reassign to: '),
	   td({-align=>'center'}, popup_menu(-name=>"reassign",
					     -values=>\@list,
					     -default=>$row2[4])));
	print end_table; 

	# Comments and resolution entries
	print start_table({-border=>0, -align=>'center',
			   -cellspacing=>5, -cellpadding=>0}),
	Tr(td({-align=>'left'},'Comments: ')),
	Tr(td({-align=>'center'}, textarea(-name=>"comments",
					   -default=>$row2[3], -rows=>5,
					   -columns=>60, -wrap=>'virtual')));
	print end_table;

	print start_table({-border=>0, -align=>'center',
			   -cellspacing=>5, -cellpadding=>0}),
	Tr(td({-align=>'left'}, 'Resolution: (Note: Mandatory for finished jobs)')),
	Tr(td({-align=>'center'}, textarea(-name=>"resolutions",
					   -default=>$row2[6], -rows=>5,
					   -columns=>60, -wrap=>'virtual')));
	print end_table;

	# Only allow the assigned person to make changes
	if ($row2[7] eq $userID) {
	    print start_center, submit(-name=>'update', -value=>'Update'),
	    hidden(-name=>'name', -value=>$userName),
	    hidden(-name=>'date', -value=>$date),
	    hidden(-name=>'oldstatus', -value=>$row2[0]),
	    hidden(-name=>'oldreassign', -value=>$row2[4]),
	    end_center;
	}

	print end_form;
    }	# End if ($#row)

    # If failed to retrieve request, display error message
    else {
	print hr, h1({-align=>'center'}, "Sorry, This job request has either status changed or been deleted"), hr;
    }

} # End JobDisplay

########## Update the job with changes ##########
sub JobUpdate {
# Purpose: Update the database with the changes requested by
#   the user.
# Input: database handle
# Output: none
    
    my $dbh = shift(@_);
    
    my $status = param('status');
    my $comments = param('comments');
    my $reassign = param('reassign');
    my $oldstatus = param('oldstatus');
    my $oldreassign = param('oldreassign');
    my $resolution = param('resolutions');

    if ($status eq 'Finished' && !$resolution) {
	print hr, br, start_center;
	print h1("The request is not updated"), br;
	print h2("Please go back and fill out the resolution field");
	print end_center, br, hr;
	return;
    }

    # Update information.
    $sth = $dbh->prepare(qq{
	UPDATE jobManage SET
	    status = ?, comments = ?,
	    reassigned = ?,	resolution = ?,
	    datefinished = sysdate
		WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS')= ?
		    AND clientname = ?});
    $sth->bind_param(1,$status);
    $sth->bind_param(2,$comments);
    $sth->bind_param(3,$reassign);
    $sth->bind_param(4,$resolution);
    $sth->bind_param(5,$date);
    $sth->bind_param(6,$userName);
    
    # Execute the update.
    $sth->execute or die "executing: $sth->errstr";
    $dbh->commit;

    # Get email of the user.
    my $mail_handler = $dbh->prepare(qq{
	SELECT * FROM assignlist WHERE name = ?});
    $mail_handler->execute($userID) or die "Executing: $mail_handler->errstr";
    my @user_record = $mail_handler->fetchrow_array;
    $mail_handler->finish;
    
    # Retrieve information from the request form
    my $sth3 = $dbh->prepare(qq{
	SELECT
	    TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
	    TO_CHAR(datereceived, 'MM-DD-YYYY'),
	    clientname, roomno, building, phoneno, email,
	    machinetype, operatingsystem, jobdescription
		FROM jobRequest
		    WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = ?
			AND clientname = ?});
    $sth3->execute($date, $userName) or die "executing: $sth3->errstr";
    my @row3 = $sth3->fetchrow_array;
    $sth3->finish;

    # Retrieve management information
    my $sth4 = $dbh->prepare(qq{
	SELECT
	    priority, comments, resolution
		FROM jobManage
		    WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = ?
			AND clientname = ?});
    $sth4->execute($date, $userName) or die "executing: $sth4->errstr";
    my @row4 = $sth4->fetchrow_array;
    $sth4->finish;

    if ($status eq 'Finished') {
	# Send mail notifying the manager that this person has finished
	# the request.
    	open (MAIL, "|/usr/lib/sendmail -t") || die "Cannot open $mailprog!";
        print MAIL "To: $row3[6]", "\n";
	print MAIL 'Cc: kindness@email.sjsu.edu', "\n";
    	print MAIL "From: $user_record[1]\n";
    	print MAIL "Subject: Finished Request\n";
    	print MAIL "\n\n";
    	print MAIL "Hello:\n\n";
    	print MAIL "Request $date requested by $userName has been completed.\n\n";
	print MAIL "Description:\n";
	print MAIL "$row3[9]\n\n";
	print MAIL "Resolution:\n";
	print MAIL "$row4[2]\n\n";
	if ($row4[1] ne '') {
	    print MAIL "Comments:\n";
	    print MAIL "$row4[1]\n\n";
	}
    	print MAIL "Thank you for using the ECS Job Tracking System.\n\n";
    	print MAIL "Sincerely,\n\n";
    	print MAIL "$userID\n";
	print MAIL "$user_record[1]\n";
    	close (MAIL);
    }

    # Send email to the one who has been assigned a job when reassign name
    # is changed.
    if (($reassign ne $oldreassign) && ($reassign ne 'Nobody')) {

	# Retrieve email of the person who has been assigned the job
    	my $sth2 = $dbh->prepare(qq{
	    SELECT email FROM assignList
		WHERE name = ? and assigner = ?});
    	$sth2->execute($reassign, $userID) or die "executing: $sth2->errstr";
    	my @row2 = $sth2->fetchrow_array;
	$sth2->finish;

	#Compose and send mail to the lucky person
	open (MAIL, "|/usr/lib/sendmail -t") || die "Cannot open $mailprog!";
	print MAIL "To: $row2[0]\n";
	print MAIL "From: $userID\n";
	print MAIL "Subject: New Request\n";
	print MAIL "\n\n";
	print MAIL "Hello $reassign,\n\n";
	print MAIL "Please work on this request.\n\n";
	print MAIL "Request ID: $row3[0]\n";
	print MAIL "Request date: $row3[1]\n";
	print MAIL "Priority: $row4[0]\n";
	print MAIL "Comments: $row4[1]\n\n";
	print MAIL "Requester: $row3[2]\n";
	print MAIL "Room number: $row3[3]	Building: $row3[4]\n";
	print MAIL "Phone number: $row3[5]	Email: $row3[6]\n";
	print MAIL "Machine type: $row3[7]	O/S: $row3[8]\n";
	print MAIL "Description: $row3[9]\n\n";
	print MAIL "Thank you,\n\n";
	print MAIL "$userID";
	close (MAIL);
    }  # End if (($reassign ne $oldreassign) && ($reassign ne 'Nobody'))

    # Print message to comfirm the update
    print hr, h1({-align=>'center'}, "This request has been updated"), hr;

} # End JobUpdate
