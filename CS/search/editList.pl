#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use FindBin qw($Bin);
use lib "$Bin/../Common";
use misclib;
use 5.004;

# Project: Job Tracking System
# File:    editList.pl
# By:      Phuoc Diec
# Date:    June 28, 1999
# Last update:	July 18, 1999

# Description:
# This script allows users to add, change, or delete person name from
# the assign lists that belong to the users.

# Each user has a separated list. All users' lists are kept in one
# database table called 'assignList'. Each record in this table has
# three fields:
#	name:		name of a person
#	email:		email of a person
#	assigner: 	name of a person who will assign job to the above
#			person

# The script takes three differents command parameters: 'add',
# 'update', 'delete', and 'submit'.  When there is not command
# parameter passed in, the script displays as existing list that
# belong to the user if ther is one.

# When 'add' command is passed in, editing window is displayed.

# When 'update' command is passed in, the script will displays a
# selected record for editing. If more than one record is selected,
# only the first one in the list can be edited at the time.

# When 'delete' command is passed in, the script will remove all
# selected records.  This process cannot be undone.

# When 'submit' is passed in, a user either submit a new record or
# finish editing an existing record. The script will look for new name
# and email in param(). It will check for valid email and add it to
# the database.  Display error message, otherwise.

# ChangeLog:
# 06/12/2000 Prasanth Kumar
# - Did a initial cleanup and reformatting.
# - Read DB username/password from files for added security.
# 06/29/2000 Prasanth Kumar
# - Start using ../Common/misclib.pm
# 08/14/2000 Prasanth Kumar
# - Fix prepare statements to not interpolate parameters.
# 12/13/2000 Prasanth Kumar
# - Do additional cleanup of comments and formatting.

########## SET UP A PATH TO THE DATABASE ##########
BEGIN
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

########## OPEN CONNECTION WITH THE DATABASE ##########

# Open connection to database
my $dbh = open_database("/home/httpd/.jobDBAccess");

########## PRINT HEADER AND START FORMATTING HTML ##########
print
    header(-expires=>'now'),
    start_html(-title=>"Job Tracking Display", -bgcolor=>"#ffffff");

########## START PROCESSING REQUESTS FROM WEB BROWSER ##########

# Get user ID from environment variable
$userId = remote_user();

# When there is no parameter passed in, the user just get in the first
# time List all the names that belong to this user.
if (!param()) {
    ListAllNames($dbh, $userId);
}

# When a user want to add new name, display a window for the user to
# type in new name and email. Only one name can be added at one time.
if (param('add')) {
    EditPage();
}

# When a user want to edit an existing name, display a window for the
# user to type in new information. Only one name can be edited at a
# time.
if (param('edit')) {
    EditPage($userId, param('name'), $dbh);
}

# When user finished adding new name or editing an existing name,
# update the database.
if (param('submit')) {
    UpdateDatabase($dbh, $userId, param('name'),
		   param('email'), param('fullname'), param('oldname'));
    ListAllNames($dbh, $userId);
}

# When the user had selected an option for the script to deal with
# sublist, call the function to accomplish the request.
if (param('sublistoption')) {
    if (param('deloptions') eq 'delall') {
	DeleteSublist($dbh, $userId, param('curdelname'));
    }
    elsif (param('deloptions') eq 'transfer') {
	DeleteSublist($dbh, $userId, param('curdelname'), param('newowner'));
    }

  # Call delete function if there is any more name to be deleted.
    if (param('Nid')) {
	DeleteNames($dbh, $userId, param('Nid'));
    }

  # Otherwise, there is no more name in the deleted list.
    else {
	ListAllNames($dbh, $userId);
    }
}

# When users want to delete one or more existing names, all selected
# names will be removed from the table. No warning nessessary. It is
# assumpted that all the warning has been done at the web page.
if (param('delete')) {
    DeleteNames($dbh, $userId, param('Nid'));
}

########## DISCONNECT WITH THE DATABASE ##########
$dbh->disconnect;

########## END FORMATTING HTML ##########
print end_html;
exit 0;

