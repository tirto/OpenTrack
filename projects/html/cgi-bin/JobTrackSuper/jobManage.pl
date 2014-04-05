#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use 5.004;

####################################################################################
# jobManage.pl is the script that lists all kinds of requests:                     #
# new, currently in process and already finished ones                              #
# This is the first script loaded when a manager connects to the JobTrackingSystem #
####################################################################################


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


# All info on CGI functions used here can be found @ http://stein.cshl.org/WWW/software/CGI/cgi_docs.html
# They are also featured in the last part of the CGI.pm source itself
print header(),
      start_html(-title=>'College Of Engineering Job Tracking System',-BGCOLOR=>'white'),
      h1({-align=>center},"College Of Engineering Job Tracking System"),
      p({-align=>center},img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"});


# For $dbh and $sth documentation, refer to the DBI module, which is described in 'perldoc DBI'
if (param()) {
  $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError=>1,RaiseError=>1}) or die "connecting :   $DBI::errsrtr";
  my $page  = param("page");

########################################## NEW REQUESTS #################################################

  if ($page == 1) {

      $sth = $dbh->prepare(qq{SELECT
	     TO_CHAR(jobRequest.datereceived,'MM-DD-YYYY-HH24-MI-SS'),
             TO_CHAR(jobRequest.datereceived,'MMDDYYYYHH24MISS'),
	     jobRequest.clientname, jobRequest.phoneno, jobRequest.email
	     FROM jobManage, jobRequest
	     WHERE jobRequest.datereceived = jobManage.datereceived
             AND jobRequest.clientname = jobManage.clientname
	     AND jobManage.status = 'Unassigned'});
    $sth->execute or die "executing: $sth->errstr";

    print p({-align=>center},'<font size=+1>These are requests that are not currently assigned</font>');

    print '<table border=0 align=center cellspacing=4>';
    print Tr({-bgcolor=>"#9999FF"}, td(), td("Date of Request"), td("Name of Issuer"), td("Phone No"), td("Email Address"));

    while (@row = $sth->fetchrow_array) {
# Checking the phone value - indeed there could be a bug here in case of somebody's number being '4-0000'
	if ($row[3] == 0) {
	    $row[3] = "None";
	} else {
	    $row[3] = "4-$row[3]";
	}
# Substituting spaces with %20 for cgi
	$temp = $row[2];
	$temp =~ s/\s/%20/g;

	print Tr(td(a({-href=>"/cgi-bin/JobTrackSuper/jobEdit.pl?page=new&date=$row[0]&client=$temp",
		       -onMouseOver=>"window.status='Edit and Assign this new request from [$row[2]]'; return true;",
		       -onMouseOut=>"window.status=' '; return true;"}, img({src=>"/redbullet.gif", border=>0}))),
		 td("$row[1]"),td("$row[2]"),td({-align=>center}, "$row[3]"),td("$row[4]"));
    }
    print '</table>';

##################################### REQUESTS UNDER PROCESS ############################################

  } elsif ($page == 2) {
      $sth = $dbh->prepare(qq{SELECT
	     TO_CHAR(datereceived,'MM-DD-YYYY-HH24-MI-SS'), priority,
             TO_CHAR(datereceived,'MMDDYYYYHH24MISS'),
	     clientname, personassigned, title
	     FROM jobManage
             WHERE status = 'Active'
             ORDER by datereceived DESC});
    $sth->execute or die "executing: $sth->errstr";

    print p({-align=>center},'<font size=+1>These are the requests that are currently under process</font>');

    print '<table border=0 align=center cellspacing=4 cellpadding=4>';
    print Tr({-bgcolor=>"#11EE88", -align=>center}, td(), td(), td("Request ID"), td("Name of Issuer"),
	     td("Personassigned to it"), td("Title of Request"));

    while (@row = $sth->fetchrow_array) {
# Substituting spaces with %20 for cgi
	$temp = $row[3];
	$temp =~ s/\s/%20/g;

	if ($row[1] eq 'High  ') {
	    print Tr(td(img({src=>"/exclamation.gif", alt=>"this request is of higher priority"})),
		 td(a({-href=>"/cgi-bin/JobTrackSuper/jobEdit.pl?page=now&date=$row[0]&client=$temp",
		       -onMouseOver=>"window.status='Edit this request assigned to [$row[4]]'; return true;",
		       -onMouseOut=>"window.status=' '; return true;"}, img({src=>"/greenbullet.gif", border=>0}))),
		 td("$row[2]"),td("$row[3]"),td("$row[4]"),td("$row[5]"));
	} else {
	    print Tr(td(),
		 td(a({-href=>"/cgi-bin/JobTrackSuper/jobEdit.pl?page=now&date=$row[0]&client=$temp",
		       -onMouseOver=>"window.status='Edit this request assigned to [$row[4]]'; return true;",
		       -onMouseOut=>"window.status=' '; return true;"}, img({src=>"/greenbullet.gif", border=>0}))),
		 td("$row[2]"),td("$row[3]"),td("$row[4]"),td("$row[5]"));
	}
    }
    print '</table>';

##################################### REQUESTS ALREADY FINISHED #########################################

  } else {
      $sth = $dbh->prepare(qq{SELECT
	     TO_CHAR(datereceived,'MM-DD-YYYY-HH24-MI-SS'),
             TO_CHAR(datereceived,'MMDDYYYYHH24MISS'),
	     clientname, personassigned, title
	     FROM jobManage
             WHERE status = 'Finished'
             ORDER by datereceived DESC});
    $sth->execute or die "executing: $sth->errstr";

    print p({-align=>center},'<font size=+1>These are the requests that are already finished. You might want to find a case similar to the one of a current request</font>');

    print '<table border=0 align=center cellspacing=4 cellpadding=4>';
    print Tr({-bgcolor=>"#11EE88", -align=>center}, td(), td("Request ID"), td("Name of Issuer"),
	     td("Personassigned to it"), td("Title of Request"));

    while (@row = $sth->fetchrow_array) {
# Substituting spaces with %20 for cgi
	$temp = $row[2];
	$temp =~ s/\s/%20/g;

	print Tr(td(a({-href=>"/cgi-bin/JobTrackSuper/jobEdit.pl?page=old&date=$row[0]&client=$temp",
		       -onMouseOver=>"window.status='Retrieve information about this request that was assigned to [$row[3]]'; return true;",
		       -onMouseOut=>"window.status=' '; return true;"}, img({src=>"/tealbullet.gif", border=>0}))),
		 td("$row[1]"),td("$row[2]"),td({-align=>center}, "$row[3]"),td("$row[4]"));
    }
    print '</table>';

  }

  $dbh->disconnect;

########################################### WELCOME SCREEN ##############################################

} else {
# We get the name of the remote user as he/she entered it in the login dialog box
    print h1({-align=>center},"Welcome $ENV{REMOTE_USER}");
}

print end_html;
































