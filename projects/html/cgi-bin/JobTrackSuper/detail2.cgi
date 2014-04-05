#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;

################################################################################

# Project:	Job Tracking System
# File:		detail.cgi
# By:		Phuoc Diec
# Date:		Augus 11, 1999
# Description:
#   List a request in details including information submitted by requester,
#   information added by responder, and information added by manager.

#   Required parameters:
#	- 'list' for listing all information.
#	- 'delete' for deleting a request.
#	- 'rid' request id.
#	- 'status' request status.
#	- 'index' index of the request in the list.

#   When deleting a request, the next request of the same status will be listed
#   in detail. In case the deleted request is the last one in the list, the
#   precessor request will be listed.

#   Information is displayed in table format.

#   If there is no request after deleting, empty message is displayed.

################################################################################

########## SET UP ENVIRONMENT VARIABLES TO THE DATABASE ##########
BEGIN
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

########## OPEN CONNECTION TO THE DATABASE ##########
open(FILE,"/home/httpd/.jobDBAccess");
$DBlogin = <FILE>;
$DBpassword = <FILE>;
# Let's get rid of that newline character
chop $DBlogin;
chop $DBpassword;

my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
    or die "connecting:  $DBI::errstr";


########## GENERATE RESPOND HEADER AND HTML HEADER ##########
print header();
print start_html(-title=>"Management Request Listing",
                 -bgcolor=>"#ffffff");

########## PROCESS REQUESTS FROM BROWSERS ##########
if (param('delete')) {

  DeleteRequest($dbh, param('rid'));
  $dbh->commit || die $dbh->errstr;

  if (param('type') == 1) {
    print '<center>', "Request with ID ";
    print param('rid');
    print " was deleted<center>";
  } # End if (param('type') == 1)

  elsif (param('type') == 2) {
    @result = Next_rid($dbh, param('rid'), param('search_status'), param('pos'));
    if ($result[0] ne 'failed') {
      ListDetails($dbh, $result[0], param('search_status'), $result[1]);
    }
    else {
      @result = Previous_rid($dbh, param('rid'), param('search_status'), param('pos'));
      if ($result[0] ne 'failed') {
        ListDetails($dbh, $result[0], param('search_status'), $result[1]);
      }
      else {
        print "The list is empty";
      }
    }
  } # End if (param('type') == 2)

}

elsif (param('update')) {
  if (param('change_sta') eq 'true' && param('status') eq 'Active') {
    ChangeStatus($dbh, param('rid'));
  }
  elsif (!param('change_sta')) {
    UpdateRequest($dbh, param('rid'), param('responder'), param('status'), param('priority'), param('title'), param('comments'), param('reassigned'), param('sendnoteto'));
  }

  if (param('type') == 1) {
    #ListDetailsByID($dbh, param('rid'));
  }
  elsif (param('type') == 2) {
    ListDetails($dbh, param('rid'), param('search_status'), param('pos'));
  }
} # End elsif (param('update')

elsif (param('type') == 1) {
print h1("Listing detail by searching ID");
}

elsif (param('type') == 2) {
  if (param('next')) {
    @result = Next_rid($dbh, param('rid'), param('search_status'));
    if ($result[0] ne 'failed') {
      ListDetails($dbh, $result[0], param('search_status'), $result[1]);
    }
    else {
      print h3("Could not find next request");
    }
  }
  elsif (param('prev')) {
    @result = Previous_rid($dbh, param('rid'), param('search_status'));
    if ($result[0] ne 'failed') {
      ListDetails($dbh, $result[0], param('search_status'), $result[1]);
    }
    else {
      print h3("Could not find previous request");
    }
  }
  else {
    ListDetails($dbh, param('rid'), param('search_status'), param('pos'));
  }
}

# Other than that, error message
else {
  print '<center>';
  print h2("Unknown request");
  print '</center>';
}

$dbh->disconnect;
print end_html;