########## DELETE A NAME AND ITS SUBLIST ##########
sub DeleteSublist() {
# Purpose: Transfer or delete sublist and then delete the selected name. 
# Input: Handle to the database, userId, a name to be deleted, and new
#   owner's name if the sublist is transferred. 
# Output: None

    my $dbh = shift @_;
    my $userId = shift @_;
    my $delName = shift @_;
    my $newOwner = shift @_;

    # Transfer the list to new owner if there is a new owner's name.
    if ($newOwner) {
	$sth = $dbh->prepare(qq{UPDATE assignList SET assigner = ?
				    WHERE assigner = ?});
	$sth->execute($newOwner, $delName) or die "Executing: $sth->errstr";
	$dbh->commit;
	$sth->finish;
    }

  # If there is no new owner's name, the list will be deleted.
    else {
	#  Fist delete the sublist
	$sth = $dbh->prepare(qq{DELETE FROM assignList
				    WHERE assigner = ?});
	$sth->execute($delName) or die "Executing: $sth->errstr";
	$sth->finish;
    }

    #  Now delete the name
    $sth = $dbh->prepare(qq{DELETE FROM assignList
				WHERE name = ?
				    AND assigner = ?});
    $sth->execute($delName, $userId) or die "Executing: $sth->errstr";
    $sth->finish;

} # End DeleteSublist()


########## DELETE SELECTED NAMES AND THEIR SUBLISTS ##########
sub DeleteNames() {
# Purpose: Delete all selected names and their sublists
# Input: Handle to the database, list of names to be deleted, userId
# Output: None

# The list of name to be deleted is passed through @delList. Some
# names in the list may have their own list. The user who wanted to
# delete these name have choices:
#		Delete the name and its sublist
#		Delete the name and give its sublist to another owner
#		Keep the name and its sublist

    my $dbh = shift @_;
    my $userId = shift @_;
    my @delList = @_;

    # Delete all the name in the list one-by-one until the list is
    # empty.  If the name owns a sublist, ask the user for whether to
    # delete all, keep the sublist, or keep all. If the name does not
    # own a list, it will be deleted without a confirmation.
    while (@delList) {

	# Extract the name at the top of the list
	$delName = shift @delList;

	# Check for its sublist
	$sth = $dbh->prepare(qq{SELECT name, email
				    FROM assignList
					WHERE assigner = ?});
	$sth->execute($delName) or die "Executing: $sth->errstr";
	@row = $sth->fetchrow_array;

	# If the name owns a sublist, notify the user for further
	# decision
	if (@row) {

	    # Get the list of names that the user may transfer the
	    # sublist to.  The list belong to this user.
	    $sth2 = $dbh->prepare(qq{SELECT name
					 FROM assignList
					     WHERE assigner = ?});
	    $sth2->execute($userId) or die "Executing: $sth2->errstr";

	    $i = 1;
	    while (@row2 = $sth2->fetchrow_array) {

		# Get all the name in the list except for the name to
		# be deleted
		if ($row2[0] ne $delName) {
		    $list[$i++] = $row2[0];
		}
	    }
	    $sth2->finish;
	    $list[0] = $userId;
	    @list = sort @list;

	    # Display error message.
	    print h2({-align=>'center'},
		     "$delName owns the following sublist");
	    print '<br>';
      
	    # Display the sublist
	    print '<TABLE align=center cellspacing=2 cellpadding=3 border=1>';
	    print Tr({-bgcolor=>"#BBCCDD", -align=>'center'},
		     td("Name"), td("Email"));
	    print Tr(td($row[0]), td($row[1]));

	    while (@row = $sth->fetchrow_array) {
		print Tr(td($row[0]), td($row[1]));
	    }

	    print '</TABLE>';
	    $sth->finish;

	    print startform();

	    # Format radio buttons of options for the user to choose
	    print "<br>Please choose one of the options below:", '<br><br>';
	    print '<INPUT TYPE="radio" NAME="deloptions" VALUE="cancel" CHECKED> Cancel the deletion <BR>';
	    print '<INPUT TYPE="radio" NAME="deloptions" VALUE="delall"> Delete the name and its sublist <BR>';
	    print '<INPUT TYPE="radio" NAME="deloptions" VALUE="transfer"> Delete the name and transfer its sublist to ';

	    # Format a popup list of name that the user can transfer
	    # the sublist to
	    print popup_menu(-name=>'newowner',
			     -values=>\@list, -default=>$userId);
 
	    # Format the submit button
	    print '<br><br>';
	    print '<INPUT TYPE="submit" NAME="sublistoption" VALUE="OK">';
	    print '<B> to continue with the selected option</B>';

	    # Also list the rest of names to be deleted but have not
	    # yet been deleted to the deleted list so that they will
	    # be deleted when after the work on the current deleted
	    # name is done.

	    foreach $nameHolder (@delList) {
		print hidden(-name=>'Nid', -value=>$nameHolder);
	    }

	    # Current deleted name is listed separately for later use.
	    print hidden(-name=>'curdelname', -value=>$delName);

	    print endform();

	    return;
	} # End if (@row) 

	# In case there is no matched row returned, just delete the name.
	else { 
	    $sth3 = $dbh->prepare(qq{DELETE FROM assignList
					 WHERE name = ?
					     AND assigner = ?});
	    $sth3->execute($delName, $userId)
		or die "Executing: $sth3->errstr";
	}

    } # End while

    ListAllNames($dbh, $userId);
} # End DeleteNames


