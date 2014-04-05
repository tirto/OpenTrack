#! /usr/bin/perl

use infolib;
use CGI qw/:standard :html3/;


########## STARTING THE HEADER ##########
print header,
    start_html(-title=>"Information System", -bgcolor=>"#ffffff");

# User requested an empty form to add a new entry.
if (!param()) {
    print "<center><h1>Add A New Name<\/h1><\/center>\n";
    print start_form;
    Form();
    print "<table border=0 align=center cellspacing=5 cellpadding=5>\n";
    print Tr(td({-align=>center}, reset()),
	     td({-align=>center}, submit(-name=>"add", -value=>"true",
					 -label=>"Add")));
    print "<\/table>\n";
    print end_form;
}


# Add new entry.
if (param('add') eq 'Add') {
    
    $is_success = AddEntry(param('firstname'), param('lastname'),
			   param('ssn'), param('title'), param('email'),
			   param('phone'), param('building'), param('room'),
			   param('dept'), param('status'), param('notes'));
    
    if ($is_success == 0) {
	print "<br><br><br><br><br>\n";
	print "<center>\n";
	print "<h1>Add Successful<\/h1>\n";
	print "<hr width=30%>\n";
	print "<hr width=20%>\n";
	print "<\/center>\n";
    }
    elsif ($is_success == 1) {
	print "<center>\n";
	print "<h1>First Name Is Missing<\/h1>";
	print "<h2>Enter The First Name And Try Again<\/h2>\n";
	print "<form method=post enctype=application/x-www-form-urlencoded>";
	Form('list', param('firstname'), param('lastname'),
	     param('ssn'), param('title'), param('email'),
	     param('phone'), param('building'), param('room'),
	     param('dept'), param('status'), param('notes'));
	print "<table border=0 align=center cellspacing=5 cellpadding=5>\n";
	print Tr(td({-align=>center}, reset()),
		 td({-align=>center}, submit(-name=>"add", -value=>"true",
					     -label=>"Add")));
	print "<\/table>\n";
	print '</form>';
    }
    elsif ($is_success == 2) {
	print "<center>\n";
	print "<h1>Last Name Is Missing<\/h1>";
	print "<h2>Enter The Last Name And Try Again<\/h2>\n";
	print "<form method=post enctype=application/x-www-form-urlencoded>";
	Form('list', param('firstname'), param('lastname'),
	     param('ssn'), param('title'), param('email'),
	     param('phone'), param('building'), param('room'),
	     param('dept'), param('status'), param('notes'));
	print "<table border=0 align=center cellspacing=5 cellpadding=5>\n";
	print Tr(td({-align=>center}, reset()),
		 td({-align=>center}, submit(-name=>"add", -value=>"true",
					     -label=>"Add")));
	print "<\/table>\n";
	print '</form>';
    }
    elsif ($is_success == 3) {
	print "<center>\n";
	print "<h1>Title Is Not Available<\/h1>";
	print "<h2>Enter The Title And Try Again<\/h2>\n";
	print "<form method=post enctype=application/x-www-form-urlencoded>";
	Form('list', param('firstname'), param('lastname'),
	     param('ssn'), param('title'), param('email'),
	     param('phone'), param('building'), param('room'),
	     param('dept'), param('status'), param('notes'));
	print "<table border=0 align=center cellspacing=5 cellpadding=5>\n";
	print Tr(td({-align=>center}, reset()),
		 td({-align=>center}, submit(-name=>"add", -value=>"true",
					     -label=>"Add")));
	print "<\/table>\n";
	print '</form>';
    }
    elsif ($is_success == 4) {
	$l = param('lastname');
	$f = param('firstname');
	print "<center>\n";
	print "<h1>Duplicate Entry<\/h1>";
	print "<h2>The name <a href=/cgi-bin/Info/searchbyname.cgi?search=Search&sfirstname=$f&slastname=$l&sbool=and>$l, $f<\/a> already exists<\/h2>\n";
	print "<form method=post enctype=application/x-www-form-urlencoded>";
	Form('list', param('firstname'), param('lastname'),
	     param('ssn'), param('title'), param('email'),
	     param('phone'), param('building'), param('room'),
	     param('dept'), param('status'), param('notes'));
	print "<table border=0 align=center cellspacing=5 cellpadding=5>\n";
	print Tr(td({-align=>center}, reset()),
		 td({-align=>center}, submit(-name=>"add", -value=>"true",
					     -label=>"Add")));
	print "<\/table>\n";
	print '</form>';
    }
    else {
	print "<center>\n";
	print "<h1>Unknow Error<\/h1>";
	print "<h2>The network could be down. Try again later<\/h2>\n";
	print "<form method=post enctype=application/x-www-form-urlencoded>";
	Form('list', param('firstname'), param('lastname'),
	     param('ssn'), param('title'), param('email'),
	     param('phone'), param('building'), param('room'),
	     param('dept'), param('status'), param('notes'));
	print "<table border=0 align=center cellspacing=5 cellpadding=5>\n";
	print Tr(td({-align=>center}, reset()),
		 td({-align=>center}, submit(-name=>"add", -value=>"true",
					     -label=>"Add")));
	print "<\/table>\n";
	print '</form>';
    }
}
print end_html;

