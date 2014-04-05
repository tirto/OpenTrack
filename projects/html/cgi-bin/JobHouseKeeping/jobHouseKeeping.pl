#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use 5.004;

#GENERAL CONFIGURATION PARAMETERS

BEGIN 

{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}


# We get the login and password to access the database
open(FILE,"/home/httpd/.jobDBAccess");
$DBlogin = <FILE>;
$DBpassword = <FILE>;
# Let's get rid of that newline character
chop $DBlogin;
chop $DBpassword;
$index = 0;
@names = ();
@emails = ();

my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
    or die "connecting:  $DBI::errstr";


$sth = $dbh->prepare(qq{
		SELECT DISTINCT name, email
		FROM assignList
		});

$sth->execute or die "executing: $sth->errstr";

while (@row = $sth->fetchrow_array) {
  $names[$index] = $row[0];
  $emails[$index++] = $row[1];
}
$nbPeople = $index;

$sth->finish;

for ($peopleIndex = 0; $peopleIndex < $nbPeople; $peopleIndex++) {
  $sth = $dbh->prepare(qq{
		SELECT dateReceived, clientName, priority, title
		FROM jobManage
		WHERE dateFinished IS NULL
		AND TRUNC(SysDate - dateReceived) > 6
		AND personAssigned = '$names[$peopleIndex]'
		AND priority != 'Low' 
		});
  $sth->execute or die "executing: $sth->errstr";

  @tasks = ();
  $taskIndex = 0;

  while (@row = $sth->fetchrow_array) {
    $tasks[$taskIndex++] = $row[0];
    $tasks[$taskIndex++] = $row[1];
    $tasks[$taskIndex++] = $row[2];
    $tasks[$taskIndex++] = $row[3];
  }
  $sth->finish;

  $sth = $dbh->prepare(qq{
		SELECT dateReceived, clientName, title
		FROM jobManage
		WHERE dateFinished IS NOT NULL
		AND resolution IS NULL
		AND personAssigned = '$names[$peopleIndex]' 
		});
  $sth->execute or die "executing: $sth->errstr";

  @comments = ();
  $commentIndex = 0;
  
  while (@row = $sth->fetchrow_array) {
    $comments[$commentIndex++] = $row[0];
    $comments[$commentIndex++] = $row[1];
    $comments[$commentIndex++] = $row[2];
  }
  $sth->finish;

  if ($taskIndex + $commentIndex > 0) {  
    # Compose and send an email to notify the person that there are unfinished requests.
    open (MAIL, "|/usr/lib/sendmail -t") || die "Can't open $mailprog!\n";
    print MAIL "To: $emails[$peopleIndex]\n";
    print MAIL "From: Job Tracking Manager\n";
    print MAIL "Subject: Weekly reminder\n";
    print MAIL "\n\n";
    print MAIL "Dear $names[$peopleIndex]\n\n";

    if ($taskIndex > 0) {
      print MAIL "It seems that the following tasks are not completed yet. You may have forgotten to mark their status as \"Finished\".\n\n";
      for ($i = 0; $i < $taskIndex; $i += 4) {
	print MAIL "\'", $tasks[$i+3], "\', started: ", $tasks[$i], ", for ", $tasks[$i+1],"\n";
	if ($tasks[$i+2] =~ "High") {
	  print MAIL " - Please remember that this task has been assigned a High Priority\n";
	}
      }
      print MAIL "\n\n";
    }

    if ($commentIndex > 0) {
      print MAIL "Although the following tasks have a \"Finished\" status, there is no mention of the way they have been solved in the \"Resolution\" field. Please reactivate each request and explain your solution before closing it again.\n\n";
      for ($i = 0; $i < $commentIndex; $i += 3) {
	print MAIL "\'", $comments[$i+2], "\', started: ", $comments[$i], ", for ", $comments[$i+2],"\n";
      }
      print MAIL "\n\n";
    }

    print MAIL "Thank you.\n";
    close (MAIL);
  }
}
