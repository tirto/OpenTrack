package inventorylib;

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(GetSoftwareTitle ListTitleDeleteAble EntryForm
	     AddEntry GetDeptList ListHeaderTitle ListReport
	     SearchByDept
	     SearchByName SearchByWildCard SearchForNA UpdateEntry
	     %status @titles @category);

use DBI;
use CGI qw/:standard :html3/;

#########################################
#					#
#      	     GLOBAL VARIABLES	        #
#					#
#########################################

$mt = 'N/A';

%buildings = ("ENG"=>"Engineering Building",
	      "IS"=>"Industrial Studies");

@category = ("All Categories",
	     "Utility",
	     "Software Development",
	     "Networking",
	     "Office Suit");

%status = ("FULL-TIME"=>"Full Time",
	   "INACTIVE"=>"Inactive",
	   "PART-TIME"=>"Part Time");

@titles = ("Not Available",
	   "Acting Chair", 
	   "Advisor",
	   "Chair",
	   "Clerk",
	   "Coordinator",
	   "Dean",
	   "Development Assistant",
	   "Director",
	   "Director Development",
	   "Faculty",
	   "Manager",
	   "Mentornet Specialist",
	   "Network Analyst",
	   "Project Manager",
	   "Secretary",
	   "Senior Secretary",
	   "System Administrator",
	   "System Analyst",
	   "Technician",
	   "Webmaster"
	   );


########################################
#                                      #
#          SUBROUTINE SECTION          #
#                                      #
########################################


sub GetSoftwareTitle {
# Description: List all software titles in software table.
# Input: None.
# Output: Return 0 if there is not any software title found.
#	  Return >0 otherwise.
    
    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";
    
    # Prepare statement to query.
    $sth = $dbh->prepare(qq{SELECT * FROM software
 				ORDER BY title});
    
    # Querying.
    $sth->execute or die "Executing: $sth->errstr";
    $ary_ref = $sth->fetchall_arrayref;
    $sth->finish;
    $dbh->disconnect;
    
    # There is one or more record matched. Return the list.
    if (@$ary_ref >= 1) {
	return (1, $ary_ref);
    }
    
    # There is not any record matched. Return error.
    else {
	return 0;
    }
    
} # End GetSoftwareTitle


sub ListTitleDeleteAble {
# Description: List records by first name, last name, and title.
#	Number of records displayed on one page is determined by page_size.
# Input: The script that will list these record in details.
#	 A reference to array of the records.
#	 Starting index to be displayed.
#	 Search criteria.
#	 Page size.
# Output: None.
    
    my $script = shift @_;
    my $ref_ary = shift @_;
    my $cur_idx = shift @_;
    my $opts = shift @_;
    my $page_size = shift @_;
    my $last_idx;
    my $temp;
    
    # Get the list of department.
    my $dept_list = GetDeptList();
    my %depts;
    foreach $i (0 .. $#$dept_list) {
	$j = $dept_list->[$i];
	$depts{$j->[0]}=$j->[1];
    }
    
    # current index is out of bounce. Reset to zero.
    if ($#$ref_ary < $cur_idx) {
	$cur_dix = 0;
    }
    
    # Display records one page at a time.
    if ($#$ref_ary < ($cur_idx + ($page_size-1))) {
	$last_idx = $#$ref_ary;
    }
    else {
	$last_idx = $cur_idx + ($page_size-1);
    }
    
    # Format the table to display all record headers.
    print '<table bgcolor=lightyellow border=1 cellspacing=1 cellpadding=4 align=center>';
    print '<Tr>';
    print '<td bgcolor=peachpuff>&nbsp</td>';
    print '<td align=center bgcolor=peachpuff>Title</td>';
    print '<td align=center bgcolor=peachpuff>Description</td>';
    print '<td align=center bgcolor=peachpuff>Category</td>';
    print '<td align=center bgcolor=peachpuff>Copies</td>';
    print '</tr>';
    
    # Format the id of the record into a string.
    # This string id is used to search for next and previous record
    # in the list.
    my $order;
    foreach $i($cur_idx .. $last_idx) {
	#$order_num = $i + 1;
	$temp = $ref_ary->[$i];
	
	# Keep track of the first and the last elements.
	if ($i == 0) {
	    $order = $temp->[0] . "_" . $i . "_f";
	}
	elsif ($i == $#$ref_ary) {
	    $order = $temp->[0] . "_" . $i . "_l";
	}
	else {
	    $order = $temp->[0] . "_" . $i . "_m";
	}
	
	if (@$ref_ary == 1) {
	    $order = $order . "_s"; # s for Single
	}
	else {
	    $order = $order . "_m"; # m for Multiple
	}
	
	print '<Tr>';
	print "<td><input type=radio name=item value=$temp->[0]><\/td>";
	#print "<td>$order_num<\/td>";
	print "<td><a href=$script?sid=$order&sd=true&opts=$opts>$temp->[1]<\/a><\/td>";
	# sd for show details.
	print "<td>$temp->[4]<\/td>";
	print "<td>$temp->[2]<\/td>";
	print "<td>$temp->[3]<\/td>";
	print '</Tr>';
    } 
    
    print '</table>';
    
} # End ListTitleDeleteAble


