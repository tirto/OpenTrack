#!/usr/bin/perl

###################################################################
# Program: student_login.cgi
# Author:  Isaac Grover <igrover@email.sjsu.edu>
# Date:    3 August 1999
# Purpose: allows a student to login and view and edit record and majorform
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
# where students go to create a profile
$new_student_page = 'http://dolphin.engr.sjsu.edu/webteam/new_student.html';
# script used when student clicks on menu buttons
$menu_action_page = 'http://dolphin.engr.sjsu.edu/cgi-bin/MajorForm/menu_action.cgi';
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

# see individual routines
&no_fraud;
&parse_data;
if (&validate) { &authorize; }

# same in create_profile.cgi
sub no_fraud {
  local($check_referer) = 0;
  open (STATUS, ">>$status_file");
    print STATUS "starting sub no_fraud\n";
    print STATUS "$ENV{'REQUEST_METHOD'}\n";
  close (STATUS);
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

# same in create_profile.cgi
sub parse_data {
  open (STATUS, ">>$status_file");
    print STATUS "sub parse_data\n";
  close (STATUS);
  @pairs=split(/&/,$buffer);
  foreach $pair(@pairs) {
    ($name, $value)=split(/=/,$pair);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][A-F0-9])/pack("C",hex($1))/eg;
    $FORM{$name} = $value;
  }
}

# same in create_profile.cgi
sub validate {
  open (STATUS, ">>$status_file");
    print STATUS "sub validate\n";
  close (STATUS);
  foreach $keys (@required) {
    if ($FORM{$keys} eq '') {
      push (@unfilled, $keys);
    }
  }
  if (@unfilled) { &error ('unfilled') }

  return 1;
}

# looks for student info in database and creates button
# values accordingly
sub authorize {
  local ($record);
  $in_db = 0;
  $ssn = $FORM{'ssn'};

### read from database here
  $dbh = DBI->connect('DBI:Oracle:', 'insider', 'master',
{PrintError=>1,RaiseError=>1}) or die "connecting: $DBI::errsrtr";
  $sth = $dbh->prepare(qq{SELECT
    studentInfor.lastname,
    studentInfor.firstname,
    studentInfor.middleinit,
    studentInfor.ssnumber,
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
  $dbh->disconnect;

  open (STATUS, ">>$status_file");
    print STATUS "---\n";
    foreach $keys (@row) {
      print STATUS "$keys\n";
    }
    print STATUS "---\n";
  close (STATUS);

### must fake it until above routine is fixed
  $in_db = 1;
  $mfvalue2 = "* Edit";

  $mfvalue1 = "Create";

  if ($in_db == 1) { &return_html ('display_menu') }
    else { &error ('not_in_db') }
}

# returns affirmative/neutral html messages
sub return_html {
  local ($message) = @_;
  open (STATUS, ">>$status_file");
    print STATUS "return_html:$message\n";
  close (STATUS);

  if ($message eq 'display_menu') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head><title>web-friendly prototype</title></head>
<body bgcolor=white text=black>
<font face=arial,helvetica size=3>
</font>
<center>
<table>
  <tr>
    <td>
      (email:<a href="mailto:$email">$fname $lname</a>)
    </td>
    <td>
      <form method="POST" action="$menu_action_page" target="bottommenu">
        <input type=hidden name=ssn value="$ssn">
        <input type=hidden name=action value="view_record">
        <input type=submit value="View your record">
      </form>
    </td>
    <td>
      <form method="POST" action="$menu_action_page" target="bottommenu">
        <input type=hidden name=ssn value="$ssn">
        <input type=hidden name=action value="edit_record">
        <input type=submit value="Edit your record">
      </form>
    </td>
    <td>
      <form method="POST" action="$menu_action_page" target="bottommenu">
        <input type=hidden name=ssn value="$ssn">
        <input type=hidden name=action value="advising">
        <input type=submit value="Online advising">
      </form>
    </td>
    <td>
      <form method="POST" action="$menu_action_page" target="bottommenu">
        <input type=hidden name=ssn value="$ssn">
        <input type=hidden name=action value="$mfvalue1">
        <input type=submit value="$mfvalue1 majorform">
      </form>
    </td>
(END HTML)
    if ($mfvalue2 ne "") {
      print "    <td>\n";
      print "          <form method=POST action=\"$menu_action_page\" target=\"bottommenu\">";
      print "            <input type=hidden name=ssn value=\"$ssn\">";
      print "            <input type=hidden name=action value=\"$mfvalue2\">";
      print "            <input type=submit value=\"$mfvalue2 majorform\">";
      print "          </form>";
      print "        </td>";
    }
    if ($mfvalue3 ne "") {
      print "        <td>";
      print "          <form method=POST action=\"$menu_action_page\" target=\"bottommenu\">";
      print "            <input type=hidden name=ssn value=\"$ssn\">";
      print "            <input type=hidden name=action value=\"$mfvalue3\">";
      print "            <input type=submit value=\"$mfvalue3 majorform\">";
      print "          </form>";
      print "        </td>";
    }
    print << "(END HTML)";
  </tr>
</table>
</center>
</body>
</html>
(END HTML)
  }
  exit;
}

# returns negative html messages
sub error {
  local ($message) = @_;
  open (STATUS, ">>$status_file");
    print STATUS "error:$message\n";
  close (STATUS);
  if ($message eq 'bad_referer') {
    print "Location: $login_page\n\n";
  }
  elsif ($message eq 'bad_method') {
    print "Location: $login_page\n\n";
  }
  elsif ($message eq 'unfilled') {
    print "Location: $ENV{'HTTP_REFERER'}\n\n";
  }
  elsif ($message eq 'not_in_db') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head>
<title>error: not in db</title>
<meta name="refresh" content="10; URL=$new_student_page">
</head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/images/jpgs/college.jpg"></center><br>
<center><font face=arial><b><font size=3>S<font size=2>AN <font size=3>J<font size=2>OSE <font size=3>S<font size=2>TATE <font size=3>U<font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C<font size=2>OLLEGE OF <font size=3>E<font size=2>NGINEERING</font></center><br>
<font face=arial,helvetica size=3><br>
Your Social Security Number was not found in our database.  If you feel
this message was generated in error, please email <a
href="mailto:$author">me</a>.
</body>
</html>
(END HTML)
  }
  exit;
}

# end of script
