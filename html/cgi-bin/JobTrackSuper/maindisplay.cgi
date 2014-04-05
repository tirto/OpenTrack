#!/usr/bin/perl -w

use CGI qw/:standard :html3/;
use 5.004;

print header();

print start_html(-title=>"Job Tracking Request Management", -bgcolor=>"#00DDFF");


print '<center>';

print '<BR><BR><BR>';
print '<IMG SRC="/CoeTurn.gif">';
print '<BR><BR><BR>';
print '<FONT SIZE="+3" COLOR="#0000FF">Welcome</FONT>';
print '</center>';

print end_html;

