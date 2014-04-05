#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
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
#	Requester:
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
# User can only change the status and add comments to the request.

# The script takes several parameters:
# 'name', 'date', 'update', 'status', and 'comments'.
# 'name' and 'date' parameters are used to retrieve the right request.
# 'update' is used to determine whether to update or just display a request.
# When 'update' is not passed in, request is diplayed otherwise, the request
# is updated with new status and comments.

# Last update: July 15, 1999
# Add user's popup-assign-list. User can reassign the assignment to anyone in
# his or her list. When the user did reassign, the script will send an email
# with all information from the request form and other additional information
# the person he or she has assigned the job to.
# Users can also edit the assign list, add or delete entries in the list. 

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

BEGIN
{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

########## GET USERID FROM ENVIRONMENT VARIABLE ##########
$userID = $ENV{REMOTE_USER};

########## PRINT HEADER AND START TO FORMATING HTML ##########
print header(-expires=>'now'),
    start_html(-title=>"Job Tracking Display", -bgcolor=>"#ffffff");

########## PROCESS REQUESTS ##########
my $userName = param('name');
my $date = param('date');
my $update = param('update');

# Get database login and password from file so they are
# not visible in the perl script and easier to maintain.
open(FILE, "/home/httpd/.jobDBAccess") or die "no password file .jobDBAccess";
chop($DBlogin = <FILE>);
chop($DBpassword = <FILE>);

# Open connection to database
$dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword,
		    {PrintError=>1, RaiseError=>1}) or die "connecting : $DBI::errstr";

# There is no update passed in, retrieves and displays request only
if (!$update) {
    JobDisplay($dbh);
} else {
    JobUpdate($dbh);
}

$dbh->disconnect;

