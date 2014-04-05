#! /usr/bin/perl -w

use inventorylib;
use CGI qw/:standard :html3/;


BEGIN
{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

my $page_size = 10;

########## STARTING THE HEADER ##########
print header,
    start_html(-title=>"Inventory System", -bgcolor=>"#ffffff");

# User want to search by department, title, and status.
# Display page to take option for searching. 
if (!param() || param('search') eq 'Search') {

    # format search criteria into one string if it is not already done.
    # This string will be parsed and used by the search function.
    # It is passed back and forth between a browser and the script as well.
    # In this case search string will be 'all'.
    my $search_code;
    if (param('opts')) {
	$search_code = param('opts');
    }
    else {
	$search_code = 'all';
    }
    
    my $idx;
    if (param('idx')) {
	$idx = param('idx');
	$idx *= $page_size;
    }
    else {
	$idx = 0;
    }
    
    # Searching.
    ($err, $result) = GetSoftwareTitle($search_code); 
    
    # GetSoftwareTitle returns 0 if no entry found. Otherwise, > 0.
    if ($err > 0) {
	print '<form method=post enctype=application/x-www-form-urlencoded>';
	ListTitleDeleteAble('listsoftware.cgi', $result, $idx, $code, $page_size);
	print '</form>';
	
	use integer;
	# Calculate number of pages. page_size entries per page.
	# Display links to those pages.
	my $remain = 0;		
	my $pages = 0;
	$pages =  @$result / $page_size; # use integer for this line.
	$remain = @$result % $page_size;
	
	# There are more than one pages. More than page_size entries.
	# List the links to other pages.
	if ($pages > 0) {
	    print "<br>\n";
	    print "Go to page: \n";
	    foreach $i (0 .. $pages) {
		print "<a href=/cgi-bin/Inventory/listsoftware.cgi?search=Search&opts=$code&idx=$i>$i";
		print "<\/a>\n";
		print "&nbsp&nbsp\n";
	    }
	    
	    if ($remain > 1) {
		print "<a href=/cgi-bin/Inventory/listsoftware.cgi?search=Search&idx=$i&opts=$code>$i";
		print "<\/a>\n";
	    }
	}
	
	
	print "<br>\n";	
    }
    
    else {
	print "<center>";
	print "<hr width=30%>";
	print '<h1>No Entry Matched</h1>';
	print h2("Select Search Options And Try Again");
	print "<hr width=30%";
	print '</center>';
    }
}

# List a record in details.
elsif (param('sd') eq 'true') {
    ShowDetails('id', param('sid'), param('opts'));
}

# There is one record listed in details.
# User wants to go back to the searching result page.
# Display page that the current element is in.
elsif (param('result') eq "Result Page") {
    my $search_code = param('opts');
    
    my @fields = split /_/, param('sid'); 

    use integer;

    my $idx = $fields[1] / $page_size;
    $idx *= $page_size;
    
    # Searching.
    ($err, $result) = GetSoftwareTitle($search_code); 
    
    # GetSoftwareTitle returns 0 if no entry found. Otherwise, > 0.
    if ($err > 0) {
	print '<form method=post enctype=application/x-www-form-urlencoded>';
	ListTitleDeleteAble('listsoftware.cgi', $result, $idx, $code, $page_size);
	print '</form>';
	
	use integer;
	# Calculate number of pages according to page_size.
	# Display links to those pages.
	my $remain = 0;		
	my $pages = 0;
	$pages =  @$result / $page_size;
	$remain = @$result % $page_size;
	
	# There are more than one pages.
	# List the links to other pages.
	if ($pages > 0) {
	    print "<br>\n";
	    print "Go to page: \n";
	    foreach $i (0 .. $pages) {
		print "<a href=/cgi-bin/Inventory/listsoftware.cgi?search=Search&opts=$search_code&idx=$i>$i";
		print "<\/a>\n";
		print "&nbsp&nbsp\n";
	    }
	    
	    if ($remain > 1) {
		print "<a href=/cgi-bin/Inventory/listsoftware.cgi?search=Search&idx=$i&opts=$search_code>$i";
		print "<\/a>\n";
	    }
	}
	
	print "<br>\n";	
    }
    
    else {
	print "<center>";
	print "<hr width=30%>";
	print '<h1>Cannot go back to the result page</h1>';
	print h2("Try Again");
	print "<hr width=30%";
	print '</center>';
    }
}

# There is one record listed in details.
# A user wants to see details of the next record in the search result list.
elsif (param('next') eq 'Next') {
    
    # Searching.
    my ($err, $result) = GetSoftwareTitle(param('opts'));
    
    if ($err > 0) {
	my @id_parts = split /_/, param('sid');
	my $ordNum = $id_parts[1] + 1;
	
	if ($ordNum >= $#$result) {
	    my $temp = $result->[$#$result];
	    my $id = $temp->[0] . "_" . $#$result . "_l" . "_m";
	    ShowDetails('ref', $id, param('opts'), $temp);
	}
	else {
	    my $temp = $result->[$ordNum];
	    my $id = $temp->[0] . "_" . $ordNum . "_m" . "_m";
	    ShowDetails('ref', $id, param('opts'), $temp);
	}
	
    }	
    
    # There is not any record matched.
    else {
		print "<center>";
		print "<hr width=30%>";
		print '<h1>Next Entry Is Not Found</h1>';
		print '<h2>Please Try To Search Again</h2>';
		print "<hr width=30%";
		print '</center>';
	    }
}

elsif (param('prev') eq 'Previous') {
    # Searching.
    my ($err, $result) = GetSoftwareTitle(param('opts'));
    
    
    if ($err > 0) {
	my @id_parts = split /_/, param('sid');
	my $ordNum = $id_parts[1] - 1;
	
	if ($ordNum <= 0) {
	    my $temp = $result->[0];
	    my $id = $temp->[0] . "_" . '0' . "_f" . "_m";
	    ShowDetails('ref', $id, param('opts'), $temp);
	}
	else {
	    my $temp = $result->[$ordNum];
	    my $id = $temp->[0] . "_" . $ordNum . "_m" . "_m";
	    ShowDetails('ref', $id, param('opts'), $temp);
	}
    }	
    
    # There is not any record matched.
    else {
	print "<center>";
	print "<hr width=30%>";
	print '<h1>Next Entry Is Not Found</h1>';
	print "<h2>Select Search Options And Try Again<\/h2>\n";
	print "<hr width=30%";
	print '</center>';
    }
}

elsif (param('edit') eq 'Update') {
    # Get id number of the record.
    my @id_string = split /_/, param('sid');
    
    # Try to update the record.
    my $is_success = UpdateDataBase($id_string[0], param('title'),
				    param('category'), param('copies'), param('description'));
    
    if ($is_success == 0) {
	print "<center>\n";
	print "<h1>Update Successful<\/h1>";
	print "<\/center>\n";
	DetailForm('set', param('sid'), param('opts'));
    }
    
    elsif ($is_success == 1) {
	print "<center>\n";
	print "<h1>First Name Is Missing<\/h1>";
	print "<h2>Enter The First Name And Try Again<\/h2>\n";
	DetailForm('set', param('sid'), param('opts'));
    }
    
    elsif ($is_success == 2) {
	print "<center>\n";
	print "<h1>Last Name Is Missing<\/h1>";
	print "<h2>Enter The Last Name And Try Again<\/h2>\n";
	DetailForm('set', param('sid'), param('opts'));
    }
    
    elsif ($is_success == 3) {
	print "<center>\n";
	print "<h1>Title Is Missing<\/h1>";
	print "<h2>Enter The Title And Try Again<\/h2>\n";
	DetailForm('set', param('sid'), param('opts'));
    }
    
    elsif ($is_success == 4) {
	$l = param('lastname');
	$f = param('firstname');
	print "<center>\n";
	print "<h1>Duplicate Entry<\/h1>";
	print "<h2>The Name <a href=searchbydept?search=Search&sfirstname=$f&slastname=$l&sbool=and>$l, $f<\/a> Already Exists<\/h2>\n";
	DetailForm('set', param('sid'), param('opts'));
    }
}

else {
    print "<center>\n";
    print "<h1>Unknown Command<\/h1>\n";
    print "<h2>Select Search Options And Try Again<\/h2>\n";
    print "<\/center>\n";
}
# End html.
print end_html;

########################################
#                                      #
#          SUBROUTINE SECTION          #
#                                      #
########################################


sub ShowDetails {
# Description: Display a record in details and other options that user can
#		do with the record such as delete and update.
#		Also give the user options to go to next or previous record
#		as well as go back to search page and search result page.
# Input: (option, id, search_option).
#	 Option is a way to tell the script how to get information of the entry
#		to be displayed. The options are:
#		'ref': A reference to the entry is passed in. The script does
#			not have to get information from the database.
#		'id': Only ID of the entry is passed in. The script has to
#			make a query to get information.
#	 ID of the record to be displayed in a format of id_order#_c.
#		id	: an actual id number of the record in the database.
#		order #	: an index of the record in the search result list.
#		c	: a character either l(last), f(first), or m(middle).
#	 Search option is the search criteria, in this case, 'all'.
#	 Reference to the entry has to be specified if Option is 'ref'.
# Output: None.

    my $flag = shift @_;
    my $sid = shift @_;
    my $opts = shift @_;
    my $ref = shift @_;
    
    # Parse the 'encrypted' id to get actual id.
    my @fields = split /_/, $sid;
    
    print '<form method=post enctype=application/x-www-form-urlencoded>';
    
    # Get the function in the library to show the information.
    if ($flag eq 'id') {
	EntryForm('edit', $flag, $fields[0]);
    }
    else {
	EntryForm('edit', $flag, $ref);
    }
    
    print "<input type=hidden name=sid value=$sid>";
    print "<input type=hidden name=opts value=$opts>";
    
    print '<br><br><center>';
    print '<td><input type=submit name=edit value=Update></td>';
    print '<br><br></center>';
    print '<table align=center border=0 celspacing=4 cellpadding=4>';
    print '<tr>';
    print '<td align=center><input type=submit name=result value="Result Page"></td>';
    if ($fields[3] eq 'm') {
	if ($fields[2] eq 'l') {
	    print "<td><input type=submit name=prev value='Previous'></td>";
	}
	elsif ($fields[2] eq 'f') {
	    print "<td><input type=submit name=next value='Next'></td>";
	}
	elsif ($fields[2] eq 'm') {
	    print '<td>';
	    print "<input type=submit name=prev value='Previous'>";
	    print '&nbsp&nbsp&nbsp&nbsp&nbsp';
	    print "<input type=submit name=next value='Next'>";
	    print '</td>';
	}
	else {
	    print '<td>&nbsp&nbsp</td>';
	}
    }
    
    print '<td align=center><input type=submit name=back value="Search Page"></td>';
    print '</tr>';	
    print '</table>';
    print '</form>';
    
}	# End ShowDetails.


sub SearchForm {
# Description: Display a page of searching options.
# Input: None.
# Output: None.

    my $dept_ref = GetDeptList();
    my %depts;
    foreach $i (0 .. $#$dept_ref) {
	$j = $dept_ref->[$i];
	$depts{$j->[0]} = $j->[1];
    }
    
    print "<br><br><br><br><br>\n";
    print "<center>\n";
    print "<form method=post enctype=application/x-www-form-urlencoded>\n";
    print "<table border=0 cellspacing=2>\n";
    print "<Tr>\n";
    print "<Td align=right>Department<\/Td>\n";
    print "<Td><select name=dept>\n";
    print "<option value=0 selected> All Departments\n";
    foreach $i (sort {$depts{$a} cmp $depts{$b} }
		keys %depts) {
	print "<option value=$i> $depts{$i}\n";
    }
    print "<\/select><\/td>\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<Td align=right>Title<\/Td>\n";
    print "<Td><select name=title>\n";
    print "<option selected>All\n";
    foreach $i (1 .. $#titles) {
	print "<option> $titles[$i]\n";
    }
    print "<\/select><\/td>\n";
    print "<\/Tr>\n";
    print "<Tr>\n";
    print "<Td align=right>Status<\/Td>\n";
    print "<Td><select name=status>\n";
    print "<option value=All selected> All\n";
    foreach $c (sort { $status{$a} cmp $status{$b} }
		keys %status) {
	print "<option value=$c> $status{$c}\n";
    }
    print "<\/select><\/td>\n";
    print "<\/Tr>\n";
    print "<\/table>\n";
    print "<br><br>\n";
    print "<input type=submit name=search value=Search>\n";
    print end_form;
    print "<br><hr width=70%>\n";
    print "<\/center>\n";
    
} # End SearchForm()



