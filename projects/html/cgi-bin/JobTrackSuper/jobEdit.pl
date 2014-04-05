#!/usr/bin/perl -w 

use DBI;
use CGI qw/:standard :html3/;
use 5.004;

###########################################################################################################
# jobEdit.pl is for accessing and modifying requests on an individual basis                               #
# It takes 3 arguments:                                                                                   #
# -page: to differentiate between a new request, one already i process and one that is finished           #
# -date: this is part of the primary key to identify the request into the jobRequest and jobManage tables #
# -client: the second part of the primary key                                                             #
# The result is displaying the current state of the request.                                              #
###########################################################################################################

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
      start_html(-title=>'College Of Engineering Job Tracking System',-BGCOLOR=>'#FFFFFF'),
    h1({-align=>center},"College Of Engineering Job Tracking System");

$dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError=>1,RaiseError=>1}) or die "connecting :   $DBI::errsrtr";

my $page = param("page");
my $date = param("date");
my $client = param("client");
my $clientEmail; # This email is used to send a note to the requester if needed

print p({-align=>center},'<font size=+1>Here is the request as it was entered</font>');

$sth = $dbh->prepare(qq{SELECT * FROM jobRequest WHERE datereceived = TO_DATE(?,'MM-DD-YYYY-HH24-MI-SS') AND clientname = ?});
$sth->bind_param(1,$date); 
$sth->bind_param(2,$client); 
$sth->execute or die "executing: $sth->errstr";
@row = $sth->fetchrow_array;

# Save client email address for sending a note if needed
$clientEmail = $row[4];

# Checking the phone value - indeed there could be a bug here in case of somebody's number being '4-0000'
if ($row[3] == 0) {
    $row[3] = "None";
} else {
    $row[3] = "4-$row[3]";
}

# The jobRequest table is already complete and will be displayed in the 3 cases
print table({-border=>1, -align=>center, -cellpadding=>3, -cellspacing=>3, bgcolor=>'#FFDD99'},
	Tr(td({-bgcolor=>'#AAEEEE'}, "Name"), td({-colspan=>3}, $row[1])),
	Tr(td({-bgcolor=>'#AAEEEE'}, "Email"), td($row[4]), td({-bgcolor=>'#AAEEEE'}, "Phone"), td($row[3])),
	Tr(td({-bgcolor=>'#AAEEEE'}, "Building"), td($row[7]), td({-bgcolor=>'#AAEEEE'}, "Room"), td($row[2])),
	Tr(td({-bgcolor=>'#AAEEEE'}, "Machine Type"), td($row[5]), td({-bgcolor=>'#AAEEEE'}, "O.S."), td($row[6])),
	Tr(td({-bgcolor=>'#AAEEEE'}, "Description"), td({-colspan=>3}, $row[8]))
	);

print p({-align=>center},'<font size=+1>Here is the management information</font>');

$sth = $dbh->prepare(qq{SELECT personassigned, status, priority, title, comments FROM jobManage
			WHERE datereceived = TO_DATE(?,'MM-DD-YYYY-HH24-MI-SS') AND clientname = ?});
$sth->bind_param(1,$date); 
$sth->bind_param(2,$client); 
$sth->execute or die "executing: $sth->errstr";
@row = $sth->fetchrow_array;

#In the case of an already processed request, everything is displayed as read-only
if ($page eq 'old') {
    print table({-border=>1, -align=>center, -cellpadding=>3, -cellspacing=>3, bgcolor=>'#FFDD99'},
	Tr(td({-bgcolor=>'#AAEEEE'}, "Title"), td({-colspan=>3}, $row[3])),
	Tr(td({-bgcolor=>'#AAEEEE'}, "Person Assigned"), td({-colspan=>3}, $row[0])),
	Tr(td({-bgcolor=>'#AAEEEE'}, "Status"), td($row[1]), td({-bgcolor=>'#AAEEEE'}, "Priority"), td($row[2])),
	Tr(td({-bgcolor=>'#AAEEEE'}, "Comments"), td({-colspan=>3}, $row[4]))
	);

    print '<center>', start_form,
        button(-name=>'back', -value=>'Return to the List', onClick=>'history.back()'),
        end_form, '</center>';

#The 2 other cases are not differentiated in that script. They will be in jobChange.pl
} else {

########## End adding fragment ###########

$userId = $ENV{REMOTE_USER};

# Get the assign list from the database
$sth2 = $dbh->prepare(qq{SELECT name 
                         FROM assignList WHERE assigner = '$userId'
                         ORDER by name});
$sth2->execute or die "executing: $sth2->errstr";

$i = 1;
while (@row3 = $sth2->fetchrow_array) {
  $list[$i++] = $row3[0];
}

$list[0] = 'Nobody';

%status = (Unassigned=>'Unassigned', Assigned=>'Assigned', Finished=>'Finished');

    print start_form(-action=>'/cgi-bin/JobTrackSuper/jobChange.pl'), table({-align=>center},
	Tr(td({-align=>right}, "Title : "),
           td({-align=>left, -colspan=>3}, textarea(-name=>"title", -default=>$row[3], -rows=>2, -columns=>40, -wrap=>virtual))), 
	Tr(td({-align=>right}, "Person Assigned : "),
# Add a popup menu for Person Assigned June 7, 1999 
           td({-align=>left, -colspan=>2}, popup_menu(-name=>"personassigned", -values=>\@list, -default=>$row[0]))),
#	   td({-align=>left}, textfield(-name=>"personassigned", -default=>$row[0], -size=>30, -maxlength=>30))),           
	Tr(td({-align=>right}, "Status : "),
           td({-align=>left}, popup_menu(-name=>"status", -values=>['Unassigned', 'Active', 'Finished'], -default=>$row[1])),
	   td({-align=>right}, "Priority : "),
           td({-align=>left}, popup_menu(-name=>"priority", -values=>['Low','Normal','High'], -default=>$row[2]))),
	Tr(td({-align=>right}, "Comments : "),
           td({-align=>left, -colspan=>3}, textarea(-name=>"comments", -default=>$row[4], -rows=>5, -columns=>40, -wrap=>virtual))), 

#############################################################################
#
# The checkbox is added on Jun 17, 1999
#
#############################################################################
        Tr(td({-align=>right}, "Send a note to requester: "),
           td({-align=>left}, checkbox(-name=>'sendnoteto', -value=>$clientEmail, -label=>' '))),
	Tr(td(), td({-align=>center}, submit(-name=>'ok', -value=>'Apply Changes')),
	   td({-align=>center}, button(-name=>'cancel', -value=>'Cancel', -onClick=>'history.back()'))),
	),
        hidden(-name=>'page', -value=>$page),
        hidden(-name=>'date', -value=>$date),
        hidden(-name=>'client', -value=>$client),
	end_form;
}

$dbh->disconnect;
print end_html;






