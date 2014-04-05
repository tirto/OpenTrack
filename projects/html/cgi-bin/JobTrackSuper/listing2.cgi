#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;

################################################################################

# Project:	Job Tracking System
# File:		listing.cgi
# By:		Phuoc Diec
# Date:		Augus 6, 1999
# Description:
#   Search the database and generate html page that lists all requests that
#   match the criteria. Also perform a deletion of requests.

#   Requests can be listed by status: new, inactive, finished, or all. They can
#   also be searched by id, date, requester, responder, status, or any
#   combination of those.

#   All the input for searching such as date and requests id are assumpted to 
#   have no error. They are checked and verified before submitted.

#   Results are listed in table format in html page. The table has five columns:
#	 - First column are a check box. They are used to select and delete a
#          requests.
#	 - Request id column has links to view requests in detail.
# 	 - Request title column.
#	 - Requester column.
#	 - Responder column.

#   There are only 10 requests listed in a the table at a time. If searching 
#   result is more than 10 requests, 'next' and 'previous' buttons are generated
#   for user to be able to go to the next page for more results and go back to
#   the previous page.
 
#   Display requests in details is handled by detail.cgi.

#   The script uses parameter 'type' to determine which search function to 
#   perform. Depend on the value of 'type', there are additional parameters.
#   Values of 'type' are below:

#       - type = 0: Delete selected request(s).
#	- type = 1: Search request by ID. 'id' parameter is needed. ID is a 14
#         digit string.
#       - type = 2: Search request by status.
#	- type = 3: Search requests by date.
#	- type = 4: Search requests by period, starting date and ending date.
#	- type = 5: Search by requester's name. 
#	- type = 6: Search by responder's name. 

#   To perform a search with more than one above criteria, append all the
#   values together in an increasing order. For example, 124 or 245.

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

# Delete selected request(s)
if (param('delete')) {
  DeleteRequests($dbh, param('rid'));
  if (param('type') == 2) { 
    ByStatus($dbh, param('search_status'), param('stridx'));
  }
}

# Search by request ID
elsif (param("type") == 1) {
  print h3("Search by ID");
}

# Search by status
elsif (param("type") == 2) {
  ByStatus($dbh, param('search_status'), param('stridx'));
#  print h3("Search by status");
}

# Search by date
#elsif (param("type") eq '3') {
#  print h3("Search by date");
#}

# Search by period
#elsif (param("type") eq '4') {
#  print h3("Search by period");
#}

# Search by requester
#elsif (param("type") eq '5') {
#  print h3("Search by requester");
#}

# Search by responder
#elsif (param('type') eq '6') {
#  print h3("Search by responder"0;
#} 

# Search by status and date
#elsif (param('type') eq '23') {
#  print h3("Search by status and date");
#}

# Search by status and period
#elsif (param('type') eq '24') {
#  print h3("Search by status and period");
#}

# Search by status and requester
#elsif (param('type') eq '25') {
#  print h3("Search by status and requester");
#}

# Search by status and responder
#elsif (param('type') eq '26') {
#  print h3("Search by status and responder");
#}

# Search by status, date, and requester
#elsif (param('type') eq '235') {
#  print h3("Search by status, data, and requester");
#}

# Search by status, date, and responder
#elsif (param('type') eq '236') {
#  print h3("Search by status, date, and responder");
#}

# Search by status, period, and requester
#elsif (param('type') eq '245') {
#  print h3("Search by status, period, and requester");
#}

# Search by status, period, and responder
#elsif (param('type') eq '246') {
#3  print h3("Search by status, period, and responder");
#}

# Search by status, requester, and responder
#elsif (param('type') eq '256') {
#  print h3("Search by status, requester, and responder");
#}

# Search by date and requester
#elsif (param('type') eq '35') {
#  print h3("Search by date and requester");
#}

# Search by date and responder
#elsif (param('type') eq '36') {
#  print h3("Search by date and responder");
#}

# Search by date, requester, and responder
#elsif (param('type') eq '356') {
#  print h3("Search by date, requester, and responder");
#3}

