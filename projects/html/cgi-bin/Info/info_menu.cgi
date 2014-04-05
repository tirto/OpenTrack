#! /usr/bin/perl

use CGI qw/:standard :html3/;


########## STARTING THE HEADER ##########
print header,
      start_html(-title=>"ECS Information System", -bgcolor=>"peachpuff");

print '<center>';
print '<img src="http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg">';
print '<br><br><br><br><br>';
print '<h2>';
print '<a href="addRecord.cgi" target="info_main">Add</a><br><br>';
print '<a href="searchbyname.cgi" target="info_main">Search By Name</a><br><br>';
print '<a href="searchbywc.cgi" target="info_main">Search By Wild Card</a><br><br>';
print '<a href="searchbydept.cgi" target="info_main">Search By Dept</a><br><br>';
print '<a href="searchforna.cgi" target="info_main">Search N/A Fields</a><br><br>';
print '<a href="inforeport.cgi" target="info_main">Report</a><br><br>';
print '</h2>';
print '</center>';
print end_html;
