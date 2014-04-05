#!/usr/bin/perl -w

###################################################################
# Program: menu_action.cgi
# Author:  Isaac Grover <igrover@email.sjsu.edu>
# Date:    3 August 1999
# Purpose: to create a student record in the sql database
# Note:  - this script may contain leftover messages
#          from older projects, which should be removed
#          or modified before this script is deployed
#        - should only be called from student_login.cgi
#          or itself
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
# used for referer subroutine
$thisfile = 'http://dolphin.engr.sjsu.edu/cgi-bin/MajorForm/menu_action.cgi';
# where the student goes to login
$login_page = 'http://dolphin.engr.sjsu.edu/webteam/';
# the login script
$login_script = 'http://dolphin.engr.sjsu.edu/cgi-bin/MajorForm/student_login.cgi';
# location of sendmail on this system
$mailprog = '/usr/sbin/sendmail';
# make sure you change this
$author = 'yourname@domain.com';
# authorized referers
@referers = ('dolphin.engr.sjsu.edu');
@required = (bulletin, graddate);

# start up the status file and print environ. info to status_file
open (STATUS, ">$status_file");
  print STATUS "starting script:$ENV{'SCRIPT_NAME'}\n";
  print STATUS "SERVER_NAME:$ENV{'SERVER_NAME'}\n";
  print STATUS "REQUEST_METHOD:$ENV{'REQUEST_METHOD'}\n";
  print STATUS "SCRIPT_NAME:$ENV{'SCRIPT_NAME'}\n";
  print STATUS "HTTP_REFERER:$ENV{'HTTP_REFERER'}\n";
  print STATUS "REMOTE_ADDR:$ENV{'REMOTE_ADDR'}\n";
  print STATUS "HTTP_USER_AGENT:$ENV{'HTTP_USER_AGENT'}\n";
  print STATUS "---\n";
close (STATUS);

# see individual routines for more info
&no_fraud;
&parse_data;
&validate;

# same in create_profile.cgi
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

# same in create_profile.cgi
sub parse_data {
  @pairs=split(/&/,$buffer);
  foreach $pair(@pairs) {
    ($name, $value)=split(/=/,$pair);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][A-F0-9])/pack("C",hex($1))/eg;
    $FORM{$name} = $value;
  }
}

# this is the 'meat' of the script that makes use of the buttons
# formed from student_login.cgi
sub validate {
  open (STATUS, ">>$status_file");
    print STATUS "starting sub validate\n";
  close (STATUS);

  $in_db = 0;

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

  $lname=$row[0];
  $fname=$row[1];
  $midinit=$row[2];
  $ssn=$row[3];
  $phone=$row[4];
  $email=$row[6];

  open (STATUS, ">>$status_file");
    print STATUS "in_db:$in_db\n";
    print STATUS "ssn:$ssn;lname:$lname\n";
    print STATUS "referer:$ENV{'HTTP_REFERER'}\n";
    print STATUS "thisfile:$thisfile\n";
    print STATUS "login_script:$login_script\n";
    print STATUS "action:$FORM{'action'}\n";
  close (STATUS);

  if ($ENV{'HTTP_REFERER'} eq $login_script) {
    if ($FORM{'action'} eq 'view_record') { &view_record }
    if ($FORM{'action'} eq 'edit_record') { &view_record }
    if ($FORM{'action'} eq 'advising') { &return_html ('advising_form') }
#    if ($FORM{'action'} eq 'Create') { &create_mf }
#    if ($FORM{'action'} eq 'Edit') { &edit_mf }
#    if ($FORM{'action'} eq 'Submit') { &submit_mf }
  }
  if ($ENV{'HTTP_REFERER'} eq $thisfile) {
    if ($FORM{'action'} eq 'advise') { &add_record }
    foreach $keys (@required) {
      if ($FORM{$keys} eq '') {
        push (@unfilled, $keys);
      }
    }
    if (@unfilled) { &error ('unfilled') }
  }
  open (STATUS, ">>$status_file");
    print STATUS "ERROR:gone too far!\n";
  close (STATUS);
  exit;
}