# Search by period and requester
#elsif (param('type') eq '45') {
#  print h3("Search by period and requester");
#}

# Search by period and responder
#elsif (param('type') eq '46') {
#  print h3("Search by period and responder");
#}

# Search by period, requester, and responder
#elsif (param('type') eq '456') {
#  print h3("Search by period, requester, and responder");
#}

# Search by requester and responder
#elsif (param('type') eq '56') {
#  print h3("Search by requester and responder");
#}

# Other than that, error message
#else {
#  print '<center>';
#  print h2("Unknow request");
#  print '</center>';
#}

$dbh->disconnect;
print end_html;


#//////////////////////////////////////////////////////////////////////////////
#
# Belows are subroutines that are used by listing.cgi
#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

########## DELETING REQUESTS ##########
sub DeleteRequests() {
# Purpose: Delete requests in the deleting list.
# Input:   Handle to the database.
#          Status of requests to be deleted.
#          Starting index of the page of these requests.
#          List of request id to be deleted.

  my $dbh = shift @_;
#  my $search_status = shift @_;
#  my $startidx = shift @_;
  my @delList = @_;

  # Loop through the list and delete requests that have id in the list.
  foreach $delRequest(@delList) {
    $sth = $dbh->prepare(qq{DELETE FROM jobRequest WHERE
                 TO_CHAR(datereceived, 'MMDDYYYYHH24MISS') = '$delRequest'});
    $sth->execute or die "executing: $sth->errstr";
  } # End foreach

} # End DeleteRequests 