#//////////////////////////////////////////////////////////////////////////////
#
# Belows are subroutines that are used by listing.cgi
#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

########## CHANGE STATUS ##########
sub ChangeStatus() {
# Purpose: Change status to Active
# Input: Handle to the database.
#        ID of the request to be updated.

  my $dbh = shift @_;
  my $rid = shift @_;

  $sth = $dbh->prepare(qq{UPDATE jobManage SET status='Active'
                          WHERE TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') = '$rid'});
  $sth->execute or die "Executing: $sth->errstr";

} # End ChangeStatus()


########## UPDATE A REQUEST ##########
sub UpdateRequest() {
# Purpose: Update a request with new management info.
# Input: Handle to the database.
#        ID of the request to be updated.
#        All management info.
# Output: None.

  my $dbh = shift @_;
  my $rid = shift @_;
  my $personassigned = shift @_;
  my $status = shift @_;
  my $priority = shift @_;
  my $title = shift @_;
  my $comments = shift @_;
  my $reassigned = shift @_;
  my $sendnote = shift @_;
  my $datefinished;
  
  # Check if the request is assigned to a new person.
  $sth = $dbh->prepare(qq{SELECT clientname, personassigned, status,
                                 datefinished 
                          FROM jobManage
                          WHERE TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') = '$rid'});
  $sth->execute or die "Executing: $sth->errsrt";
  @manageInfo = $sth->fetchrow_array;
  $sth->finish;

  if ($personassigned ne 'Nobody' && $personassigned ne $manageInfo[1]) {
    $userId = $ENV{REMOTE_USER};

    # Get email address of the person from the database.
    $sth = $dbh->prepare(qq{SELECT email FROM assignList
                            WHERE name = '$personassigned'
                            AND assigner = '$userId'});
    $sth->execute or die "Executing: $sth->errstr";
    @row = $sth->fetchrow_array;
    $sth->finish;
    
    # Compose and send email to notify the person that there is a new request.
    open (MAIL, "|/usr/lib/sendmail -t") or die "Can't open $mailprog!\n";
    print MAIL "To: $row[0]\n";
    print MAIL "From: Job Tracking Manager\n";
    print MAIL "Subject: New Request for Service\n";
    print MAIL "\n\n";
    print MAIL "Hello $personassigned, \n\n";
    print MAIL "You have new request, please check Request Access at http://dolphin.engr.sjsu.edu\n\n";
    print MAIL  "Thank you.\n";
    close (MAIL);

    # Set previous reassigned person to nobody.
    $reassigned = 'Nobody';
  } # End if 

  # Compose and send email to notify requester about the request status.
  if ($sendnote) {
    open (MAIL, "|/usr/lib/sendmail -t") || die "Can't open $mailprog!\n";
    print MAIL "To: $sendnote\n";
    print MAIL "From: Job Tracking Manager\n";
    print MAIL "Subject: Respond to your request\n";
    print MAIL "\n\n";
    print MAIL "Hello $manageInfo[0], \n\n";
    print MAIL "Your request, ID number $rid, has been forward to $personassigned.\n";
    print MAIL "You may email $personassigned at $row[0].\n";
    print MAIL "Thank you.\n";
    close (MAIL);
  } # End if ($sendnote)

  if ($status eq 'Finished' && $status ne $manageInfo[2]) {

    $sth = $dbh->prepare(qq{UPDATE jobManage SET
                            personassigned='$personassigned',
                            status='$status',
                            priority='$priority',
                            title='$title',
                            comments='$comments',
                            reassigned='$reassigned',
                            datefinished = sysdate
                        WHERE TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') = '$rid'});

  }
  elsif ($status eq 'Finished' && $status eq $manageInfo[2]) {

    $sth = $dbh->prepare(qq{UPDATE jobManage SET
                            personassigned='$personassigned',
                            status='$status',
                            priority='$priority',
                            title='$title',
                            comments='$comments',
                            reassigned='$reassigned',
                            datefinished = '$manageInfo[3]' 
                        WHERE TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') = '$rid'});
  }
  else {

    $sth = $dbh->prepare(qq{UPDATE jobManage SET
                            personassigned='$personassigned',
                            status='$status',
                            priority='$priority',
                            title='$title',
                            comments='$comments',
                            reassigned='$reassigned'
                        WHERE TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') = '$rid'});
  }
  $sth->execute or die "Executing: $sth->errstr";
  $sth->finish;
} # End UpdateRequest


########## DELETE A REQUEST FROM THE DATABASE ##########
sub DeleteRequest() {
# Purpose: Delete a selected request based on rid.
# Input:   Handle to the database, dbh.
#          Request ID, rid.
# Output:  None.

  my $dbh = shift @_;
  my $rid = shift @_;

  $sth = $dbh->prepare(qq{DELETE FROM jobRequest WHERE
                          TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') = '$rid'});
  $sth->execute or die "Executing: $sth->errstr";
  $sth->finish;
  return;
} # End DeleteRequest


########## SEARCH FOR PREVIOUS REQUEST ##########
sub Previous_rid() {
# Purpose: Search for previous request in the list.
# Input:   Database handle, dbh.
#          Request ID of current request, rid.
#          Request status, status.
# Output:  A list of three variables: rid, status, and pos.

  my $dbh = shift @_;
  my $rid = shift @_;
  my $status = shift @_;
  my $pos = shift @_;

  if ($status eq 'all') {
    $sth = $dbh->prepare(qq{SELECT
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
                            clientname, personassigned, title
                            FROM jobManage
                            WHERE 
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') > '$rid'
                            ORDER by datereceived ASC});
  }  
  else {
    $sth = $dbh->prepare(qq{SELECT
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
                            clientname, personassigned, title
                            FROM jobManage
                            WHERE status = '$status' AND 
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') > '$rid'
                            ORDER by datereceived ASC});
  }

  $sth->execute or die "Executing: $sth->errstr";
  $ary_ref = $sth->fetchall_arrayref;

  $tmp = $ary_ref->[0];

  if ($tmp->[0]) {
    $returned_list[0] = $tmp->[0];

    if ($pos eq 'last') {
      $returned_list = 'last';
    }
    elsif ($#{$ary_ref} == 0) {
      $returned_list[1] = 'first';
    }
    else {
      $returned_list[1] = 'middle';
    }
  }
  else {
    @returned_list[0] = 'failed';
  }
    
  return @returned_list;
} # End Previous_rid


########## SEARCH FOR NEXT REQUEST ##########
sub Next_rid() {
# Purpose: Search for next request in the list.
# Input: Database handle.
#        Request ID of current displayed request.
#        Request status.
# Output: A list of three variables: rid, status, and pos.

  my $dbh = shift @_;
  my $rid = shift @_;
  my $status = shift @_;
  my $pos = shift @_;

  if ($status eq 'all') {
    $sth = $dbh->prepare(qq{SELECT
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
                            clientname, personassigned, title
                            FROM jobManage
                            WHERE 
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') < '$rid'
                            ORDER by datereceived DESC});
  }  
  else {
    $sth = $dbh->prepare(qq{SELECT
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
                            clientname, personassigned, title
                            FROM jobManage
                            WHERE status = '$status' AND 
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') < '$rid'
                            ORDER by datereceived DESC});
  }

  $sth->execute or die "Executing: $sth->errstr";
  $ary_ref = $sth->fetchall_arrayref;

  $tmp = $ary_ref->[0];

  if ($tmp->[0]) {
    $returned_list[0] = $tmp->[0];

    if ($pos eq 'first') {
      $returned_list[1] = 'first';
    }
    elsif ($#{$ary_ref} == 0) {
      $returned_list[1] = 'last';
    }
    else {
      $returned_list[1] = 'middle';
    }
  }
  else {
    @returned_list[0] = 'failed';
  }
    
  return @returned_list;
} # End Prev_Next_rid


########## LIST A REQUEST IN DETAIL ##########
sub ListDetails() {
# Purpose: List a request in detail.
# Input:   Database handle.
#          Request ID.
#          Request status.
#          Request index in the list.
# Output:  None

  my $dbh = shift @_;
  my $rid = shift @_;
  my $search_status = shift @_;
  my $pos = shift @_;

  # Retrieve information from 'jobRequest' table.
  $sth = $dbh->prepare(qq{SELECT *
                          FROM jobRequest, jobmanage
                          WHERE TO_CHAR(jobRequest.datereceived, 'MMDDYYYYHH24MISS') = '$rid'
                          AND TO_CHAR(jobManage.datereceived, 'MMDDYYYYHH24MISS') = '$rid'});
  $sth->execute or die "executing: $sth->errstr";
  @row = $sth->fetchrow_array;

  # Save client email address for sending a note if needed
  $clientEmail = $row[4];

  # Checking the phone value - indeed there could be a bug here in case of somebody's number being '4-0000'
  if ($row[3] == 0) {
    $row[3] = "None";
  }
  else {
    $row[3] = "4-$row[3]";
  }

  # Retrieve information from jobManage table.
  #$sth2 = $dbh->prepare(qq{SELECT * FROM jobManage 
#			  WHERE datereceived = '$row[0]'});

 # $sth2->execute or die "executing: $sth2->errstr";
  #@row2 = $sth2->fetchrow_array;

  print start_form();

 if ($row[12] eq 'Finished') {
    print '<table border=1 align=center cellpadding=3 cellspacing=3 bgcolor="#FFDD99">';
    print Tr(td({-bgcolor=>'#AAEEEE'}, "Date Requested"), td($row[0]),
              td({-bgcolor=>'#AAEEEE'}, "Date Finished"), td($row[17])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Name"), td({-colspan=>3}, $row[1])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Email"), td($row[4]),
              td({-bgcolor=>'#AAEEEE'}, "Phone"), td($row[3])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Building"), td($row[7]),
              td({-bgcolor=>'#AAEEEE'}, "Room"), td($row[2])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Machine Type"), td($row[5]),
              td({-bgcolor=>'#AAEEEE'}, "O.S."), td($row[6])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Description"), td({-colspan=>3}, $row[8])),
          Tr(td({-bgcolor=>'#AAEEEE'}, "Title"), td({-colspan=>3}, $row[14])),
          Tr(td({-bgcolor=>'#AAEEEE'}, "Responder"), td($row[11]), 
             td({-bgcolor=>'#AAEEEE'}, "Forward to"), td($row[16])),
          Tr(td({-bgcolor=>'#AAEEEE'}, "Status"),
             td({-align=>left}, popup_menu(-name=>"status",
                 -values=>['Active', 'Finished'],
                 -default=>$row[12])),
             td({-bgcolor=>'#AAEEEE'}, "Priority"), td($row[13])),
          Tr(td({-bgcolor=>'#AAEEEE'}, "Comments"), td({-colspan=>3}, $row[15])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Resolution"), td({-colspan=>3}, $row[18]));
    print '</table>';
    print "<INPUT TYPE=HIDDEN NAME=change_sta VALUE=true>";

  } # End ($row2[3] eq 'finished')

  else {

    $userId = $ENV{REMOTE_USER};

    # Get the assign list from the database
    $sth3 = $dbh->prepare(qq{SELECT name 
                             FROM assignList WHERE assigner = '$userId'
                             ORDER by name});
    $sth3->execute or die "executing: $sth3->errstr";

    $i = 1;
    while (@row3 = $sth3->fetchrow_array) {
      $list[$i++] = $row3[0];
    }
    $list[0] = 'Nobody';

    print '<table border=1 align=center cellpadding=3 cellspacing=3 bgcolor="#FFDD99">';
    print Tr(td({-bgcolor=>'#AAEEEE'}, "Date"), td({-colspan=>3}, $row[0])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Name"), td({-colspan=>3}, $row[1])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Email"), td($row[4]),
             td({-bgcolor=>'#AAEEEE'}, "Phone"), td($row[3])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Building"), td($row[7]),
             td({-bgcolor=>'#AAEEEE'}, "Room"), td($row[2])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Machine Type"), td($row[5]),
             td({-bgcolor=>'#AAEEEE'}, "O.S."), td($row[6])),
	  Tr(td({-bgcolor=>'#AAEEEE'}, "Description"), td({-colspan=>3}, $row[8]));
    print '</table>';

    print table({-align=>center}),
              Tr(td({-align=>right}, "Title : "),
                 td({-align=>left, -colspan=>3}, textarea(-name=>"title",
                   -default=>$row[14], -rows=>2, -columns=>40, -wrap=>virtual))),
              Tr(td({-align=>right}, "Responder : "),
                 td({-align=>left},
                      popup_menu(-name=>"responder",
                                 -values=>\@list, -default=>$row[11])),
                 td({-align=>right}, "Forward to: "),
                 td({-align=>left}, $row[16])),
              Tr(td({-align=>right}, "Status : "),
                 td(popup_menu(-name=>"status",
                     -values=>['Unassigned', 'Active', 'Finished'],
                      -default=>$row[12])),
                 td({-align=>right}, "Priority : "),
                 td({-align=>left}, popup_menu(-name=>"priority",
                     -values=>['Low','Normal','High'], -default=>$row[13]))),
              Tr(td({-align=>right}, "Comments : "),
                 td({-align=>left, -colspan=>3}, textarea(-name=>"comments",
                   -default=>$row[15], -rows=>5, -columns=>40, -wrap=>virtual))), 
              Tr(td({-align=>right}, "Resolution : "),
                 td({-align=>left, -colspan=>3}, textarea(-name=>"resolution",
                   -default=>$row[18], -rows=>5, -columns=>40, -wrap=>virtual))), 
              Tr(td({-align=>right}, "Send a note to requester: "),
                 td({-align=>left}, checkbox(-name=>'sendnoteto',
                     -value=>$clientEmail, -label=>' ')));
    print '</table>';
    
    print "<INPUT TYPE=HIDDEN NAME=reassigned VALUE=$row[16]>";

  } # End else

  print '<table border=0 width=100%>';
  print Tr(td({-align=>right}, submit(-name=>'delete', -value=>'Delete')),
           td({-align=>center}, reset()),
           td({-align=>left}, submit(-name=>'update', -value=>'Update'))
          );
  print '</table>';
  
  print '</CENTER>';

  print '<INPUT TYPE="HIDDEN" NAME="type" VALUE="2">';
  print "<INPUT TYPE=HIDDEN NAME=rid VALUE=$rid>";
  print "<INPUT TYPE=HIDDEN NAME=search_status VALUE=$search_status>";
  print "<INPUT TYPE=HIDDEN NAME=pos VALUE=$pos>";

  print endform;

  print '<CENTER><FONT SIZE="+2">';
  if ($pos eq 'first') {
    print "<A HREF=/cgi-bin/JobTrackSuper/detail.cgi?type=2&next=next&search_status=$search_status&rid=$rid>Next<\/A>";
  }
  elsif ($pos eq 'last') {
    print "<A HREF=/cgi-bin/JobTrackSuper/detail.cgi?type=2&prev=prev&search_status=$search_status&rid=$rid>Prev<\/A>";
  }
  else {
    print "<A HREF=/cgi-bin/JobTrackSuper/detail.cgi?type=2&prev=prev&search_status=$search_status&rid=$rid>Prev<\/A>";
    print ' | ';
    print "<A HREF=/cgi-bin/JobTrackSuper/detail.cgi?type=2&next=next&search_status=$search_status&rid=$rid>Next<\/A>";
  }
  print '</FONT></CENTER>';

} # End ListDetail