# reads database and prints out the student's majorform
# (read-only)
sub create_mf {
  open (STATUS, ">>$status_file");
    print STATUS "starting sub create_mf\n";
  close (STATUS);
  print << "(END HTML)";
Content-type: text/html

<html>
<head><title>creating majorform</title></head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/cise/Images/cise_logo.gif"></center><br>
<center><font face=arial><b><font size=3>S<font size=2>AN <font size=3>J<font size=2>OSE <font size=3>S<font size=2>TATE <font size=3>U<font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C<font size=2>OLLEGE OF <font size=3>E<font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>D<font size=2>EPARTMENT OF <font size=3>C<font size=2>OMPUTER, <font size=3>I<font size=2>NFORMATION, AND <font size=3>S<font size=2>YSTEMS <font size=3>E<font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>M<font size=2>AJOR <font size=3>F<font size=2>ORM FOR <font size=3>B.S.<font size=2> <font size=3>C<font size=2>OMPUTER <font size=3>E<font size=2>NGINEERING</font></center><br>

<form method="POST">

<input type=hidden name=lname value="$lname">
<input type=hidden name=fname value="$fname">
<input type=hidden name=midinit value="$midinit">
<input type=hidden name=ssn value="$ssn">
<input type=hidden name=email value="$email">
<input type=hidden name=action value="Create">

<table>
  <tr>
    <td><font face=arial size=3>Name:</font></td>
    <td><font face=arial size=3><input type=text size=20 maxlength=20 value="$lname"></font></td>
    <td><font face=arial size=3><input type=text size=20 maxlength=20 value="$fname"></font></td>
    <td><font face=arial size=3><input type=text size=1 maxlength=1 value="$midinit"></font></td>
    <td><font face=arial size=3 color=white>xxxx</font></td>
    <td colspan=2><font face=arial size=3>SSN:</font></td>
    <td><font face=arial size=3><input type=text size=9 maxlength=9 value="$ssn"></font></td>
  </tr>
  <tr>
    <td></td>
    <td><font face=arial size=3><i>Last</i></font></td>
    <td><font face=arial size=3><i>First</i></font></td>
    <td colspan=2><i><font face=arial size=3>MI</i></font></td>
  </tr>
</table>
<table>
  <tr>
    <td><font face=arial size=3>Email address:</font></td>
    <td><font face=arial size=3><input type=text size=30 maxlength=50 value="$email"></font></td>
  </tr>
</table>
<table>
  <tr>
    <td colspan=2><font face=arial size=3>Minimum Number of Units for the Degree:</font></td>
    <td><font face=arial size=3>131</font></td>
    <td><font color=white>xxxx</font></td>
    <td><font face=arial size=3>Bulletin:</font></td>
    <td><font face=arial size=3><input type=text name=bulletin size=7 maxlength=7></font></td>
    <td><font color=white>xxxx</font></td>
    <td><font face=arial size=3>Proposed Graduation Date (MM/YYYY):</font></td>
    <td><font face=arial size=3><input type=text name=graddate size=7 maxlength=7></font></td>
  </tr>
</table>
<br>
<table>
  <tr>
    <td colspan=10 align=center><font face=arial size=3><b>ENGINEERING COMMONCORE (minimum 14 units)</b></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Dept.</b></font></td>
    <td><font face=arial size=2><b>No.</b></font></td>
    <td><font face=arial size=2><b>Title</b></font></td>
    <td><font face=arial size=2><b>Units</b></font></td>
    <td><font face=arial size=2><b>Grade</b></font></td>
    <td><font face=arial size=2><b>Dept.</b></font></td>
    <td><font face=arial size=2><b>No.</b></font></td>
    <td><font face=arial size=2><b>Title</b></font></td>
    <td><font face=arial size=2><b>Units</b></font></td>
    <td><font face=arial size=2><b>Grade</b></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=cc_d1 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=cc_c1 size=4 maxlength=4 value="46"></font></td>
    <td><font face=arial size=3><input type=text name=cc_t1 size=25 maxlength=50 value="Computer Engineering I"></font></td>
    <td><font face=arial size=3><input type=text name=cc_u1 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=cc_g1 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=cc_d4 size=4 maxlength=4 value="Engr"></font></td>
    <td><font face=arial size=3><input type=text name=cc_c4 size=4 maxlength=4 value="20"></font></td>
    <td><font face=arial size=3><input type=text name=cc_t4 size=25 maxlength=50 value="Design & Graphics"></font></td>
    <td><font face=arial size=3><input type=text name=cc_u4 size=3 maxlength=3 value="2.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=cc_g4 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=cc_inst1 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=cc_inst4 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=cc_d2 size=4 maxlength=4 value="EE"></font></td>
    <td><font face=arial size=3><input type=text name=cc_c2 size=4 maxlength=4 value="98"></font></td>
    <td><font face=arial size=3><input type=text name=cc_t2 size=25 maxlength=50 value="Intro. to Circuit Analysis"></font></td>
    <td><font face=arial size=3><input type=text name=cc_u2 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=cc_g2 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=cc_d5 size=4 maxlength=4 value="ME/MatE"></font></td>
    <td><font face=arial size=3><input type=text name=cc_c5 size=4 maxlength=4 value="109/153"></font></td>
    <td><font face=arial size=3><input type=text name=cc_t5 size=25 maxlength=50 value="Heat Transfer in Elect./Elec. Opt, Mag. Prop."></font></td>
    <td><font face=arial size=3><input type=text name=cc_u5 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=cc_g5 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=cc_inst2 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=cc_inst5 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=cc_d3 size=4 maxlength=4 value="Engr"></font></td>
    <td><font face=arial size=3><input type=text name=cc_c3 size=4 maxlength=4 value="10"></font></td>
    <td><font face=arial size=3><input type=text name=cc_t3 size=25 maxlength=50 value="Engr. Process & Tools"></font></td>
    <td><font face=arial size=3><input type=text name=cc_u3 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=cc_g3 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=cc_inst3 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td colspan=10 align=center><font face=arial size=3><b>REQUIRED COURSES (minimum 47 units)</b></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d1 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_c1 size=4 maxlength=4 value="124"></font></td>
    <td><font face=arial size=3><input type=text name=req_t1 size=25 maxlength=50 value="Electronic Design I"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u1 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g1 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d9 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_c9 size=4 maxlength=4 value="195A"></font></td>
    <td><font face=arial size=3><input type=text name=req_t9 size=25 maxlength=50 value="CmpE Senior Design I"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u9 size=3 maxlength=3 value="1.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g9 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst1 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=3></td>
    <td><font face=arial size=3></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst9 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d2 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_c2 size=4 maxlength=4 value="125"></font></td>
    <td><font face=arial size=3><input type=text name=req_t2 size=25 maxlength=50 value="Digital Design II"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u2 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g2 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d10 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_c10 size=4 maxlength=4 value="195B"></font></td>
    <td><font face=arial size=3><input type=text name=req_t10 size=25 maxlength=50 value="CmpE Senior Design II"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u10 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g10 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst2 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst10 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d3 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_c3 size=4 maxlength=4 value="126"></font></td>
    <td><font face=arial size=3><input type=text name=req_t3 size=25 maxlength=50 value="Alg. & Data Structures"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u3 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g3 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d11 size=4 maxlength=4 value="Engr"></font></td>
    <td><font face=arial size=3><input type=text name=req_d11 size=4 maxlength=4 value="100W"></font></td>
    <td><font face=arial size=3><input type=text name=req_t11 size=25 maxlength=50 value="Engineering Reports"</font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u11 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g11 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst3 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst11 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d4 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d4 size=4 maxlength=4 value="127"></font></td>
    <td><font face=arial size=3><input type=text name=req_t4 size=25 maxlength=50 value="Microprocessor Design I"</font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u4 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g4 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d12 size=4 maxlength=4 value="EE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d12 size=4 maxlength=4 value="110"></font></td>
    <td><font face=arial size=3><input type=text name=req_t12 size=25 maxlength=50 value="Network Analysis"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u12 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g12 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst4 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst12 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d5 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d5 size=4 maxlength=4 value="130"></font></td>
    <td><font face=arial size=3><input type=text name=req_t5 size=25 maxlength=50 value="Database Design I"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u5 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g5 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d13 size=4 maxlength=4 value="EE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d13 size=4 maxlength=4 value="122"></font></td>
    <td><font face=arial size=3><input type=text name=req_t13 size=25 maxlength=50 value="Electronic Design I"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u13 size=3 maxlength=3 value="4.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g13 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst5 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst13 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d6 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d6 size=4 maxlength=4 value="140"></font></td>
    <td><font face=arial size=3><input type=text name=req_t6 size=25 maxlength=50 value="Comp. Archit. & Design"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u6 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g6 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d14 size=4 maxlength=4 value="ISE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d14 size=4 maxlength=4 value="130"></font></td>
    <td><font face=arial size=3><input type=text name=req_t14 size=25 maxlength=50 value="Engineering Statistics"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u14 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g14 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst6 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst14 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d7 size=4 maxlength=4 value="CmpE"</font></td>
    <td><font face=arial size=3><input type=text name=req_d7 size=4 maxlength=4 value="142"></font></td>
    <td><font face=arial size=3><input type=text name=req_t7 size=25 maxlength=50 value="Operat. Systems Design"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u7 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g7 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d15 size=4 maxlength=4 value="ISE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d15 size=4 maxlength=4 value="165"></font></td>
    <td><font face=arial size=3><input type=text name=req_t15 size=25 maxlength=50 value="Software Engineering I"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u15 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g15 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst7 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst15 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=req_d8 size=4 maxlength=4 value="CmpE"></font></td>
    <td><font face=arial size=3><input type=text name=req_d8 size=4 maxlength=4 value="152"></font></td>
    <td><font face=arial size=3><input type=text name=req_t8 size=25 maxlength=50 value="Compiler Design"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u8 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g8 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=req_d16 size=4 maxlength=4 value="Math"></font></td>
    <td><font face=arial size=3><input type=text name=req_d16 size=4 maxlength=4 value="129A"></font></td>
    <td><font face=arial size=3><input type=text name=req_t16 size=25 maxlength=50 value="Linear Algebra"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_u16 size=3 maxlength=3 value="3.0"></font></td>
    <td align=center><font face=arial size=3><input type=text name=req_g16 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst8 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=req_inst16 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td colspan=10 align=center><font face=arial size=3><b>APPROVED TECHNICAL ELECTIVES (minimum 12 units)</b></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=ate_d1 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_c1 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_t1 size=25 maxlength=50></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_u1 size=3 maxlength=3></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_g1 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=ate_d4 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_c4 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_t4 size=25 maxlength=50></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_u4 size=3 maxlength=3></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_g4 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=ate_inst1 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=ate_inst4 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=ate_d2 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_c2 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_t2 size=25 maxlength=50></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_u2 size=3 maxlength=3></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_g2 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=ate_d5 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_c5 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_t5 size=25 maxlength=50></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_u5 size=3 maxlength=3></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_g5 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=ate_inst2 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=ate_inst5 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=ate_d3 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_c3 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_t3 size=25 maxlength=50></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_u3 size=3 maxlength=3></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_g3 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=ate_d6 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_c6 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=ate_t6 size=25 maxlength=50></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_u6 size=3 maxlength=3></font></td>
    <td align=center><font face=arial size=3><input type=text name=ate_g6 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=ate_inst3 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=ate_inst6 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr></tr>
  <tr>
    <td colspan=10 align=center><font face=arial size=3><b>COURSES REQUIRED IN PREPARATION FOR THE MAJOR</b></font></td>
  </tr>
  <tr>
    <td colspan=10 align=center><font face=arial size=3><b>Mathematics, Chemistry, Physics (minimum 26 units)</b></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=prep_d1 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c1 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t1 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u1 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g1 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=prep_d6 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c6 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t6 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u6 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g6 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst1 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst6 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=prep_d2 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c2 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t2 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u2 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g2 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=prep_d7 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c7 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t7 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u7 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g7 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst2 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst7 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=prep_d3 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c3 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t3 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u3 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g3 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=prep_d8 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c8 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t8 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u8 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g8 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst3 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst8 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=prep_d4 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c4 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t4 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u4 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g4 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=prep_d9 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c9 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t9 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u9 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g9 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst4 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst9 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
  <tr>
    <td><font face=arial size=3><input type=text name=prep_d5 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c5 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t5 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u5 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g5 size=1 maxlength=1></font></td>
    <td><font face=arial size=3><input type=text name=prep_d10 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_c10 size=4 maxlength=4></font></td>
    <td><font face=arial size=3><input type=text name=prep_t10 size=25 maxlength=50></font></td>
    <td><font face=arial size=3><input type=text name=prep_u10 size=3 maxlength=3></font></td>
    <td><font face=arial size=3><input type=text name=prep_g10 size=1 maxlength=1></font></td>
  </tr>
  <tr>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst5 size=30 maxlength=40 value="San Jose State University"></font></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2></td>
    <td><font face=arial size=2><b>Institution</b></font></td>
    <td colspan=2><font face=arial size=3><input type=text name=prep_inst10 size=30 maxlength=40 value="San Jose State University"></font></td>
  </tr>
</table>
<br>
<center><font face=arial size=3><input type="submit" value="Create majorform"></font></center>
</form>
</body>
</html>
(END HTML)
  open (STATUS, ">>$status");
    print STATUS "done w/create_mf\n";
  close (STATUS);
  exit;
}

