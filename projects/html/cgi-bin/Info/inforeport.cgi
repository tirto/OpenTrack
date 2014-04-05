#! /usr/bin/perl

use infolib;
use CGI qw/:standard :html3/;

########## STARTING THE HEADER ##########
print header,
      start_html(-title=>"Information System", -bgcolor=>"#ffffff");

# User want to search by department, title, and status.
# Display page to take option for searching. 
if (!param() || param('back') eq "search page") {
	SearchForm();
}

# User already entered names for searching. Now search.
elsif (param('search') eq 'Search') {

	my $number = 'no';
	my $name = 'no';
	my $title = 'no';
	my $department = 'no';
	my $phone = 'no';
	my $email = 'no';
	my $room = 'no';
	my $building = 'no';

	if (param('nu') eq 'yes') {
		$number = 'yes';
	}
	if (param('na') eq 'yes') {
		$name = 'yes';
	}
	if (param('ti') eq 'yes') {
		$title = 'yes';
	}
	if (param('de') eq 'yes') {
		$department = 'yes';
	}
	if (param('ph') eq 'yes') {
		$phone = 'yes';
	}
	if (param('em') eq 'yes') {
		$email = 'yes';
	}
	if (param('bu') eq 'yes') {
		$building = 'yes';
	}
	if (param('ro') eq 'yes') {
		$room = 'yes';
	}

	# format search criteria into one string if it is not already done.
	# This string will be parsed and used by the search function.
	# It is passed back and forth between a browser and the script as well.
	my $code;
	if (param('opts')) {
		$code = param('opts');
	}
	else {
		$code = param('dept') . "_" . param('title') . "_" . param('status');
	}
		
	# Searching.
	($err, $result) = SearchByDept($code); 

	if ($err == 0) {

		print '<form method=post enctype=application/x-www-form-urlencoded>';
		$entries = ListReport($result, $number, $name, $title,
				$department, $phone, $email, $building, $room);
		print '</form>';
	}
	elsif ($err == 1) {
		print "<center>";
		print "<hr width=30%>";
		print '<h1>No Entry Matched</h1>';
		print '<h2>Select Search Options And Try Again</h2>';
		print "<hr width=30%";
		print '</center>';
		SearchForm();
	}
	elsif ($err == 2) {
		print "<center>\n";
		print "<hr width=30%>\n";
		print "<h1>Unknown Error<\/h1>\n";
		print '<h2>Select Search Options And Try Again</h2>';
		print "<hr width=30%\n";
		print "<\/center>\n";
		SearchForm();
	}
}

# List a record in details.
elsif (param('sd') eq 'true') {
	DetailForm('set', param('sid'), param('opts'));
}

# There is one record listed in details.
# User wants to go back to the searching result page.
# Display page that the current element is in.
elsif (param('result') eq "result page") {
	my $code = param('opts');

	my @fields = split /_/, param('sid'); 

use integer;

	my $idx = $fields[0] / $page_size;
	$idx *= $page_size;
	
	# Searching.
	($err, $result) = SearchByDept($code); 

	if ($err == 0) {
		# There are more than one record matched. List headers only.
		if (@$result > 1) {
			print '<form method=post enctype=application/x-www-form-urlencoded>';
			$entries = ListHeaderTitle('searchbydept.cgi', $result, $idx, $code);
			print '</form>';

use integer;
			# Calculate number of pages. 10 entries per page.
			# Display links to those pages.
			my $remain = 0;		
			my $pages = 0;
			$pages =  $entries / $page_size;
			$remain = $entries % $page_size;

			# There are more than one pages. More than 10 entries.
			# List the links to other pages.
			if ($pages > 0) {
				print "<br><br>\n";
				print "Go to page: \n";
				foreach $i (0 .. $pages) {
					print "<a href=/cgi-bin/Info/searchbydept.cgi?search=search&opts=$code&idx=$i>$i";
					print "<\/a>\n";
					print "&nbsp&nbsp\n";
				}
				
				if ($remain > 0) {
					print "<a href=/cgi-bin/Info/searchbydept.cgi?search=search&idx=$i&opts=$code>$i";
					print "<\/a>\n";
				}
			}


			print "<br>\n";	
		}
	}
	elsif ($err == 1) {
		print "<center>";
		print "<hr width=30%>";
		print '<h1>No Entry Matched</h1>';
		print '<h2>Select Search Options And Try Again</h2>';
		print "<hr width=30%";
		print '</center>';
		SearchForm();
	}
	elsif ($err == 2) {
		print "<center>\n";
		print "<hr width=30%>\n";
		print "<h1>Unknown Error<\/h1>\n";
		print '<h2>Select Search Options And Try Again</h2>';
		print "<hr width=30%\n";
		print "<\/center>\n";
		SearchForm();
	}
}

