#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;

###############################################################################

# Project:	Job Tracking System
# File:		mainmenu.cgi
# By:		Phuoc Diec
# Date:		Augus 2, 1999
# Description:
#   Generate menu bar for management module.

#   This menu contains listing requests, searching requests, editing personel
#   list, and exiting functions. Other functions such as deleting requests and 
#   viewing requests in detail are generated by listing.cgi scripts. 

#   For the searching function, users have following options:
#   search by request ID, search by date, search by a range of date, search by
#   names of the requesters, and by names of the persons who respond for the
#   requests.

#   For the listing function, users have following options:
#   List new requests, list inactive requests, list finished requests, and all.

#   The options for the listing and searching functions are displayed in the
#   option page when one of the function is selected. These option pages are
#   generated by JavaScripts included in this menu page. Results are displayed
#   in the display page.

#   Each of the option page for the searching function has a JavaScript that
#   does an error checking for that page before sending the searching option
#   to listing.cgi script which handles listing and searching functions.

###############################################################################

######### SET UP ENVIRONMENT VARIABLES TO THE DATABASE ##########
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


########## GET ASSIGN LIST FROM THE DATABASE ##########
$userid = $ENV{REMOTE_USER};
$sth = $dbh->prepare(qq{SELECT name
                        FROM assignList WHERE assigner = '$userid'
                        ORDER by name});
$sth->execute or die "Executing: $sth->errstr";
$list[0] = 'Responder';
$i = 1;
while (@row = $sth->fetchrow_array) {
  $list[$i++] = $row[0];
}

########## PRINT OUT THE REQUIRED HTTP Content-type:'text/html' ##########
print header();

########## PRINT OUT HTML HEADER AND OPEN <BODY> TAG ##########
#print start_html(-title=>'Hello World', -bgcolor=>'#ffffff');
print '<HTML><HEAD><TITLE>Hello World</TITLE>', "\n";

print '<script language="JavaScript">', "\n";

print 'function BlankPage(doc) {', "\n",
      'var optiondoc = doc', "\n",
      'optiondoc.open()', "\n",
      'optiondoc.writeln("<HTML><HEAD>")', "\n",
      'optiondoc.writeln("<TITLE>Edit Option Page</TITLE>")', "\n",
      'optiondoc.writeln("</HEAD>")', "\n",
      q/optiondoc.writeln('<BODY BGCOLOR="#FFFFFF">')/, "\n",
      'optiondoc.writeln("</BODY></HTML>")', "\n",
      'optiondoc.close()', "\n",
      '}', "\n\n";

print 'function ShowSearchOptions() {', "\n",
      'var optiondoc = top.frames[1].document', "\n",
      'optiondoc.open()', "\n",
      'optiondoc.writeln("<HTML><HEAD>")', "\n",
      'optiondoc.writeln("<TITLE>Search Option Page</TITLE>")', "\n",
      'if (document.forms[0].searchby.selectedIndex == 1) {', "\n",
        'optiondoc.writeln("</HEAD>")', "\n",
        q/optiondoc.writeln('<BODY BGCOLOR="#FFFFFF">')/, "\n",
        'optiondoc.writeln("<CENTER><FORM>")', "\n",
        'optiondoc.writeln("Enter 14 digits request ID:")', "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="TEXT" NAME="id" SIZE="14" MAXLENGTH="14 VALUE="">')/, "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="SUBMIT" NAME="searchid" VALUE="Search">')/, "\n",
        'optiondoc.writeln("<\/FORM></CENTER>")', "\n",
      '}', "\n",
      'else if (document.forms[0].searchby.selectedIndex == 2) {', "\n",
        'optiondoc.writeln("</HEAD>")', "\n",
        q/optiondoc.writeln('<BODY BGCOLOR="#FFFFFF">')/, "\n",
        'optiondoc.writeln("<FORM>")', "\n",
        'optiondoc.writeln("From date:\(01-JAN-2000\)")', "\n",
        q/optiondoc.writeln('<INPUT TYPE="TEXT" NAME="startdate" SIZE="11" MAXLENGTH="11" VALUE="">')/, "\n",
        'optiondoc.writeln("<BR>To date:\(01-JAN-2000\)")', "\n",
        q/optiondoc.writeln('<INPUT TYPE="TEXT" NAME="enddate" SIZE="11" MAXLENGTH="11" VALUE="">')/, "\n",
        'optiondoc.writeln("<BR>Requester:")', "\n",
        q/optiondoc.writeln('<INPUT TYPE="TEXT" NAME="requester" SIZE="15" MAXLENGTH="25" VALUE="">')/, "\n";
