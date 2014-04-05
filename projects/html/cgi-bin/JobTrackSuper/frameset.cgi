#!/usr/bin/perl

use CGI qw/:standard/;
use 5.004;

print header(),
    '<HEAD><TITLE>"Job Tracking Request Management"</TITLE></HEAD>';

print '<frameset cols="176,*" border=0 frameborder=0>',
    '<frame name="menu" src="/cgi-bin/JobTrackSuper/menu.cgi" scrolling="no" marginheight=1 marginwidth=4>',
    '<frame name="main" src="/cgi-bin/JobTrackSuper/jobManage.pl" scrolling="auto" marginheight=6 marginwidth=8>',
    '</frameset>';

print '<noframes>',
    'You need a frames capable browser to view this page',
    '</noframes>';

print '<HTML>';