# just sends student record to browser
# unless action=update then an 'update' button appears
sub view_record {
  open (STATUS, ">>$status_file");
    print STATUS "starting sub view_record\n";
  close (STATUS);

  print << "(END HTML)";
Content-type: text/html

<html>
<head><title>view record</title></head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/images/jpgs/college.jpg"></center><br>
<center><font face=arial><b><font size=3>S</font size=2>AN <font size=3>J</font size=2>OSE <font size=3>S</font size=2>TATE <font size=3>U</font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C</font size=2>OLLEGE OF <font size=3>E</font size=2>NGINEERING</font></center>
<br>
<form method="POST">
<font face=arial size=3>
SSN: $ssn<br>
Name: $lname, $fname $midinit<br>
Home Phone: <input type=text name=phone size=14 maxlength=14 value="$phone"><br>
Email: <input type=text name=email size=30 maxlength=30 value="$email"><br>
(END HTML)
  if ($FORM{'action'} eq 'edit_record') {
    print "<br><input type=submit value=\"Update\">";
  }
  print << "(END HTML)"; 
</form>
</font>
</body>
</html>
(END HTML)
  exit;
}

# adds record to database and sends email to advisor and student
sub add_record {
  open (STATUS, ">>$status");
    print STATUS "starting sub add_record\n";
  close (STATUS);

  open (MAIL,"|$mailprog -t");
    print MAIL "From: $email\n";
    print MAIL "To: $author\n";
    print MAIL "Subject: SSN:$ssn\n\n";
    print MAIL "--- ENVIRONMENT INFO ---\n\n";
    print MAIL "HTTP_REFERER:$ENV{'HTTP_REFERER'}\n";
    print MAIL "REMOTE_IDENT:$ENV{'REMOTE_IDENT'}\n";
    print MAIL "REMOTE_USER:$ENV{'REMOTE_USER'}\n";
    print MAIL "DOCUMENT_URI:$ENV{'DOCUMENT_URI'}\n";
    print MAIL "REMOTE_HOST:$ENV{'REMOTE_HOST'}\n";
    print MAIL "REMOTE_ADDR:$ENV{'REMOTE_ADDR'}\n";
    print MAIL "HTTP_USER_AGENT:$ENV{'HTTP_USER_AGENT'}\n";
    print MAIL "AUTH_TYPE:$ENV{'AUTH_TYPE'}\n\n";
    print MAIL "--- START OF FORM ---\n\n";
    print MAIL "$ssn:$lname:$fname:$midinit:$email:$FORM{'bulletin'}:$FORM{'graddate'}:\n";
    print MAIL "\n--- END OF FORM ---\n";
  close (MAIL);

  open (MAIL,"|$mailprog -t");
    print MAIL "From: $author\n";
    print MAIL "To: $FORM{'email'}\n";
    print MAIL "Subject: Online Advising Submission\n\n";
    print MAIL "Greetings.\n\n";
    print MAIL "This email is being sent to you as proof of your submission to the Online Advising database.\n\n";
    print MAIL "Database Author and Maintainer\n\n";

    print MAIL "--- START OF FORM ---\n\n";

    print MAIL "SSN: $ssn\n";
    print MAIL "Name: $lname, $fname $midinit\n";
    print MAIL "Expected graduation date: $FORM{'graddate'}\n";
    print MAIL "Bulletin: $FORM{'bulletin'}\n\n";

    print MAIL "\n--- END OF FORM ---\n";
  close (MAIL);

  open (MAIL,"|$mailprog -t");
    print MAIL "From: $FORM{'email'}\n";
    print MAIL "To: $FORM{'advisor'}\n";
    print MAIL "Subject: Online Advising Submission\n\n";
    print MAIL "Greetings.\n\n";
    print MAIL "I plan to take these classes next semester. Please review.\n\n";
    print MAIL "$fname $midinit $lname\n";

    print MAIL "--- START OF FORM ---\n\n";

    print MAIL "SSN: $ssn\n";
    print MAIL "Name: $lname, $fname $midinit\n";

    print MAIL "\n--- END OF FORM ---\n";
  close (MAIL);

  open (STATUS, ">>$status_file");
    print STATUS "done mailing, now what?\n";
  close (STATUS);
  &return_html ('record_added');
}

