#! /usr/bin/perl -w

use CGI qw/:standard :html3/;
use 5.004;

# Project: Job Tracking System
# File :   requestMenu.pl
# By:      Prasanth Kumar
# Date:    Jun 21, 2000

# Description:
# This file formats a menu for the user to enter requests.
# - Job Request : place a new job request.
# - Info System : go to the COE information system.
# - Home Page : go to the COE home page.

# ChangeLog:
# 06/20/2000 Prasanth Kumar
# - Modified for use with job requests page
# 06/29/2000 Prasanth Kumar
# - Fixed more typos and links

########## PRINT HEADER AND START FORMATTING HTML ##########
print 
    header(-expires=>'now'),
    start_html(-title=>"Job Tracking Menu", -bgcolor=>"#CCCCCC");

print '<center>',
    p(img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"}),
    h3({-align=>'center'}, "Job Tracking System"),
    hr,br,
    '<a href="requestMain.pl" target="main">',
    'Place a job request</a>',
    br,br,
    '<a href="/cgi-bin/public/info.cgi" target=_top">',
    'COE Information System</a>',
    br,br,
    '<a href="http://www.engr.sjsu.edu/ecs" target="_top">',
    'Back to the home page</a>',
    br,br,
    hr, '</center>';

print end_html;