########## UPDATING THE DATABASE WITH NEW INFOR OR NEW NAME ##########
sub UpdateDatabase() {
# Purpose: Add new entry to the database or update an existing entry
# Input: Handle to the database, userId, new name, email, old name 
# Output: None

    my ($dbh, $userId, $name, $email, $fullname, $oldname) = @_;

    # If old and new name are the same, the user must wanted to update
    # the email.
    if ($oldname && $oldname eq $name) { 
	$sth = $dbh->prepare(qq{UPDATE assignList SET email=?, fullname=?
				    WHERE name = ? AND assigner = ?});
	$sth->bind_param(1,$email);
	$sth->bind_param(2,$fullname);
	$sth->bind_param(3,$name);
	$sth->bind_param(4,$userId);
	
	$sth->execute or die "executing: $sth->errstr";
    }

    # Otherwise, the user must wanted to add a new entry or change an
    # existing name.  In both cases, the new name has to be checked if
    # it matches with other existing names under this userId in the
    # database.
    else {
	print "Suppose to be OK";

	# Check with other existing names
	$sth = $dbh->prepare(qq{SELECT name FROM assignList
				    WHERE name = ? AND assigner = ?});
	$sth->execute($name, $userId) or die "executing: $sth->errstr";

	@row = $sth->fetchrow_array;

	# If name already exists, display error message and have the
	# user go back to editing page with the information he
	# provided.
	if ($row[0]) {
	    print h1({-align=>'center'},
		     "$name already exists. Select new name");
	    EditPage($userId, $name, $dbh, $oldname, $email);
	    return;
	}
	
	# If there is no old name and new name does not conflict with
	# any name in the database, create a new entry in the
	# database.

	if (!$oldname) {
	    print "Prepare to insert new entry";

	    $sth = $dbh->prepare(qq{insert into assignList values (?,?,?,?)});
	    $sth->bind_param(1,$name);
	    $sth->bind_param(2,$email);
	    $sth->bind_param(3,$userId);
	    $sth->bind_param(4,$fullname);
	    $sth->execute or die "executing: $sth->errstr";
	    $sth->finish;

	    my $rc = $dbh->commit || die $dbh->errstr;

	} # End if (!$oldname)

	# The new name for an existing entry does not conflict with
	# any name in the database, update that entry with new infor.
	else {
	    $sth = $dbh->prepare(qq{UPDATE assignList
					SET name=?, email=?, fullname=?
					WHERE name = ? AND assigner = ?});
	    $sth->bind_param(1, $name);
	    $sth->bind_param(2, $email);
	    $sth->bind_param(3, $fullname);
	    $sth->bind_param(4, $oldname);
	    $sth->bind_param(5, $userId);
	    
	    $sth->execute or die "executing: $sth->errstr";

	} # End inner else
	
    } # End outer else

} # End UpdateDatabase