sub SearchByWildCard {
# Description: Search an entry by wild card.
# Input: Search criteria (first few characters of either first or last name).
# Output: 0 if input are valid. Array of reference to records is returned.
#	  4 if the name is not found.
    
    
    my $opts = shift @_;
    my $sth;
    my $ary_ref;
    
    # Parsing search criteria.
    my ($wildcard, $bool) = split /_/, $opts;
    $wildcard = ucfirst lc $wildcard;
    
    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";
    
    # Search by first name.
    if ($bool eq 'first') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE
					employee.firstname LIKE '$wildcard%' AND
					    employee.id=position.employeeid});
    }
    
    # Search by last name only.
    elsif ($bool eq 'last') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position 
				    WHERE
					employee.lastname LIKE '$wildcard%' AND
					    employee.id=position.employeeid});
    }
    
    # Search by either first name or last name.
    else {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position 
				    WHERE
					(employee.lastname LIKE '$wildcard%' OR
					 employee.firstname LIKE '$wildcard%') AND
					     employee.id=position.employeeid});
    }
    
    # Querying.
    $sth->execute or die "Executing: $sth->errstr";
    $ary_ref = $sth->fetchall_arrayref;
    $sth->finish;
    $dbh->disconnect;
    
    # There is one or more record matched. Return the list.
    if (@$ary_ref >= 1) {
	return (0, $ary_ref);
    }
    
    # There is not any record matched. Return error.
    else {
	return 4;
    }
} # End SearchByWildCard


sub ListReport {
# Description: List records by first name, last name, and title.
#	Only 15 records are displayed in one page.
# Input: The script that will list these record in details.
#	 A reference to array of the records.
#	 Starting index to be displayed.
#	 Search criteria.
# Output: None.
    
    my $ref_ary = $_[0];
    my $numb = $_[1];
    my $name = $_[2];
    my $titl = $_[3];
    my $dept = $_[4];
    my $phon = $_[5];
    my $emai = $_[6];
    my $buil = $_[7];
    my $room = $_[8];
    my $temp;
    my %depts;
    
    if ($dept eq 'yes') {
	# Get the list of department.
	my $dept_list = GetDeptList();
	foreach $i (0 .. $#$dept_list) {
	    $j = $dept_list->[$i];
	    $depts{$j->[0]}=$j->[1];
	}
    }
    
    # Format the table to display all record headers.
    print '<table bgcolor=ffffff border=0 cellspacing=5 cellpadding=0 align=left>';
    
    # Format the id of the record into a string.
    # This string id is used to search for next and previous record
    # in the list.
    my $order;
    foreach $i(0 .. $#$ref_ary) {
	$order_num = $i + 1;
	$temp = $ref_ary->[$i];
	
	print '<Tr>';
	if ($numb eq 'yes') {
	    print "<td valign=top>$order_num<\/td>";
	}
	if ($name eq 'yes') {
	    print "<td valign=top>$temp->[2], $temp->[1]<\/a><\/td>";
	}
	if ($titl eq 'yes') {
	    print "<td valign=top>$temp->[8]<\/td>";
	}
	if ($dept eq 'yes') {
	    print "<td valign=top>$depts{$temp->[10]}<\/td>";
	}
	if ($phon eq 'yes') {
	    print "<td valign=top>$temp->[11]<\/td>";
	}
	if ($emai eq 'yes') {
	    print "<td valign=top>$temp->[4]<\/td>";
	}
	if ($buil eq 'yes') {
	    print "<td valign=top>$temp->[12]<\/td>";
	}
	if ($room eq 'yes') {
	    print "<td valign=top>$temp->[13]<\/td>";
	}
	print '</Tr>';
    } 
    
    print '</table>';
    
} # End ListReport.