# contains all positive/neutral html messages
sub return_html {
  local ($message) = @_;
  open (STATUS, ">>$status_file");
    print STATUS "return_html:$message\n";
  close (STATUS);

  if ($message eq 'record_added') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/cise/Images/cise_logo.gif"></center><br>
<center><font face=arial><b><font size=3>S<font size=2>AN <font size=3>J<font size=2>OSE <font size=3>S<font size=2>TATE <font size=3>U<font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C<font size=2>OLLEGE OF <font size=3>E<font size=2>NGINEERING</font></center>
Your majorform has been successfully added to the scratch database.<br>
<br>
Also, a message has been sent to the email address you specified, $email, containing the information you submitted.
Please keep this message for your records as proof of your majorform submission.<br>
<br>
</body>
</html>
(END HTML)
    open (STATUS, ">>$status_file");
      print STATUS "i should be done with return_html now.\n";
    close (STATUS);
    exit;
  }
  elsif ($message eq 'advising_form') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head><title>online advising form</title></head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/images/jpgs/college.jpg"></center><br>
<center><font face=arial><b><font size=3>S<font size=2>AN <font size=3>J<font size=2>OSE <font size=3>S<font size=2>TATE <font size=3>U<font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C<font size=2>OLLEGE OF <font size=3>E<font size=2>NGINEERING<font></center>
<center><font face=arial><b><font size=3>O<font size=2>NLINE <font size=3>A<font size=2>DVISING <font size=3>F<font size=2>ORM</font></center><br>