########## EDITING PAGE ##########
sub EditPage() {
# Purpose: Display text fields for users to add new name or edit
#   existing names
# Input: Handle to the database, userId, Name of an existing entry to
#   be edited
# Output: None

    my $userId = shift @_;
    my $name = shift @_;
    my $dbh = shift @_;
    my $oldname = shift @_;
    my $email = shift @_;

    print startform();

    # The user want to edit an existing name. Display text fields with
    # values retrieved from the database.
    if ($name) {
	# Retrieve the entry from the database first
	$sth = $dbh->prepare(qq{SELECT name, email, fullname
				    FROM assignList
					WHERE name = ?
					    AND assigner = ?});
	$sth->execute($name, $userId) or die "executeing: $sth->errstr";
	@row = $sth->fetchrow_array;

	# Format text fields for name and email without default values
	print '<table border=0 align=center cellpadding=0 cellspacing=0>',
	Tr(td({-align=>'right'}, 'Login ID: '),
	   td({-align=>'left'}, textfield(-name=>'name',
					  -default=>$row[0],
					  -size=>25,
					  -maxlength=>30))),
	Tr(td({-align=>'right'}, 'Name: '),
	   td({-align=>'left'}, textfield(-name=>'fullname',
					  -default=>$row[2],
					  -size=>25,
					  -maxlength=>30))),
	Tr(td({-align=>'right'}, 'Email: '),
	   td({-align=>'left'}, textfield(-name=>'email',
					  -default=>$row[1],
					  -size=>25,
					  -maxlength=>30))),
	'</table>';

	print hidden(-name=>'oldname', -value=>$name);
    } # End if

    # The user has entered a conflict name. Display text fields with
    # values that have been enter by the user for new name.
    elsif ($email) {
	print '<table border=0 align=center cellpadding=0 cellspacing=0>',
	Tr(td({-align=>'right'}, 'Login ID: '),
	   td({-align=>'left'}, textfield(-name=>'name',
					  -default=>$name,
					  -size=>25,
					  -maxlength=>30))),
	Tr(td({-align=>'right'}, 'Name: '),
	   td({-align=>'left'}, textfield(-name=>'fullname',
					  -default=>$name,
					  -size=>25,
					  -maxlength=>30))),
	Tr(td({-align=>'right'}, 'Email: '),
	   td({-align=>'left'}, textfield(-name=>'email',
					  -default=>$email,
					  -size=>25,
					  -maxlength=>30))),
	'</table>';

	if ($oldname) {
	    print hidden(-name=>'oldname', -value=>$oldname);
	}
    } # End elsif

    # Otherwise, the user want to add new name. Display a blank field.
    else {
	# Format text fields for name and email without default values
	print '<table border=0 align=center cellpadding=0 cellspacing=0>',
	Tr(td({-align=>'right'}, 'Login ID: '),
	   td({-align=>'left'}, textfield(-name=>'name',
					  -size=>25,
					  -maxlength=>30))),
	Tr(td({-align=>'right'}, 'Name: '),
	   td({-align=>'left'}, textfield(-name=>'fullname',
					  -size=>25,
					  -maxlength=>30))),
	Tr(td({-align=>'right'}, 'Email: '),
	   td({-align=>'left'}, textfield(-name=>'email',
					  -size=>25,
					  -maxlength=>30))),
	'</table>';
    } # End else
    
    print '<br><br>';

    # Format submit and reset buttons.
    print '<table border=0 align=center cellpadding=0 cellspacing=0>',
    Tr(td({-align=>'center'}, reset('  RESET  ')),
       td({-align=>'center'}, "&nbsp&nbsp&nbsp&nbsp"),
       td({-align=>'center'}, submit(-name=>'submit', -value=>'SUBMIT'))),
    '</table>';

    print endform();

} # End EditPage


########## LIST ALL NAMES IN THE TABLE ##########
sub ListAllNames() {
# Purpose: List all names in the table that belong to this user
# Input: Handle of connection with the database
#	 User name (or ID)
# Output: None

    my $dbh = shift @_;
    my $userId = shift @_;

    # Beginning of the form
    print startform();

    # Formatting a menu of three buttons: 'ADD', 'EDIT', and 'DELETE'.
    print '<table border=0 cellpadding=1 cellspacing=0 width="100%">',
    Tr(td({-align=>'right'}, submit(-name=>'add', -value=>'    ADD    ')),
       td({-align=>'center'}, reset('  RESET  ')),
       td({-align=>'left'}, submit(-name=>'delete', -value=>'DELETE'))),
    '</table>';

    print '<br>';

    # Table of entries
    print '<table border=1 align=center cellpadding=5 cellspacing=0>';

    # Get all entries in the database that belong to this user
    # and sort them by name.
    $sth = $dbh->prepare(qq{SELECT name, email, fullname
				FROM assignList
				    WHERE assigner = ?
					ORDER BY name});
    $sth->execute($userId) or die "executing: $sth->errstr";

    # Read all entries from the database one-by-one
    while (@row = $sth->fetchrow_array) {
	print
	    Tr({-bgcolor=>"#ffffff"}, 
	       td(checkbox(-name=>"Nid", -value=>$row[0], -label=>' ')),
	       td(a({-href=>"/cgi-bin/JobTrackSuper/editList.pl?edit='true'&name=$row[0]"}, "$row[0]")),
	       td($row[2]),
	       td(a({-href=>"mailto:$row[1]"}, "$row[1]")));
    }

    print '</table>';

    print '<br>';

    # Formatting the same menu as above at the end of the form This is
    # an additional menu bar. For long tables, users don't have to
    # scroll back to the top the menu.
    print '<table border=0 cellpadding=1 cellspacing=0 width="100%">',
    Tr(
       td({-align=>'right'}, submit(-name=>'add', -value=>'    ADD    ')),
       td({-align=>'center'}, reset('  RESET  ')),
       td({-align=>'left'}, submit(-name=>'delete', -value=>'DELETE'))),
        '</table>';

    # Ending of the form
    print endform();
    
} # End ListAllNames