sub SearchForNA {
# Description: Search for N/A fields in all records.
# Input: Search criteria (dept, title, and status).
# Output: 0 if input are valid. Array of reference to records is returned.
#	  1 if there is not any entry found.
    
    my $opts = shift @_;
    my $sth;
    my $ary_ref;
    
    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";
    
    # Parsing search criteria.
    ($dept, $title, $status) = split /_/, $opts;
    
    if ($dept == 0 && $title eq 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE (position.phone='$mt' OR
					   position.roomnumber='$mt' OR
					   employee.email='$mt') AND
					       employee.id=position.employeeid
						   ORDER by employee.lastname});
    }
    elsif ($dept == 0 && $title eq 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE employee.employeestatus='$status'
					AND (position.phone='$mt' OR
					     position.roomnumber='$mt' OR
					     employee.email='$mt') AND
						 position.employeeid=employee.id
						     ORDER by employee.lastname});
    }
    elsif ($dept == 0 && $title ne 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE position.title='$title'
					AND (position.phone='$mt' OR
					     position.roomnumber='$mt' OR
					     employee.email='$mt')
					    AND employee.id=position.employeeid
						ORDER by employee.lastname});
    }
    elsif ($dept == 0 && $title ne 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE (employee.employeestatus='$status'
					   AND position.title='$title')
					AND (position.phone='$mt' OR
					     position.roomnumber='$mt' OR
					     employee.email='$mt')
					    AND employee.id=position.employeeid
						ORDER by employee.lastname});
    }
    elsif ($dept != 0 && $title ne 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE (employee.employeestatus='$status'
					   AND position.staffdept='$dept'
					   AND position.title='$title')
					AND (position.phone='$mt' OR
					     position.roomnumber='$mt' OR
					     employee.email='$mt')
					    AND employee.id=position.employeeid
						ORDER by employee.lastname});
    }
    elsif ($dept != 0 && $title ne 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE (position.staffdept='$dept'
					   AND position.title='$title')
					AND (position.phone='$mt' OR
					     position.roomnumber='$mt' OR
					     employee.email='$mt')
					    AND employee.id=position.employeeid
						ORDER by employee.lastname});
    }
    elsif ($dept != 0 && $title eq 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE position.staffdept='$dept'
					AND (position.phone='$mt' OR
					     position.roomnumber='$mt' OR
					     employee.email='$mt')
					    AND employee.id=position.employeeid
						ORDER by employee.lastname});
    }
    elsif ($dept != 0 && $title eq 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE (employee.employeestatus='$status'
					   AND position.staffdept='$dept')
					AND (position.phone='$mt' OR
					     position.roomnumber='$mt' OR
					     employee.email='$mt')
					    AND employee.id=position.employeeid
						ORDER by employee.lastname});
    }
    else {
	return 2;	# Unknown error
    }
    
    # Querying.
    $sth->execute or die "Executing: $sth->errstr";
    $ary_ref = $sth->fetchall_arrayref;
    $sth->finish;
    $dbh->disconnect;
    
    # There is one or more record matched. Return the list.
    if (@$ary_ref >= 1) {
#print "Total found $#$ary_ref<br>\n";
	return (0, $ary_ref);
    }
    
    # There is not any record matched. Return error.
    else {
	return 1;
    }
} #End SearchForNA