print 'optiondoc.writeln("<SELECT NAME=responder>")', "\n";
foreach $name(@list) {
  print "optiondoc.writeln('<OPTION>$name')", "\n";
}
print 'optiondoc.writeln("</SELECT>")', "\n";
print   'optiondoc.writeln("<BR>Status:")', "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="Unassigned" CHECKED> New requests')/, "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="Active"> Inactive requests')/, "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="Finished"> Finished requests')/, "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="All"> All requests')/, "\n",
        q/optiondoc.writeln('<BR><CENTER><INPUT TYPE="SUBMIT" NAME="searchperiod" VALUE="Search"><\/CENTER>')/, "\n",
        'optiondoc.writeln("</FORM>")', "\n",
      '}', "\n",
      'else if (document.forms[0].searchby.selectedIndex == 3) {', "\n",
        'optiondoc.writeln("</HEAD>")', "\n",
        q/optiondoc.writeln('<BODY BGCOLOR="#FFFFFF">')/, "\n",
        'optiondoc.writeln("<FORM>")', "\n",
        'optiondoc.writeln("Date:\(01-JAN-2000\)")', "\n",
        q/optiondoc.writeln('<INPUT TYPE="TEXT" NAME="date" SIZE="11" MAXLENGTH="11" VALUE="">')/, "\n",
        'optiondoc.writeln("<BR>Requester:")', "\n",
        q/optiondoc.writeln('<INPUT TYPE="TEXT" NAME="requester" SIZE="15" MAXLENGTH="25" VALUE="">')/, "\n",
        'optiondoc.writeln("<BR>Responder:")', "\n",
        q/optiondoc.writeln('<INPUT TYPE="TEXT" NAME="responder" SIZE="15" MAXLENGTH="25" VALUE="">')/, "\n",
        'optiondoc.writeln("<BR>Status:")', "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="Unassigned" CHECKED> New requests')/, "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="Active"> Inactive requests')/, "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="Finished"> Finished requests')/, "\n",
        q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="All"> All requests')/, "\n",
        q/optiondoc.writeln('<BR><CENTER><INPUT TYPE="SUBMIT" NAME="searchperiod" VALUE="Search"><\/CENTER>')/, "\n",
        'optiondoc.writeln("</FORM>")', "\n",
      '}', "\n",
      'else {', "\n",
        'optiondoc.writeln("</HEAD>")', "\n",
        q/optiondoc.writeln('<BODY BGCOLOR="#FFFFFF">')/, "\n",
        'optiondoc.writeln("<P>Select search criteria</P>")', "\n",
      '}', "\n",
      'optiondoc.writeln("</BODY></HTML>")', "\n",
      'optiondoc.close()', "\n",
      '}', "\n\n";

print 'function ShowEditOptions() {', "\n",
      'top.frames[2].location="/cgi-bin/JobTrackSuper/editList.pl"', "\n",
      'BlankPage(top.frames[1].document)', "\n",
      '}', "\n\n";

print 'function ShowListOptions() {', "\n",
      'var optiondoc = top.frames[1].document', "\n",
      'optiondoc.open()', "\n",
      'optiondoc.writeln("<HTML><HEAD>")', "\n",
      'optiondoc.writeln("<TITLE>List Option Page</TITLE>")', "\n",
      'optiondoc.writeln("</HEAD>")', "\n",
      q/optiondoc.writeln('<BODY BGCOLOR="#FFFFFF">')/, "\n",
      q/optiondoc.writeln('<FORM METHOD="POST" ENCTYPE="application\/x-www-form-urlencoded" ACTION="\/cgi-bin\/JobTrackSuper\/listing.cgi" TARGET="display">')/, "\n",
      'optiondoc.writeln("Select status:")', "\n",
      q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="Unassigned" CHECKED> New requests')/, "\n",
      q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="active"> Inactive requests')/, "\n",
      q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="finished"> Finished requests')/, "\n",
      q/optiondoc.writeln('<BR><INPUT TYPE="RADIO" NAME="status" VALUE="all"> All requests')/, "\n",
      q/optiondoc.writeln('<INPUT TYPE="HIDDEN" NAME="stridx" VALUE="1">')/, "\n",
      q/optiondoc.writeln('<BR><CENTER><INPUT TYPE="SUBMIT" NAME="list" VALUE="List Them"><\/CENTER>')/, "\n",
      'optiondoc.writeln("</FORM>")', "\n",
      'optiondoc.writeln("</BODY></HTML>")', "\n",
      'optiondoc.close()', "\n",
      '}', "\n\n";

print '</script>', "\n";

print '</HEAD>';
print '<BODY bgcolor="#FFFFFF">';

########## GENERATE MENU ##########
print '<center>';
print startform();
print popup_menu(-name=>'searchby',
                 -value=>['Search by', 'ID',
                          'Period', 'Other'],
                 -onChange=>'ShowSearchOptions()');

print '<TABLE BORDER=0 CELLSPACING=4 WIDTH="100%">';
print Tr({-align=>'center'},
         td(button(-name=>"edit", -value=>"     Edit     ", -onClick=>'ShowEditOptions()')),
         td(button(-name=>"list", -value=>"     List     ", -onClick=>'ShowListOptions()'))),
      Tr({-align=>'center'},
         td({-colspan=>2}, button(-name=>"exit", -value=>"     Exit     ",
                                  -onClick=>'top.location="http://dolphin.engr.sjsu.edu/"')));
print '</TABLE>';

print endform();

print '</center>';
 
$dbh->disconnect;
print end_html;




