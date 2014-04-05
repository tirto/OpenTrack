#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use 5.004;

##########################################################################################
# jobChange.pl is a simple script that performs the changes asked by the user            #
# then returns to the list in jobmanage.pl                                               #
# The input values are all jobManage fields plus 'page' to know whether to return to the #
# new requests list or to the current requests list                                      #
##########################################################################################

#GENERAL CONFIGURATION PARAMETERS

BEGIN 

{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

#We get the login and password to access the database
open(FILE,"/home/httpd/.jobDBAccess");
$DBlogin = <FILE>;
$DBpassword = <FILE>;
#Let's get rid of that newline character
chop $DBlogin;
chop $DBpassword;


print header(),
      start_html(-title=>'College Of Engineering Job Tracking System',-BGCOLOR=>'white'),
      h1({-align=>center},"College Of Engineering Job Tracking System"),
      p({-align=>center},img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"});


$dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError=>1,RaiseError=>1}) or die "connecting :   $DBI::errsrtr";

$sth = $dbh->prepare(qq{UPDATE jobManage SET personassigned = ?, status = ?, priority = ?, title = ?, comments = ?
		        WHERE datereceived = TO_DATE(?,'MM-DD-YYYY-HH24-MI-SS') AND clientname = ?}); 
$sth->bind_param(1,param('personassigned'));
$sth->bind_param(2,param('status'));
$sth->bind_param(3,param('priority'));
$sth->bind_param(4,param('title'));
$sth->bind_param(5,param('comments'));
$sth->bind_param(6,param('date')); 
$sth->bind_param(7,param('client')); 
$sth->execute or die "executing: $sth->errstr"; 
$sth->finish;              

##############################################################################
# The following fragment is added on June 7, 1999.
# It sends email notification to assigned person.
# The list of assigned persons and their email address is kept in a text file.
# The list has to be read from the file every time this script is invoked.
# It is inefficient but easilly to manage the list.
##############################################################################
$recipient = param("personassigned");
$job_id = param('date');

if ($recipient ne 'Nobody') {

  $userId = $ENV{REMOTE_USER};

  # Get email from the database
  $sth = $dbh->prepare(qq{SELECT email FROM assignList
                          WHERE name = '$recipient' AND assigner = '$userId'});
  $sth->execute or die "executing: $sth->errstr";
  @row = $sth->fetchrow_array;
  $sth->finish;

  # Compose and send an email to notify the person that there is a new request.
  open (MAIL, "|/usr/lib/sendmail -t") || die "Can't open $mailprog!\n";
  print MAIL "To: $row[0]\n";
  print MAIL "From: Job Tracking Manager\n";
  print MAIL "Subject: New Request for Service\n";
  print MAIL "\n\n";
  print MAIL "Hello $recipient,\n\n";
  print MAIL "You have new request. Request ID is $job_id.\n";
  print MAIL "Please check Request Access at http://dolphin.engr.sjsu.edu\n\n";
  print MAIL "Thank you.\n";
  close (MAIL);

  # The user want to send a note to the person who make the request to 
  # notify about the progress of the request.
  # Compose and send email to the requester.
  if (param('sendnoteto')) {

    my $date = param("date");
    my $client = param("client");
    # Get the request ID number from the database for the requester's future
    # reference. This ID is based on the date and time the request was issued.
    $sth1 = $dbh->prepare(qq{SELECT TO_CHAR(datereceived, 'MMDDYYYYHH24MISS')
                            FROM jobmanage WHERE
                            TO_CHAR(datereceived, 'MM-DD-YYYY-HH24-MI-SS') = '$date'
                            AND clientname = '$client'}); 
    $sth1->execute or die "executing: $sth1->errstr";
    @id = $sth1->fetchrow_array;
    $sth->finish;

    $client = param('client');
    $clientEmail = param('sendnoteto');
    open (MAIL, "|/usr/lib/sendmail -t") || die "Can't open $mailprog!\n";
    print MAIL "To: $clientEmail\n";
    print MAIL "From: Job Tracking Manager\n";
    print MAIL "Subject: Respond to your request\n";
    print MAIL "\n\n";
    print MAIL "Hello $client, \n\n";
    print MAIL "Your request, ID number $id[0], has been forwarded to $recipient.\n";
    print MAIL "You may email $recipient at $row[0].\n\n";
    print MAIL "Thank you.\n";
    close (MAIL);
  }
}
# End adding fragment

$dbh->disconnect;

print 'Request updated', br;
if (param("page") eq 'new') {
    $temp = 1;
} else {
    $temp = 2;
}
print a({-href=>"/cgi-bin/JobTrackSuper/jobManage.pl?page=$temp"}, 'Back to your List of Requests');
print end_html;