sub SearchByDept {
# Description: Search an entry by department, title, and status.
# Input: Search criteria (dept, title, and status).
# Output: 0 if input are valid. Array of reference to records is returned.
#	  1 if there is not any entry found.
    
    my $opts = shift @_;
    my $sth;
    my $ary_ref;
    
    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";
    
    # Parsing search criteria.
    ($dept, $title, $status) = split /_/, $opts;
    
    if ($dept == 0 && $title eq 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE employee.id=position.employeeid
					ORDER by employee.lastname});
    }
    elsif ($dept == 0 && $title eq 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE employee.employeestatus='$status'
					AND position.employeeid=employee.id
					    ORDER by employee.lastname});
    }
    elsif ($dept == 0 && $title ne 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE position.title='$title'
					AND employee.id=position.employeeid});
    }
    elsif ($dept == 0 && $title ne 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE employee.employeestatus='$status'
					AND position.title='$title'
					    AND employee.id=position.employeeid});
    }
    elsif ($dept != 0 && $title ne 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE employee.employeestatus='$status'
					AND position.staffdept='$dept'
					    AND position.title='$title'
						AND employee.id=position.employeeid});
    }
    elsif ($dept != 0 && $title ne 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE position.staffdept='$dept'
					AND position.title='$title'
					    AND employee.id=position.employeeid});
    }
    elsif ($dept != 0 && $title eq 'All' && $status eq 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE position.staffdept='$dept'
					AND employee.id=position.employeeid});
    }
    elsif ($dept != 0 && $title eq 'All' && $status ne 'All') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE employee.employeestatus='$status'
					AND position.staffdept='$dept'
					    AND employee.id=position.employeeid});
    }
    else {
	return 2;	# Unknown error
    }
    
    # Querying.
    $sth->execute or die "Executing: $sth->errstr";
    $ary_ref = $sth->fetchall_arrayref;
    $sth->finish;
    $dbh->disconnect;
    
    # There is one or more record matched. Return the list.
    if (@$ary_ref >= 1) {
#print "Total found $#$ary_ref<br>\n";
	return (0, $ary_ref);
    }
    
    # There is not any record matched. Return error.
    else {
	return 1;
    }
} # End SearchByDept.


sub GetDeptList {
# Description: Query the list of department from table 'staffdept'.
#		 This list is used for pupup menu.
# Input: None.
# Output: A reference to the list of department.
    
    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";

    my $sth = $dbh->prepare(qq{SELECT *
				   FROM staffdept});
    $sth->execute or die "Executing: $sth->errstr";
    my $ary_ref = $sth->fetchall_arrayref;
    $sth->finish;
    $dbh->disconnect;
    return $ary_ref;
    
} # End GetDeptList.


sub SearchByName {
# Description: Search an entry by first name, last name, or both.
# Input: Search criteria (first, last name, and boolean).
# Output: 0 if input are valid. Array of reference to records is returned.
#	  1 if bool is 'and' and first name is missing.
#	  2 if bool is 'and' and last name is missing.
#	  3 if first and last name are missing.
#	  4 if the name is not found.


    my $opts = shift @_;
    my $sth;
    my $ary_ref;
    
    # Parsing search criteria.
    ($firstname, $bool, $lastname) = split /_/, $opts;
    
    # Search by name, but did not enter any name.
    if ($firstname eq '' && $lastname eq '') {
	return 3;
    }
    
    # User choose search by both first and last.
    # Check if both first and last name are provided.
    if ($bool eq 'and') {
	
	if ($firstname eq '') {
	    return 1;
	}
	
	if ($lastname eq '') {
	    return 2;
	}
    }
    
    $firstname = ucfirst lc $firstname;
    $lastname = ucfirst lc $lastname;
    
    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";
    
    # Search by last name and first name.
    if ($bool eq 'and') {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position
				    WHERE
					(employee.firstname='$firstname' AND
					 employee.lastname='$lastname') AND
					     (employee.id=position.employeeid)});
    }
    
    # Search by first name or last name only.
    else {
	$sth = $dbh->prepare(qq{SELECT * FROM employee, position 
				    WHERE
					(employee.firstname='$firstname' OR
					 employee.lastname='$lastname') AND
					     (employee.id=position.employeeid)});
    }
    
    # Querying.
    $sth->execute or die "Executing: $sth->errstr";
    $ary_ref = $sth->fetchall_arrayref;
    $sth->finish;
    $dbh->disconnect;
    
    # There is one or more record matched. Return the list.
    if (@$ary_ref >= 1) {
	return (0, $ary_ref);
    }
    
    # There is not any record matched. Return error.
    else {
	return 4;
    }
    
} # End SearchByName