print end_html;

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
    $sth = $dbh->prepare(qq{SELECT
				TO_CHAR(datereceived, 'MM-DD-YYYY'),
				clientname, roomno, building, phoneno, email,
				machinetype, operatingsystem, jobdescription,
				TO_CHAR(datereceived, 'MMDDYYYYHH24MISS')
				    FROM jobRequest
					WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$date' AND clientname = '$userName'});
    $sth->execute or die "executing: $sth->errstr";
    @row = $sth->fetchrow_array;

    # Retrieve request's information from 'jobManage' table
    $sth2 = $dbh->prepare(qq{SELECT
				 status, priority, title, comments,
				 reassigned, TO_CHAR(datefinished, 'MM-DD-YYYY'),
				 resolution, personassigned
				     FROM jobManage
					 WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$date' AND clientname = '$userName'});
    $sth2->execute or die "executing: $sth2->errstr";
    @row2 = $sth2->fetchrow_array;

    # Get the assign list from the database based of person assigned
    $sth3 = $dbh->prepare(qq{SELECT name
				 FROM assignList WHERE assigner = '$row2[7]'
				     ORDER by name});
    $sth3->execute or die "executing: $sth3->errstr";

    $i = 1;
    while (@row3 = $sth3->fetchrow_array) {
	$list[$i++] = $row3[0];
    }
                          
    $list[0] = 'Nobody';

    # Don't have a blank date finished (looks nicer)
    if ($row2[5] eq '') {
	$row2[5] = '(none)';
    }
    
    # Check if successed to retrieve a request. If successed, go on
    if ($#row == 9) {
	print start_form(-action=>'/cgi-bin/JobTrackHotline/changeStatus.pl');
	print h3({-align=>'center'}, "Job Details");    
	print '<table border=2 align=center cellspacing=2 cellpadding=5>',
        Tr(td({-bgcolor=>'#CCEEFF'}, 'Job Title'),
	   td({-colspan=>3},"$row2[2]")),
        Tr(td({-bgcolor=>'#CCEEFF'}, 'Description'),
	   td({-colspan=>3},"$row[8]")),
	Tr(td({-bgcolor=>'#CCEEFF'}, 'Request ID'),
	   td({-colspan=>3},"$row[9]")),
        Tr(td({-bgcolor=>'#CCEEFF'}, 'Date Received'),
	   td("$row[0]"), td({-bgcolor=>'#CCEEFF'}, 'Date Finished'),
	   td("$row2[5]")),
        Tr(td({-bgcolor=>'#CCEEFF'}, 'Requester'),
	   td("$row[1]"), td({-bgcolor=>'#CCEEFF'}, 'Email'),
	   td('<a href="mailto:' . "$row[5]" . '">' . "$row[5]" . '</a>')),
        Tr(td({-bgcolor=>'#CCEEFF'}, 'Room Number'),
	   td("$row[2]"), td({-bgcolor=>'#CCEEFF'}, 'Building'),
	   td("$row[3]")),
        Tr(td({-bgcolor=>'#CCEEFF'}, 'Phone'),
	   td("$row[4]"), td({-bgcolor=>'#CCEEFF'}, 'Machine Type'),
	   td("$row[6]")),
	   Tr(td({-bgcolor=>'#CCEEFF'}, 'Priority'),
	   td("$row2[1]"), td({-bgcolor=>'#CCEEFF'}, 'O.S'),
	   td("$row[7]"));
	print '</table>';

	# Pull down menu choices for status and reassignment
	print '<table border=0 align=center cellspacing=5 celpadding=5>',
        Tr(td({-align=>'right'},'Status: '),
	   td({-align=>'center'}, popup_menu(-name=>"status",
					   -values=>['Finished', 'Active'],
					   -default=>$row2[0])),
	   td({-align=>'right'}, 'Reassign to: '),
	   td({-align=>'center'}, popup_menu(-name=>"reassign",
					   -values=>\@list,
					   -default=>$row2[4])));
	print '</table>'; 

	print '<table border=0 align=center cellspacing=5 cellpadding=0>',
	Tr(td({-align=>'left'},'Comments: ')),
	Tr(td({-align=>'center'}, textarea(-name=>"comments",
					 -default=>$row2[3], -rows=>5,
					 -columns=>40, -wrap=>'virtual')));
	print '</table>';

	print '<table border=0 align=center cellspacing=5 cellpadding=0>',
	Tr(td({-align=>'left'}, 'Resolution: (Note: Mandatory for finished jobs)')),
	Tr(td({-align=>'center'}, textarea(-name=>"resolutions",
					 -default=>$row2[6], -rows=>5,
					 -columns=>40, -wrap=>'virtual')));
	print '</table>';

	# Only allow the assigned person to make changes
	if ($row2[7] eq $userID) {
	    print '<center>', submit(-name=>'update', -value=>'Update'),
	    hidden(-name=>'name', -value=>$userName),
	    hidden(-name=>'date', -value=>$date),
	    hidden(-name=>'oldstatus', -value=>$row2[0]),
	    hidden(-name=>'oldreassign', -value=>$row2[4]),
	    '</center>';
	}

	print end_form;
    }	# End if ($#row)

    # If failed to retrieve request, display error message
    else {
	print '<HR>';
	print h1({-align=>'center'}, "Sorry, This job request has either status changed or been deleted");
	print '<HR>';
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
	print '<hr>';
	print '<br><center>';
	print h1("The request is not updated"), "<br>";
	print h2("Please go back and fill out the resolution field");
	print '</center><br><hr>';
	return;
    }

    # Update information.
    $sth = $dbh->prepare(qq{UPDATE jobManage SET
				status = ?,
				comments = ?,
				reassigned = ?,
				resolution = ?,
				datefinished = sysdate
				    WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS')= '$date' AND clientname = '$userName'});
    $sth->bind_param(1,$status);
    $sth->bind_param(2,$comments);
    $sth->bind_param(3,$reassign);
    $sth->bind_param(4,$resolution);

    # Execute the update.
    $sth->execute or die "executing: $sth->errstr";
    $dbh->commit;

    # Get email of the user.
    my $mail_handler = $dbh->prepare(qq{SELECT * FROM assignlist
					    WHERE name='$userID'});
    $mail_handler->execute or die "Executing: $mail_handler->errstr";
    my @user_record = $mail_handler->fetchrow_array;
    $mail_handler->finish;
    
    # Retrieve information from the request form
    my $sth3 = $dbh->prepare(qq{SELECT
				    TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
				    TO_CHAR(datereceived, 'MM-DD-YYYY'),
				    clientname, roomno, building, phoneno, email,
				    machinetype, operatingsystem, jobdescription
					FROM jobRequest
					    WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$date' AND clientname = '$userName'});
    $sth3->execute or die "executing: $sth3->errstr";
    my @row3 = $sth3->fetchrow_array;
    $sth3->finish;

    # Retrieve management information
    my $sth4 = $dbh->prepare(qq{SELECT
				    priority, comments, resolution
					FROM jobManage
					    WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$date' AND clientname = '$userName'});
    $sth4->execute or die "executing: $sth4->errstr";
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
#	if ($finish_info[1] ne '') {  possible typo?
	if ($row4[1] ne '') {
	    print MAIL "Comments:\n";
	    print MAIL "$row4[1]\n\n";
	}
    	print MAIL "Regards,\n\n";
    	print MAIL "$userID\n";
	print MAIL "$user_record[1]\n";
    	close (MAIL);
    }

    # Send email to the one who has been assigned a job when reassign name
    # is changed.
    if (($reassign ne $oldreassign) && ($reassign ne 'Nobody')) {

	# Retrieve email of the person who has been assigned the job
    	my $sth2 = $dbh->prepare(qq{SELECT email FROM assignList
					WHERE name = '$reassign' and assigner = '$userID'});
    	$sth2->execute or die "executing: $sth2->errstr";
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
    print '<HR>',
    h1({-align=>'center'}, "This request has been updated"),
    '<HR>';

} # End JobUpdate