# There is one record listed in details.
# A user wants to see details of the next record in the search result list.
elsif (param('next') eq 'next') {

	# Searching.
	my ($err, $result) = SearchByDept(param('opts'));


	if ($err == 0) {
		my @id_parts = split /_/, param('sid');
		my $ordNum = $id_parts[1] + 1;

		if ($ordNum >= $#$result) {
			my $temp = $result->[$#$result];
			my $id = $temp->[0] . "_" . $#$result . "_l";
			DetailForm('unset', $id, param('opts'), $temp);
		}
		else {
			my $temp = $result->[$ordNum];
			my $id = $temp->[0] . "_" . $ordNum . "_m";
			DetailForm('unset', $id, param('opts'), $temp);
		}

	}	
	
	# There is not any record matched.
	elsif ($err == 1) {
		print "<center>";
		print "<hr width=30%>";
		print '<h1>Next record not found</h1>';
		print '<h2>Please try to search again</h2>';
		print "<hr width=30%";
		print '</center>';
		SearchForm();
	}
	elsif ($err == 2) {
		print "<center>\n";
		print "<hr width=30%>\n";
		print "<h1>Unknown Error<\/h1>\n";
		print "<h2>Try Again<\/h2>\n";
		print "<hr width=30%\n";
		print "<\/center>\n";
		SearchForm();
	}
}

elsif (param('prev') eq 'previous') {
	# Searching.
	my ($err, $result) = SearchByDept(param('opts'));


	if ($err == 0) {
		my @id_parts = split /_/, param('sid');
		my $ordNum = $id_parts[1] - 1;

		if ($ordNum <= 0) {
			my $temp = $result->[0];
			my $id = $temp->[0] . "_" . '0' . "_f";
			DetailForm('unset', $id, param('opts'), $temp);
		}
		else {
			my $temp = $result->[$ordNum];
			my $id = $temp->[0] . "_" . $ordNum . "_m";
			DetailForm('unset', $id, param('opts'), $temp);
		}
	}	
	
	# There is not any record matched.
	elsif ($err == 1) {
		print "<center>";
		print "<hr width=30%>";
		print '<h1>Next record not found</h1>';
		print '<h2>Please try to search again</h2>';
		print "<hr width=30%";
		print '</center>';
		SearchForm();
	}
	elsif ($err == 2) {
		print "<center>\n";
		print "<hr width=30%>\n";
		print "<h1>Unknown Error<\/h1>\n";
		print "<h2>Try Again<\/h2>\n";
		print "<hr width=30%\n";
		print "<\/center>\n";
		SearchForm();
	}
}

elsif (param('edit') eq 'update') {
	# Get id number of the record.
	my @id_string = split /_/, param('sid');

	# Try to update the record.
	my $is_success = UpdateEntry($id_string[0], param('firstname'),
		param('lastname'), param('ssn'), param('title'), param('email'),
		param('phone'), param('building'), param('room'),
		param('dept'), param('status'),  param('notes'));	
	
	if ($is_success == 0) {
		print "<center>\n";
		print "<h1>Update successed<\/h1>";
		print "<\/center>\n";
		DetailForm('set', param('sid'), param('opts'));
	}

	elsif ($is_success == 1) {
		print "<center>\n";
		print "<h1>First name is missing<\/h1>";
		print "<h2>Enter the first name and try again<\/h2>\n";
		DetailForm('set', param('sid'), param('opts'));
	}

	elsif ($is_success == 2) {
		print "<center>\n";
		print "<h1>Last name is missing<\/h1>";
		print "<h2>Enter the last name and try again<\/h2>\n";
		DetailForm('set', param('sid'), param('opts'));
	}

	elsif ($is_success == 3) {
		print "<center>\n";
		print "<h1>Title is missing<\/h1>";
		print "<h2>Enter the title and try again<\/h2>\n";
		DetailForm('set', param('sid'), param('opts'));
	}

	elsif ($is_success == 4) {
		$l = param('lastname');
		$f = param('firstname');
		print "<center>\n";
		print "<h1>Duplicate Entry<\/h1>";
		print "<h2>The name <a href=searchbyname?search=search&sfirstname=$f&slastname=$l&sbool=and>$l, $f<\/a> already exists<\/h2>\n";
		DetailForm('set', param('sid'), param('opts'));
	}
}

else {
	print "<center>\n";
	print "<h1>Unknown command<\/h1>\n";
	print "<h2>Message could be lost, please try to search again<\/h2>\n";
	print "<\/center>\n";
}
# End html.
print end_html;

########################################
#                                      #
#          SUBROUTINE SECTION          #
#                                      #
########################################


sub DetailForm {
# Description: Display a record in details and other options that user can
#		do with the record such as delete and update.
#		Also give the user options to go to next or previous record
#		as well as go back to search page and search result page.
# Input: ID of the record to be displayed in a format of id_order#_c.
#		id	: an actual id number of the record in the database.
#		order #	: an index of the record in the search result list.
#		c	: a character either l(last), f(first), or m(middle).
#	 Search option in a format of firstname_bool_lastname.
#		bool	:and, or.
# Output: None.

	my $flag = shift @_;
	my $sid = shift @_;
	my $opts = shift @_;
	my $ref = shift @_;

	my @fields = split /_/, $sid;

	print '<form method=post enctype=application/x-www-form-urlencoded>';

	if ($flag eq 'set') {
		Form('true', $fields[0]);
	}
	else {
		Form('false', $ref);
	}
	
	print "<input type=hidden name=sid value=$sid>";
	print "<input type=hidden name=opts value=$opts>";

	print '<td><input type=submit name=edit value=update></td>';

	print '<table align=center border=0 celspacing=4 cellpadding=4>';
	print '<tr>';
	print '<td align=center><input type=submit name=result value="result page"></td>';
	if ($fields[2] eq 'l') {
		print "<td><input type=submit name=prev value='previous'></td>";
	}
	elsif ($fields[2] eq 'f') {
		print "<td><input type=submit name=next value='next'></td>";
	}
	elsif ($fields[2] eq 'm') {
		print '<td>';
		print "<input type=submit name=prev value='previous'>";
		print '&nbsp&nbsp&nbsp&nbsp&nbsp';
		print "<input type=submit name=next value='next'>";
		print '</td>';
	}
	else {
		print '<td>&nbsp&nbsp</td>';
	}
	
	print '<td align=center><input type=submit name=back value="search page"></td>';
	print '</tr>';	
	print '</table>';
	print '</form>';

}	# End DetailForm.


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
	print "<br><br><br>\n";
	print "<hr width=50%>\n";

	print "<br>\n";
	print "<h3>Select Information That Should Be Displayed<\/h3>\n";
	print "<br><br>\n";
	print "<input type=checkbox name=nu value=yes>Number\n";
	print "&nbsp&nbsp&nbsp&nbsp&nbsp\n";
	print "<input type=checkbox name=na value=yes checked>Name\n";
	print "&nbsp&nbsp&nbsp&nbsp&nbsp\n";
	print "<input type=checkbox name=ti value=yes checked>Title\n";
	print "&nbsp&nbsp&nbsp&nbsp&nbsp\n";
	print "<input type=checkbox name=de value=yes checked>Department\n";
	print "&nbsp&nbsp&nbsp&nbsp&nbsp\n";
	print "<input type=checkbox name=ph value=yes checked>Phone\n";
	print "&nbsp&nbsp&nbsp&nbsp&nbsp\n";
	print "<input type=checkbox name=em value=yes checked>Email\n";
	print "&nbsp&nbsp&nbsp&nbsp&nbsp\n";
	print "<input type=checkbox name=ro value=yes>Room\n";
	print "&nbsp&nbsp&nbsp&nbsp&nbsp\n";
	print "<input type=checkbox name=bu value=yes>Building\n";
 
	print end_form;
	print "<\/center>\n";

} # End SearchForm()
