#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;


BEGIN
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

print header,
    start_html(-title=>'College Of Engineering Job Tracking System',
	       -BGCOLOR=>"white");

print h1({-align=>center}, "Job Tracking System");
print '<center><img src="http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"></center>';

print '<br><br>';
print '<hr width=30%>';

if (!param()){
  LoginDialog();
}
elsif (param('submit')){
  SearchRequest(param('email'), param('id'));
}

print '<br><br>';
print '<hr width=30%>';

print end_html();

sub LoginDialog() {
  print '<form action="http://dolphin.engr.sjsu.edu/cgi-bin/checkStatus.cgi" method="post" enctype="application/x-www-form-urlencoded">';

  print '<table border=0 align=center width=50%>',
	'<tr>',
	'<td align=right>Email: </td>',
	'<td align=left><input type="text" name="email" maxlength="30" size="30"></td>',
	'</tr>',
	'<tr>',
	'<td align=right>Request ID: </td>',
	'<td align=left><input type="text" name="id" maxlength=14 size=30></td>',
	'</tr>',
	'</table>';

  print '<table border=0 align=center width=30%>',
	'<tr>',
	'<td align=center><input type=submit name=submit value=Submit></td>',
	'<td align=center><input type=reset name=reset value=Reset></td>',
	'</tr>',
	'</table>';
  print '</form>';
  print '<center>Make sure that you use the same email address with the one that you submitted in the request form</center>';
}

sub SearchRequest() {

  my $email = shift @_;
  my $id = shift @_;

# Query for requests that matches the ID and email address
# If there are matches, display them to users.
# At this point user is validated valid.
# If there is no matches, try with ID only
# If there is a match, send it to email address in the request form.

  # We get the login and password to access the database
  open(FILE,"/home/httpd/.jobDBAccess");
  $DBlogin = <FILE>;
  $DBpassword = <FILE>;
  # Let's get rid of that newline character
  chop $DBlogin;
  chop $DBpassword;
  
  my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
      or die "connecting:  $DBI::errstr";

  my $sth = $dbh->prepare(qq{SELECT 
                             jobRequest.jobdescription,
                             jobManage.status,
			     jobManage.personassigned,
                             TO_CHAR(jobManage.datefinished, 'MM-DD-YYYY')
                             FROM jobRequest, jobManage
			     WHERE
                             jobRequest.email = '$email' AND
			     TO_CHAR(jobRequest.datereceived, 'MMDDYYYYHH24MISS') = '$id' AND
                             TO_CHAR(jobManage.datereceived, 'MMDDYYYYHH24MISS') = '$id'}); 
  $sth->execute or die "Executing: $sth->errstr";
 
  @row = $sth->fetchrow_array;
  $sth->finish;

  if ($#row > 0){
    if ($row[1] eq 'Unassigned') {
      print "Request: $id<br><br>";
      print "Description: $row[0]<br><br>";
      print "Status: has not been inprogress yet.<br><br>";
      print "We will have someone to work on this request very soon<br>";
    }
    elsif ($row[1] ne 'Unassigned') {
      my $sth = $dbh->prepare(qq{SELECT email FROM assignlist
				 WHERE name = '$row[2]'});
      $sth->execute or die "Executing: $sth->errstr";
      @name = $sth->fetchrow_array;
      $sth->finish;

      print "Request: $id<br><br>";
      print "Description: $row[0]<br><br>";
      if ($row[1] eq 'Active') {
        print "Status: In progress. ";
        print "$row[2] is working on this request.<br><br>";
      }
      else {
        print "Status: Finished on $row[3] by $row[2].<br><br>"
      }

      print "If you have any question, please email $row[2] at $name[0]<br>";
    }
  }
  else {
    print "<center>Request not found<br><\/center>";
    print "<hr>";
    LoginDialog();
  }
}
