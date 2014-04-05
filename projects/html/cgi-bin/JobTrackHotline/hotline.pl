#!/usr/bin/perl -w

use CGI qw/:standard :netscape/;

# Project: Job Tracking System
# File:    hotline.pl
# By:      Phuoc Diec
# Date:    May 28, 1999

# Description:
# This file sets up a main frame for hotline persons to retrieve job requests.
# Browser window is partition into two. The left partition is a small part that
# displays the menu. The right partition is where information is displayed.

# ChangeLog:
# 06/06/2000 Prasanth Kumar
# - Use relative URLs for ease of maintainance.
# 06/07/2000 Prasanth Kumar
# - Use scrolling tag of menu frame to no.
# 06/12/2000 Prasanth Kumar
# - Enabled perl -w option on first line.

print header;

print
    frameset({-cols=>'23%,*', -border=>'0', -frameborder=>'0'},
	     frame({-name=>'menu',-src=>"menu.pl", -scrolling=>'no'}),
	     frame({-name=>'main',-src=>"main.pl"})
	     );

print end_html();