sub ListHeaderTitle {
# Description: List records by first name, last name, and title.
#	Only 10 records are displayed in one page.
# Input: The script that will list these record in details.
#	 A reference to array of the records.
#	 Starting index to be displayed.
#	 Search criteria.
# Output: None.

    my $script = shift @_;
    my $ref_ary = shift @_;
    my $cur_idx = shift @_;
    my $opts = shift @_;
    my $page_size = shift @_;
    my $last_idx;
    my $temp;
    
    # Get the list of department.
    my $dept_list = GetDeptList();
    my %depts;
    foreach $i (0 .. $#$dept_list) {
	$j = $dept_list->[$i];
	$depts{$j->[0]}=$j->[1];
    }
    
    # current index is out of bounce. Reset to zero.
    if ($#$ref_ary < $cur_idx) {
	$cur_dix = 0;
    }
    
    # Display 10 records at a time.
    if ($#$ref_ary < ($cur_idx + ($page_size-1))) {
	$last_idx = $#$ref_ary;
    }
    else {
	$last_idx = $cur_idx + ($page_size-1);
    }
    
    # Format the table to display all record headers.
    print '<table bgcolor=ffffff border=1 cellspacing=1 cellpadding=4 align=center>';
    print '<Tr>';
    print '<td bgcolor=peachpuff>&nbsp</td>';
    print '<td align=center bgcolor=peachpuff>Name</td>';
    print '<td align=center bgcolor=peachpuff>Title</td>';
    print '<td align=center bgcolor=peachpuff>Department</td>';
    print '<td align=center bgcolor=peachpuff>Phone</td>';
    print '<td align=center bgcolor=peachpuff>Email</td>';
    print '<td align=center bgcolor=peachpuff>Room</td>';
    print '<td align=center bgcolor=peachpuff>Building</td>';
    print '</tr>';
    
    # Format the id of the record into a string.
    # This string id is used to search for next and previous record
    # in the list.
    my $order;
    foreach $i($cur_idx .. $last_idx) {
	$order_num = $i + 1;
	$temp = $ref_ary->[$i];
	
	# Keep track of the first and the last elements.
	if ($i == 0) {
	    $order = $temp->[0] . "_" . $i . "_f";
	}
	elsif ($i == $#$ref_ary) {
	    $order = $temp->[0] . "_" . $i . "_l";
	}
	else {
	    $order = $temp->[0] . "_" . $i . "_m";
	}
	
	if (@$ref_ary == 1) {
	    $order = $order . "_s";
	}
	else {
	    $order = $order . "_m";
	}
	
	print '<Tr>';
#		print "<td><input type=radio name=item value=$temp->[0]><\/td>";
	print "<td>$order_num<\/td>";
	print "<td><a href=$script?sid=$order&sd=true&opts=$opts>$temp->[2], $temp->[1]<\/a><\/td>";
	print "<td>$temp->[8]<\/td>";
	print "<td>$depts{$temp->[10]}<\/td>";
	print "<td>$temp->[11]<\/td>";
	print "<td><a href=mailto:$temp->[4]>$temp->[4]<\/a><\/td>";
	print "<td>$temp->[13]<\/td>";
	print "<td>$temp->[12]<\/td>";
	print '</Tr>';
    } 
    
    print '</table>';
    
    return @$ref_ary;
    
} # End ListHeaderTitle