########## LIST REQUESTS BASED ON STATUS ##########
sub ByStatus() {
# Purpose: Retrieve and list requests in the database based on status.
# Input: Handle of connection to the database.
#        Status of request to be retrieved.
# Output: None.

  my $dbh = shift @_;
  my $search_status = shift @_;
  my $startidx = shift @_;

  # Retrieve all request that match the criteria
  # 'all' is listing all requests in the database.
  if ($search_status eq 'all') {
    $sth = $dbh->prepare(qq{SELECT
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
                            clientname, personassigned, title
                            FROM jobManage
                            ORDER by datereceived DESC});
  } # End if ($search_status eq 'all')

  # List Requests that have specified status.
  else {
   # Capitalize the first letter to match with status in the database.
    if ($search_status eq 'unassigned') {
      $search_status = 'Unassigned';
    }
    if ($search_status eq 'active') {
      $search_status = 'Active';
    }
    if ($search_status eq 'finished') {
      $search_status = 'Finished';
    }

    $sth = $dbh->prepare(qq{SELECT
                            TO_CHAR(datereceived, 'MMDDYYYYHH24MISS'),
                            clientname, personassigned, title
                            FROM jobManage
                            WHERE status = '$search_status'
                            ORDER by datereceived DESC});
  } # End else

  $sth->execute or die "Executing: $sth->errstr";

  $ary_ref = $sth->fetchall_arrayref;
  $tmp = $ary_ref->[0];

  if ($tmp->[0]) {

    # Calculate ending index to list requests.
    # The starting index and ending index start at 1 but the index of the array
    # returned by fetchall_ref starts at 0. 
    $total_requests = $#{$ary_ref} + 1;
    if (($startidx+4) >= $#{$ary_ref}) {
      $endidx = $#{$ary_ref} + 1;
    }
    else {
      $endidx = $startidx + 5;
    }

    # Generate heading message of request to request of total requests 
    print '<center>';
    print h4("$search_status requests: $startidx-$endidx of $total_requests");
    print '</center>';

    # Generate a form of check boxes for deleting requests.
    print startform();

    # Generate table header.
    print '<table border=1 align=center cellspacing=1 cellpadding=2>';
    print Tr({-bgcolor=>"#0088ff", -align=>'center'}, td("&nbsp"), td("Request ID"),
           td("Title"), td("Requester"), td("Responder"));

    # Looping through the array until to the ending index and format requests
    # onto the table one at a time.
    $ary_idx = $startidx - 1;

    # Check for out of bound
    if ($ary_idx >= $endidx && $startidx > 11) {
      $ary_idx -= 10;
    }
    elsif ($ary_idx >= $endidx && $startidx <= 11) {
      $ary_idx = 0;
    }

    while ($ary_idx < $endidx) { 
      $temp_ary = $ary_ref->[$ary_idx];

      print '<TR BGCOLOR="#ffffff">';
      print "<TD><INPUT TYPE=CHECKBOX NAME=rid VALUE=$temp_ary->[0]></TD>";
      print '<TD>';

      if ($ary_idx == 0) {
        print "<A HREF=/cgi-bin/JobTrackSuper/detail.cgi?type=2&rid=$temp_ary->[0]&search_status=$search_status&pos=first>$temp_ary->[0]<\/A>";
      }
      elsif ($ary_idx == $#{$ary_ref}) {
        print "<A HREF=/cgi-bin/JobTrackSuper/detail.cgi?type=2&rid=$temp_ary->[0]&search_status=$search_status&pos=last>$temp_ary->[0]<\/A>";
      }
      else {
        print "<A HREF=/cgi-bin/JobTrackSuper/detail.cgi?type=2&rid=$temp_ary->[0]&search_status=$search_status&pos=middle>$temp_ary->[0]<\/A>";
      }

      print '</TD>';
      print "<TD>$temp_ary->[3]<\/TD>";
      print "<TD>$temp_ary->[1]<\/TD>";
      print "<TD>$temp_ary->[2]<\/TD>";
      print '</TR>';

      $ary_idx++;
    } # End while 

    print '</table>';  # End of request listing table.

    # Generate delete and reset button for deleting selected requests above.
    print '<table width=50% align=center border=0>';
    print Tr({-align=>'center'}, td(submit(-name=>'delete', -value=>'Delete')),
             td(reset));
    print '</table>';

    # Generate hidden fields for additional information for the deletion. 
    print hidden(-name=>'type', -value=>$type);
    print hidden(-name=>'search_status', -value=>$search_status);
    print hidden(-name=>'stridx', -value=>$startidx);

    print endform; # End check box form

    # Generate Next and Previous buttons for results that are longer than 10.
    # The first page does not have previous button.
    print '<table width=100% border=0>';
    if ($startidx == 1 && $endidx < $total_requests) {
      $endidx += 1;
      print '<TR><TD>&nbsp</TD><TD ALIGN="RIGHT">';
      print "<A HREF=\"\/cgi-bin\/JobTrackSuper\/listing.cgi?type=2&search_status=$search_status&stridx=$endidx\">NEXT<\/A><\/TD><\/TR>";
    }

    # The last page does not have next button.
    elsif ($startidx > 1 && $endidx >= $total_requests) {
      $startidx -= 6;
      print '<TR><TD ALIGN="LEFT">';
      print "<A HREF=\"\/cgi-bin\/JobTrackSuper\/listing.cgi?type=2&search_status=$search_status&stridx=$startidx\">PREVIOUS<\/A><\/TD><\/TR>";
    }

    # Pages in between have both previous and next buttons.
    elsif ($startidx > 1 && $endidx < $total_requests) {
      $endidx += 1;
      $startidx -= 6;
      print '<TR><TD ALIGN="LEFT">';
      print "<A HREF=\"\/cgi-bin\/JobTrackSuper\/listing.cgi?type=2&search_status=$search_status&stridx=$startidx\">PREVIOUS<\/A><\/TD>";
      print '<TD ALIGN="RIGHT">';
      print "<A HREF=\"\/cgi-bin\/JobTrackSuper\/listing.cgi?type=2&search_status=$search_status&stridx=$endidx\">NEXT<\/A><\/TD><\/TR>";
    }
    print '</table>'; # End table of next and previous buttons.

  } # End if ($tmp->[0])

  # In case of no request is retrieved, display message.
  else {
    print '<center><hr>';
    print h2("No $search_status Request Found");
    print '<hr></center>';
  }
} # End ByStatus

