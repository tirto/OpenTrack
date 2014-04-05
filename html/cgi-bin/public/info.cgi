#! /usr/bin/perl

use CGI qw/:standard :html3/;


########## STARTING THE HEADER ##########
print header,
      '<head><title>COE Information System</title></head>';

print '<frameset cols="18%,*" border=0>';
print '<frame src="info_menu.cgi" name="info_menu">';
print '<frame src="info_welcome.cgi" name="info_main">';
print '</frameset>';
print '</html>';
