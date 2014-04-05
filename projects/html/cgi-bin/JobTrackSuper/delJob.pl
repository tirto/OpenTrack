#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use 5.004;

##############################################################################
#
# Projects: Job Tracking System
# File:     delJob.pl
# By:       Phuoc Diec
# Date:     June 11, 1999
# Description:
# This file lists all requests in database for user to view.
# User can then choose which request to delete. 

# When user first login, it will list all request with date received and 
# requester name. 
# User can choose which request to delete or view a request in detail
# before delete it.
# Each request is referred to by its received date.
#
##############################################################################

########## SET UP A PATH TO DATABASE FOR ENVIRONMENT VARIABLES ##########
BEGIN
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}


########## OPEN CONNECTION WITH THE DATABASE ##########
open(FILE,"/home/httpd/.jobDBAccess");
$DBlogin = <FILE>;
$DBpassword = <FILE>;
# Let's get rid of that newline character
chop $DBlogin;
chop $DBpassword;

my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
    or die "connecting:  $DBI::errstr";


########## PRINT HEADER AND START FORMATTING HTML ##########
print 
  header(-expires=>'now'),
  start_html(-title=>"Job Tracking Display", -bgcolor=>"#ffffff");

print 
  h1({-align=>'center'}, "College Of Engineering"),
  h2({-align=>'center'}, "Job Tracking System"),
  p({-align=>'center'}, img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"});

########## START PROCESSING REQUESTS FROM A WEB BROWSER ##########

# List all job requests when user first logins or
# requests with 'listall' while that user is viewing a single request in detail.
if (!param() || param('listall')) {
  ListRequests($dbh);
}

# User wants to list a single request in detail.
elsif (param('listdetail')) {
  ListDetail($dbh, param('date'));
}

# User wants to delete one or more requests by selecting their checkboxes.
# When a request is selected, its received date will be passed in.
# 'Mid' is a list of recieved dates passed in from a web browser by a user. 
# This list along with a handle to the database are passed to the function
# that will delete requests by date received.
elsif (param('delthem')) {
  DeleteRequestsByDate($dbh, param('Mid'));
  ListRequests($dbh);
} 

# User wants to delete a single request that he or she has viewed in detail
# A date received of the request is also passed along.
# The function delete request by date received is called to do the job.
elsif (param('delthis')) {
  DeleteRequestsByDate($dbh, param('date'));
  ListRequests($dbh);
}

########## CLOSE THE DATABASE CONNECTION ##########
$dbh->disconnect;

########## END FORMATTING HTML ##########
print end_html;


#////////////////////////////////////////////////////////////////////////////
# 
# Belows are subroutines that are used by this script (delJob.pl).
#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

########## LIST A REQUEST IN DETAIL ##########
sub ListDetail {
# Purpose: lists a single request in detail. 
#          Also allow user to delete a current request or go back
#          to a list of requests.

# Input: a handle to the database and a request id (request's received date).
# Output: Information of a request is listed in a table.

  my $dbh = shift @_;
  my $date = shift @_;

  # Since information of a request is kept in two different tables in the database,
  # we have to get information from each table.

  # Retrieve request's infor from 'jobRequest' table
  $sth = $dbh->prepare(qq{SELECT
                          TO_CHAR(datereceived, 'MM-DD-YYYY'),
                          clientname, roomno, building, phoneno, email,
                          machinetype, operatingsystem, jobdescription
                          FROM jobRequest
                          WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$date'});
  $sth->execute or die "executing: $sth->errstr";
  @row = $sth->fetchrow_array;

  # Retrieve request's infor from 'jobManage' table
  $sth2 = $dbh->prepare(qq{SELECT
                          status, priority, title, comments, personassigned
                          FROM jobManage
                          WHERE TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$date'});
  $sth2->execute or die "executing: $sth2->errstr";
  @row2 = $sth2->fetchrow_array;

  # format a form which contain only 'Delete' and 'Go Back' buttons. 
  print startform();

  # This hidden value is a request's ID. It is used later for deleting or
  # listing a request.
  print hidden(-name=>'date', -value=>$date);
                          
  # Format a menu of two buttons. One for deleting a current viewing request
  # and the other one is for going back to the list of requests.
  # This menu is placed on top and at the bottom of the table so that for
  # long table, user don't have to scroll back to the top for the menu.
  print '<table border=0 cellpadding=1 cellspacing=0 width="100%">',
        Tr({-bgcolor=>"#dcdcdc"},
            td({-align=>'left'}, submit(-name=>'delthis', -value=>'Delete')),
            td({-align=>'right'}, submit(-name=>'listall', -value=>'Go Back'))),
        '</table>';

  print '<br><br>';

  # Format table and arrange data in it.
  print '<table border=1 align=center cellpadding=4 cellspacing=2>',
        Tr(td('Job Title'), td("$row2[2]")),
        Tr(td('Date Received'), td("$row[0]")),
        Tr(td('Requester'), td("$row[1]")),
        Tr(td('Room Number'), td("$row[2]")),
        Tr(td('Building'), td("$row[3]")),
        Tr(td('Phone'), td("$row[4]")),
        Tr(td('Email'), td("$row[5]")),
        Tr(td('Machine Type'), td("$row[6]")),
        Tr(td('O/S'), td("$row[7]")),
        Tr(td('Description'), td("$row[8]")),
        Tr(td('Priority'), td("$row2[1]")),
        Tr(td('Assigned to'), td("$row2[4]")),
        Tr(td('Status'), td("$row2[0]")),
        Tr(td('Comments'), td("$row2[3]"));
  print '</table>'; 

  print '<br><br>';

  # Place the menu at the end of the table.
  print '<table border=0 cellpadding=1 cellspacing=0 width="100%">',
        Tr({-bgcolor=>"#dcdcdc"},
            td({-align=>'left'}, submit(-name=>'delthis', -value=>'Delete')),
            td({-align=>'right'}, submit(-name=>'listall', -value=>'Go Back'))),
        '</table>';

  print endform();
}	#End ListDetail

########## LISTING ALL REQUESTS ##########
sub ListRequests() {
# Purpose: List all requests that have been submitted to 'jobManage' table.
# Input: A handle to the database where 'jobManage' is kept.
# Output: A list of requests listed in a table.

  my $dbh = shift @_;

  # Format a form that has one checkbox for each request listed on the table.
  # User can choose which request to delete by selecting these checkboxes.
  print startform();

  # Format the table header which has five columns.
  print '<table border=0 align=center cellpadding=2 cellspacing=1>',
        Tr({-bgcolor=>"#aaccff"},
           td("&nbsp;"),
           td({-align=>'center'}, "Title"),
           td({-align=>'center'}, "Request Date"),
           td({-align=>'center'}, "Requester"),
           td({-align=>'center'}, "Priority"));

  # Prepare a statement to retrieve all requests
  $sth = $dbh->prepare(qq{SELECT
                            TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS'),
                            title,
                            TO_CHAR(datereceived, 'MM-DD-YYYY'),
                            clientname, priority
                            FROM jobManage
                         }); 
  $sth->execute or die "executing: $sth->errstr";

  $numOfItem = 0;

  # Reading requests from the database one-by-one.
  while (@row = $sth->fetchrow_array) {

    # Substitute spaces of strings with char '+', %20, for passing to cgi
    $tmpClient = $row[3];
    $tmpClient =~ s/\s/%20/g;
    
    $numOfItem += 1;

    # Format each request for diplaying on the tableManage.
    # The first column is a checkbox, select it to delete a request.
    # The second column is a link that will display a request in detail. 
    print 
        Tr({-bgcolor=>"#ffffff"}, td(checkbox(-name=>"Mid", -value=>$row[0], -label=>' ')),
           td(a({-href=>"/cgi-bin/JobTrackSuper/delJob.pl?date=$row[0]&listdetail='detail'"}, "$row[1]")),
           td("$row[2]"),
           td("$row[3]"),
           td("$row[4]"));
  }	# End while

  # If no request has been listed, display no request found
  if ($numOfItem == 0) {
    print Tr({-bgcolor=>"#ffffff"}, td("No request found"));
  }

  print '</table>';

  # Format a delete and reset buttons.
  # Delete will delete all selected requests.
  # Reset will undo the selection.
  print '<table border=0 align=center cellspacing=4>',
        Tr(td(reset('Reset')),
           td({-width=>50}, "&nbsp;"),
           td(submit(-name=>'delthem', -value=>'Delete'))),
        '</table>';

  print endform();
}	#End ListRequests

########## DELETE ALL REQUESTS ##########
sub DeleteRequestsByDate() {
# Purpose: Deletes one or more requests by received date.
# Input: A handle to the database where the data will be deleted.
#        A list of received dates of request to be deleted.
# Output: None.

  my $dbh = shift @_;
  my @delList = @_;

  $counter = 0;

  # Received data is a request's ID. Requests that have received date matched
  # with the dates passed into this function will be deleted.
  # This function gives a command to delete information of a request in
  # 'jobRequest' table. When doing the deletion, the database also has
  # a trigger which causes the coresponding information in 'jobManage'
  # table deleted as well.

  foreach $delDate(@delList) {
    $sth = $dbh->prepare(qq{DELETE FROM jobRequest WHERE
            TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$delDate'
                         }); 
    $sth->execute or die "executing: $sth->errstr";

    $counter++;
  } #End foreach

  print h2({-align=>'center'}, "Deleted $counter request(s)"), '<br>';
}	# End DeleteRequests