<font face=arial,helvetica size=2>
<form method="POST">

<input type=hidden name=lname value="$lname">
<input type=hidden name=fname value="$fname">
<input type=hidden name=midinit value="$midinit">
<input type=hidden name=ssn value="$ssn">
<input type=hidden name=email value="$email">
<input type=hidden name=action value="advise">

<center>Choose your advisor:</center>
<center>
  <select name="advisor">
    <option value=""></option>
    <option value="shpham\@email.sjsu.edu">Professor Somebody</option>
    <option value="shpham\@email.sjsu.edu">Dr. Scott Pham</option>
  </select>
</center>
<br>
<center><table>
  <tr>
    <td><font face=arial,helvetica size=2>Core Courses You Took Last Semester</td>
    <td><font face=arial,helvetica size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
    <td><font face=arial,helvetica size=2>Core Courses You Plan To Take Next Semester</font></td>
  </tr>
  <tr><td colspan=3></td></tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>1.&nbsp;<input type=text name=core1_last></font></td>
    <td><font face=arial,helvetica size=2>1.&nbsp;<input type=text name=core1_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>2.&nbsp;<input type=text name=core2_last></font></td>
    <td><font face=arial,helvetica size=2>2.&nbsp;<input type=text name=core2_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>3.&nbsp;<input type=text name=core3_last></font></td>
    <td><font face=arial,helvetica size=2>3.&nbsp;<input type=text name=core3_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>4.&nbsp;<input type=text name=core4_last></font></td>
    <td><font face=arial,helvetica size=2>4.&nbsp;<input type=text name=core4_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>5.&nbsp;<input type=text name=core5_last></font></td>
    <td><font face=arial,helvetica size=2>5.&nbsp;<input type=text name=core5_next></font></td>
  </tr>
  <tr><td colspan=3></td></tr>
  <tr><td colspan=3></td></tr>
  <tr>
    <td><font face=arial,helvetica size=2>Non-Core Courses You Took Last Semester</font></td>
    <td><font face=arial,helvetica size=2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></td>
    <td><font face=arial,helvetica size=2>Non-Core Courses You Plan To Take Next Semester</font></td>
  </tr>
  <tr><td colspan=3></td></tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>1.&nbsp;<input type=text name=noncore1_last></font></td>
    <td><font face=arial,helvetica size=2>1.&nbsp;<input type=text name=noncore1_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>2.&nbsp;<input type=text name=noncore2_last></font></td>
    <td><font face=arial,helvetica size=2>2.&nbsp;<input type=text name=noncore2_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>3.&nbsp;<input type=text name=noncore3_last></font></td>
    <td><font face=arial,helvetica size=2>3.&nbsp;<input type=text name=noncore3_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>4.&nbsp;<input type=text name=noncore4_last></font></td>
    <td><font face=arial,helvetica size=2>4.&nbsp;<input type=text name=noncore4_next></font></td>
  </tr>
  <tr>
    <td colspan=2><font face=arial,helvetica size=2>5.&nbsp;<input type=text name=noncore5_last></font></td>
    <td><font face=arial,helvetica size=2>5.&nbsp;<input type=text name=noncore5_next></font></td>
  </tr>
