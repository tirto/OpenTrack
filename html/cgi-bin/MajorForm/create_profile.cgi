#!/usr/bin/perl -w

###################################################################
# Program: create_profile.cgi
# Author:  Isaac Grover <igrover@email.sjsu.edu>
# Date:    3 August 1999
# Purpose: to create a student record in the sql database
# Note:  - this script may contain leftover messages
#          from older projects, which should be removed
#          or modified before this script is deployed
#        - should only be called from $login_page
###################################################################

# includes the DBI module which contains commands to interface
# with the sql daemon
use DBI;

# set up environ. vars. to point to the database
BEGIN {
  $ENV{ORACLE_HOME} = '/projects/oracle';
  $ENV{ORACLE_SID} = 'rdb2';
}

# not necessary for functionality, but useful for debugging
$status_file = '/home/httpd/cgi-bin/MajorForm/status.txt';
# where the student goes to login
$login_page = 'http://dolphin.engr.sjsu.edu/webteam/';
# authorized referers
@referers = ('dolphin.engr.sjsu.edu');
# can't login without a ssn!
@required = (ssn);

# start up the status file and print environ. info to status_file
open (STATUS, ">$status_file");
  print STATUS "starting script:$ENV{'SCRIPT_NAME'}\n";
  print STATUS "SERVER_NAME:$ENV{'SERVER_NAME'}\n";
  print STATUS "REQUEST_METHOD:$ENV{'REQUEST_METHOD'}\n";
  print STATUS "SCRIPT_NAME:$ENV{'SCRIPT_NAME'}\n";
  print STATUS "HTTP_REFERER:$ENV{'HTTP_REFERER'}\n";
  print STATUS "REMOTE_ADDR:$ENV{'REMOTE_ADDR'}\n";
  print STATUS "HTTP_USER_AGENT:$ENV{'HTTP_USER_AGENT'}\n";
  print STATUS "QUERY_STRING:$ENV{QUERY_STRING}\n\n";
  print STATUS "---\n";
close (STATUS);

# see individual routines for more info
&no_fraud;
&parse_data;
if (&validate) { &authorize; }

# validate request_method and referer
# prevents clients from setting up mirror pages on remote sites
sub no_fraud {
  local($check_referer) = 0;
  if ($ENV{'REQUEST_METHOD'} eq "POST") {
    read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    if (length($buffer) < 5) {
       $buffer = $ENV{QUERY_STRING};
    }
  }
  else {
    &error ('bad_method')
  }

  if ($ENV{'HTTP_REFERER'}) {
    foreach $referer (@referers) {
      if ($ENV{'HTTP_REFERER'} =~ m|https?://([^/]*)$referer|i) {
        $check_referer = 1;
        last;
      }
    }
  }
  else {
    $check_referer = 1;
  }
  if ($check_referer != 1) { &error ('bad_referer') }
}

# read incoming data stream into $FORM{'variable'} syntax
sub parse_data {
  @pairs=split(/&/,$buffer);
  foreach $pair(@pairs) {
    ($name, $value)=split(/=/,$pair);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][A-F0-9])/pack("C",hex($1))/eg;
    $FORM{$name} = $value;
  }
}

# make sure all required variables are filled
# otherwise send a message
sub validate {
  open (STATUS, ">>$status_file");
    print STATUS "starting sub validate\n";
  close (STATUS);
  foreach $keys (@required) {
    if ($FORM{$keys} eq '') {
      push (@unfilled, $keys);
    }
  }
  if (@unfilled) { &error ('unfilled') }

  return 1;
}

# look for ssn in database
# if not exist, go to &add_record
sub authorize {
  open (STATUS, ">>$status_file");
    print STATUS "starting sub authorize\n";
  close (STATUS);
  local ($auth_db, $record);
  $auth_db = 1;

  ### read from db here
  $dbh = DBI->connect('DBI:Oracle:', 'insider', 'master',
{PrintError=>1,RaiseError=>1}) or die "connecting: $DBI::errsrtr";
  $sth = $dbh->prepare(qq{SELECT
    studentInfor.lastname,
    studentInfor.firstname,
    studentInfor.middleinit,
    studentInfor.ssnumber,
cd
    studentInfor.phone,
    studentInfor.major,
    studentInfor.email,
    studentInfor.bod,
    studentInfor.dategraduate,
    studentInfor.catalog,
    studentInfor.numofcourses
    FROM studentInfor
    WHERE studentInfor.ssnumber = '$FORM{"ssn"}'});
  $sth->execute or die "executing: $sth->errstr";

  @row = $sth->fetchrow_array;

  open (STATUS, ">>$status_file");
    print STATUS "---\n";
    foreach $keys (@row) {
      print STATUS "$keys\n";
    }
    print STATUS "---\n";
  close (STATUS);

  if ($row[3] eq $FORM{'ssn'}) {
    $auth_db = 0;
  }

  open (STATUS, ">>$status_file");
    print STATUS "row3:$row[3]; ssn:$FORM{'ssn'}; auth_db:$auth_db\n";
  close (STATUS);

  if ($auth_db) {
    open (STATUS, ">>$status_file");
      print STATUS "row_array does not exist\n";
    close (STATUS);
    &add_record;
  }
  else {
    open (STATUS, ">>$status_file");
      print STATUS "row_array exists\n";
    close (STATUS);
    &error ('ssn_exists');
  }
}

