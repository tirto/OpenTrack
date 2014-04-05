#!/usr/bin/perl -w

use CGI qw/:standard :netscape/;

# Project: Job Tracking System
# File:    requestFrame.pl
# By:      Prasanth Kumar
# Date:    Jun 21, 2000

# Description:
# This file sets up a main frame for people to place job requests.
# Browser window is partition into two. The left partition is a small part that
# displays the menu. The right partition is where information is displayed.

# ChangeLog:
# 06/21/2000 Prasanth Kumar
# - Modified for job request page

print header;

print frameset({-cols=>'23%,*', -border=>'0', -frameborder=>'0'},
	       frame({-name=>'menu',-src=>"requestMenu.pl", -scrolling=>'no'}),
	       frame({-name=>'main',-src=>"requestMain.pl"}));

print end_html();