</table></center>
</font>
<br>
<br>
<center><font face=arial,helvetica size=2><input type=submit value="Submit">&nbsp;&nbsp;<input type=reset value="Start Over"></font></center>
</body>
</html>
(END HTML)
    exit;
  }
  open (STATUS, ">>$status_file");
    print STATUS "i should be done now.\n";
  close (STATUS);
  exit;
}

# contains all negative html messages
sub error {
  local ($message) = @_;
  open (STATUS, ">>$status_file");
    print STATUS "error:$message\n";
  close (STATUS);

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
  }
  elsif ($message eq 'bad_referer') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head>
<meta http-equiv="refresh" content="0; URL=http://www.engr.sjsu.edu/~testcgi/">
<title>CmpE Majorform: Unexpected Error</title></head>
<body bgcolor=white text=black background="http://www.engr.sjsu.edu/cise/Images/tile-sjsu.gif">
<center><img src="http://www.engr.sjsu.edu/cise/Images/cise_logo.gif"></center><br>
<center><font face=arial><b><font size=3>S</font size=2>AN <font size=3>J</font size=2>OSE <font size=3>S</font size=2>TATE <font size=3>U</font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C</font size=2>OLLEGE OF <font size=3>E</font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>D</font size=2>EPARTMENT OF <font size=3>C</font size=2>OMPUTER, <font size=3>I</font size=2>NFORMATION, AND <font size=3>S</font size=2>YSTEMS <font size=3>E</font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>M</font size=2>AJOR <font size=3>F</font size=2>ORM FOR <font size=3>B.S.</font size=2> <font size=3>C</font size=2>OMPUTER <font size=3>E</font size=2>NGINEERING</font></center><br>
</body>
</html>
(END HTML)
  }
  elsif ($message eq 'bad_method') {
    print "Location: $ENV{'HTTP_REFERER'}\n\n";
  }
  elsif ($message eq 'unfilled') {
    print << "(END HTML)";
Content-type: text/html

<html>
<head><title>error:$message</title></head>
<body bgcolor=white text=black>
<center><img src="http://www.engr.sjsu.edu/cise/Images/cise_logo.gif"></center><br>
<center><font face=arial><b><font size=3>S</font size=2>AN <font size=3>J</font size=2>OSE <font size=3>S</font size=2>TATE <font size=3>U</font size=2>NIVERSITY</font></center>
<center><font face=arial><b><font size=3>C</font size=2>OLLEGE OF <font size=3>E</font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>D</font size=2>EPARTMENT OF <font size=3>C</font size=2>OMPUTER, <font size=3>I</font size=2>NFORMATION, AND <font size=3>S</font size=2>YSTEMS <font size=3>E</font size=2>NGINEERING</font></center>
<center><font face=arial><b><font size=3>M</font size=2>AJOR <font size=3>F</font size=2>ORM FOR <font size=3>B.S.</font size=2> <font size=3>C</font size=2>OMPUTER <font size=3>E</font size=2>NGINEERING</font></center><br>
<br>
<font face=arial size=3>
Some of the fields may have been inadvertently left blank.  Please correct
them.<br><br>
(END HTML)

  foreach $keys (@unfilled) {
    print STDOUT "<ul><li><b>$keys</b></ul>\n";
  }

  print << "(END HTML)";
<br>
</font>
</body>
</html>
(END HTML)
  }
  exit;
}

# end of record