# add the student's info to the database
# and return a message
sub add_record {
  open (STATUS, ">>$status_file");
    print STATUS "starting sub add_record\n";
  close (STATUS);

  ##### add to db here
  $sth = $dbh->prepare(qq{insert into studentInfor values
    (?,?,?,?,?,?,?,?,?,?,?)});
  $sth->bind_param(1,$FORM{'lname'}); # lastname
  $sth->bind_param(2,$FORM{'fname'}); # firstname
  $sth->bind_param(3,$FORM{'midinit'}); # middleinit
  $sth->bind_param(4,$FORM{'ssn'}); # ssnumber
  $sth->bind_param(5,$FORM{'phone'}); # phone
  $sth->bind_param(6,$FORM{'major'}); # major
  $sth->bind_param(7,$FORM{'email'}); # email
  # $sth->bind_param(8,'00/00/00'); # bod
  $sth->bind_param(9,$FORM{'graddate'}); # dategraduate
  $sth->bind_param(10,$FORM{'bulletin'}); # catalog
  # $sth->bind_param(11,'0'); # numofcourses
  $sth->finish;
  $rv = $dbh->commit or die $dbh->errstr;
  $dbh->disconnect;

  open (STATUS, ">>$status_file");
    print STATUS "record added?: $rv\n";
  close (STATUS);

  &return_html ('record_added');
}

# contains all the affirmative html messages
sub return_html {
  local ($message) = @_;

  if ($message eq 'record_added') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head>
<meta http-equiv="refresh" content="10; URL=$login_page">
<title>Submission accepted</title>
</head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/images/jpgs/college.jpg"></center><br>
<center><font face=arial><b><font size=3>S</font size=2>AN <font size=3>J</font size=2>OSE <font size=3>S</font size=2>TATE <font size=3>U</font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C</font size=2>OLLEGE OF <font size=3>E</font size=2>NGINEERING</font></center>
Submission successful.<br>
<br>
You will now be re-directed to the <a href="http://student.engr.sjsu.edu/~igrover/">main login page</a>.
</body>
</html>
(END HTML)
    exit;
  }
}

# contains all the negative html messages
sub error {
  local ($message) = @_;

  if ($message eq 'ssn_exists') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head><title>CmpE Majorform: SSN Already Exists</title></head>
<body bgcolor=white text=black background="http://www.engr.sjsu.edu/cise/Images/tile-sjsu.gif">
<center><img src="http://www.engr.sjsu.edu/cise/Images/cise_logo.gif"></center><br>
<center><font face=arial><b><font size=3>S</font size=2>AN <font size=3>J</font size=2>OSE <font size=3>S</font size=2>TATE <font size=3>U</font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C</font size=2>OLLEGE OF <font size=3>E</font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>D</font size=2>EPARTMENT OF <font size=3>C</font size=2>OMPUTER, <font size=3>I</font size=2>NFORMATION, AND <font size=3>S</font size=2>YSTEMS <font size=3>E</font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>M</font size=2>AJOR <font size=3>F</font size=2>ORM FOR <font size=3>B.S.</font size=2> <font size=3>C</font size=2>OMPUTER <font size=3>E</font size=2>NGINEERING</font></center><br>
<br>
<font face=arial size=3>
We're sorry.  That SSN already exists in our database.<br>
Please verify that all information is correct and try again.<br><br>
If you feel that this message has been displayed in error,<br>
please email the <a href="http://www.engr.sjsu.edu/cise/feedback/">webmaster</a> and explain your situation in detail.<br><br>
Thank you.<br>
</font>
</body>
</html>
(END HTML)
    exit;
  }
  elsif ($message eq 'bad_referer') {
    print "Location: $login_page\n\n";
    exit;
  }
  elsif ($message eq 'bad_method') {
    print "Location: $login_page\n\n";
    exit;
  }
  elsif ($message eq 'unfilled') {
    open (STATUS, ">>$status_file");
      print STATUS "error: unfilled\n";
    close (STATUS);
    print << "(END HTML)";
Content-type: text/html

<html>
<head><title>Engineering Student Profile Creation Page</title></head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/images/jpgs/college.jpg"></center><br>
<center><font face=arial><b><font size=3>S</font size=2>AN <font size=3>J</font size=2>OSE <font size=3>S</font size=2>TATE <font size=3>U</font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C</font size=2>OLLEGE OF <font size=3>E</font size=2>NGINEERING</font></center><br>
<font face=arial size=3> Oops!<br>
<br>
Some of the fields may have been inadvertently left blank.  Please use the
'back' function of your browser and correct the following fields:<br><br>
(END HTML)
  foreach $keys (@unfilled) {
    print STDOUT "<ul><b>$keys</b></ul>\n";
  }
  print << "(END HTML)";
<br>
</font>
</body>
</html>
(END HTML)
    exit;
  }
}

# end of script