sub AddEntry {
# Description: Add a new entry to the database.
# Input: Information of the new entry.
# Output: 0 for succeed .
#	  1 if first name is missing.
#	  2 if last name is missing.
#	  3 if title is not valid.
#	  4 if the new entry is duplicated.

    my $firstname = shift @_;
    my $lastname = shift @_;
    my $ssn = shift @_;
    my $title = shift @_;
    my $email = shift @_;
    my $phone = shift @_;
    my $building = shift @_;
    my $room = shift @_;
    my $dept = shift @_;
    my $employmentstatus = shift @_;
    my $notes = shift @_;
    
    # Check for presence of the first name.
    if ($firstname eq '') {
	return 1;
    }
    $firstname = ucfirst lc $firstname;
    
    # Check for presence of the last name.
    if ($lastname eq '') {
	return 2;
    }
    $lastname = ucfirst lc $lastname;
    
    # Check for valid title.
    if ($title eq 'Not Available') {
	return 3;
    }
    
    if ($ssn eq '') {
	$ssn = $mt;
    }
    
    if ($email eq '') {
	$email = $mt;
    }
    
    if ($phone eq '') {
	$phone = $mt;
    }
    
    if ($room eq '') {
	$room = $mt;
    }
    
    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";
    
    # Check for duplicated entry.
    my $sth = $dbh->prepare(qq{SELECT * FROM employee, position WHERE
				   (employee.firstname='$firstname'
				    AND employee.lastname='$lastname')
				       AND (position.title='$title'
					    AND employee.id=position.employeeid)});
    $sth->execute or die "Executing: $sth->errstr";
    my @row = $sth->fetchrow_array;
    if (@row != ()) {
	$dbh->disconnect;
	return 4;
    }
    $sth->finish;
    
    # Generate an unique id number.
    $sth = $dbh->prepare(qq{SELECT * FROM employee ORDER by id});
    $sth->execute or die "Executing: $sth->errstr";
    my $ary_ref = $sth->fetchall_arrayref;
    $sth->finish;
    my $last_element = $ary_ref->[$#ary_ref];
    my $id = $last_element->[0] + 1;
    
    # Everything went well, insert new entry into the position table.
    $sth = $dbh->prepare(qq{INSERT into employee values(?,?,?,?,?,?,?)});
    $sth->bind_param(1, $id);
    $sth->bind_param(2, $firstname);
    $sth->bind_param(3, $lastname);
    $sth->bind_param(4, $ssn);
    $sth->bind_param(5, $email);
    $sth->bind_param(6, $employmentstatus);
    $sth->bind_param(7, $notes);
    $sth->execute or die "Executing: $sth->errstr";
    $sth->finish;
    
    # Now insert other information into the employee table.
    $sth = $dbh->prepare(qq{UPDATE position SET title='$title',
			    staffdept='$dept',
			    phone='$phone',
			    building='$building',
			    roomnumber='$room'
				WHERE positionid='$id'});
    $sth->execute or die "Executing: $sth->errstr";
    $sth->finish;
    
    $dbh->disconnect;
    return 0;
    
} # End AddEntry.


sub EntryForm {
# Description: Display a form for adding, editing, or viewing an entry.
# Input: 1. () Display a blank form.
#	 2. ([edit, nonedit], Flag, Holder)
#	 3. ([edit, nonedit], Flag, title, description, category, copies)
#        Where:	edit for editable form.
#		Flag tells what kind of data Holder has, value or reference.
#		Holder can be either 'id' or 'ref' of the entry. If Holder is
#		a reference, the script does not have to query information
#		from the database. Otherwise, need more work.
# Output: String describe the error if any.

    # Declare local variables.
    my $id = 0;
    my $title = '';
    my $description = '';
    my $category = '';
    my $copies = 0;
    my $is_editable;
    
    
    # Check if any argument is passed in.
    if (@_) {
	$is_editable = shift @_;	
	my $flag = shift @_;
	
	# Holder contains id of the entry, have to query.
	if ($flag eq 'id') {
	    
	    # We get the login and password to access the database
	    open(FILE,"/home/httpd/.jobDBAccess");
	    $DBlogin = <FILE>;
	    $DBpassword = <FILE>;
	    # Let's get rid of that newline character
	    chop $DBlogin;
	    chop $DBpassword;
	    
	    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
		or die "connecting:  $DBI::errstr";
	    
	    # Get id number.
	    $id = shift @_;
	    
	    # Get information.
	    my $handle = $dbh->prepare(qq{SELECT * FROM software 
					      WHERE id='$id'});
	    $handle->execute or die "Executing: $handle->errstr";
	    my @record = $handle->fetchrow_array;	
	    
	    #	$id = $record[0];
	    $title = $record[1];
	    $category = $record[2];
	    $copies = $record[3];
	    $description = $record[4];
	    
	    # Clean up connection with the database.
	    $handle->finish;
	    $dbh->disconnect;
	}
	
	# Holder is a reference. Save sometime. 
	elsif ($flag eq 'ref') {
	    my $temp = shift @_;
	    
	    #	$id = $temp->[0];
	    $title = $temp->[1];
	    $category = $temp->[2];
	    $copies = $temp->[3];
	    $description = $temp->[4];
	}		
	
	# All information is passed in. Better!
	else {
	    if ($_[0] ne '') {$title = $_[0];}
	    if ($_[1] ne '') {$category = $_[1];}
	    if ($_[2] ne '') {$copies = $_[2];}
	    if ($_[4] ne '') {$description = $_[3];}
	}		
    }
    
    # Display a note on message board.
    print "<center><hr width=30%><br>\n";
    print "<i>Note<\/i>: (*) fields are required fields.\n";
    print "<br><br><hr width=30%><\/center><br>\n";
    
    # Format information onto the form.
    print "<table border=0 align=center cellpadding=0 cellspacing=4>\n";
    print "<Tr>\n";
    print '<td align=left valign=bottom>Title (*)</td>', "\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<td align=left valign=top><input type=text name=title value=\"$title\" size=16 maxlength=32><\/td>\n";
    print "</Tr>\n";
    print "<Tr>\n";
    print "<td align=left valign=bottom>Category (*)<\/td>\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<td valign=top><select name=category>\n";
    foreach $index(0 .. $#category) {
	if ($category[$index] eq $category) {
	    print "<option selected> $category[$index]\n";
	}
	else {
	    print "<option> $category[$index]\n";
	}
	}
    print "<\/select><\/td>\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<td align=left valign=bottom>Number of copies (*)<\/td>\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<td align=left valign=top><input type=text name=copies value=$copies size=3 maxlength=5><\/td>\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<td align=left valign=bottom>Descriptions (limited to 5 lines)<\/td>\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<td align=left valign=top>";
    print "<textarea name=description rows=5 cols=50 wrap=soft>\n";
    print "$description<\/textarea>\n";
    print "<\/td><\/Tr>\n";
    print "<\/table>\n"; 
    
} # End EntryForm

sub UpdateDataBase {
# Description: Add a new entry or update an existing one.
# Input: (id, title, category, copies, description).
#	 id of an entry to be updated or 0 if insert a new entry.

# Output: 0 for succeed .
#	  1 if first name is missing.
#	  2 if last name is missing.
#	  3 if Title is missing.
#	  4 if entry is duplicated.

    my $id = shift @_;
    my $title = shift @_;
    my $category = shift @_;;
    my $copies = shift @_;
    my $description = shift @_;
    
    # Check for presence of the title.
    if ($title eq '') {
	return 1;
    }
    $title =~ s/(\w+)/\u\L$1/g;

    # We get the login and password to access the database
    open(FILE,"/home/httpd/.jobDBAccess");
    $DBlogin = <FILE>;
    $DBpassword = <FILE>;
    # Let's get rid of that newline character
    chop $DBlogin;
    chop $DBpassword;
    
    my $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError => 1,RaiseError =>1 })
	or die "connecting:  $DBI::errstr";
    
    # Check for duplicated entry.
    my $sth = $dbh->prepare(qq{SELECT * FROM employee, position WHERE
				   employee.id!='$id'
				       AND (employee.firstname='$firstname'
					    AND employee.lastname='$lastname')
					   AND (position.title='$title'
						AND employee.id=position.employeeid)});
    $sth->execute or die "Executing: $sth->errstr";
    my @row = $sth->fetchrow_array;
    if (@row != ()) {
	$dbh->disconnect;
	return 4;
    }
    $sth->finish;
    
    # Everything went well, insert new entry into the position table.
    $sth = $dbh->prepare(qq{UPDATE employee SET
				firstname='$firstname',
				lastname='$lastname',
				ssn='$ssn',
				email='$email',
				employeestatus='$employmentstatus',
				notes='$notes'
				    WHERE id='$id'});
    $sth->execute or die "Executing: $sth->errstr";
    $sth->finish;
    
    # Now insert other information into the employee table.
    $sth = $dbh->prepare(qq{UPDATE position SET
				title='$title',
				staffdept='$dept',
				phone='$phone',
				building='$building',
				roomnumber='$room'
				    WHERE employeeid='$id'});
    $sth->execute or die "Executing: $sth->errstr";
    $sth->finish;
    
    $dbh->disconnect;
    return 0;
    
}	#End UpdateEntry

1;











