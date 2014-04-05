#! /usr/bin/perl -w

use CGI qw/:standard :html3/;
use 5.004;

# Project: Job Tracking System
# File :   menu.pl
# By:      Phuoc Diec
# Date:    May 28, 1999

# Description:
# This file formats a menu for the user to look up requests that have
# been assigned to him. This menu has three elements:
# - User active requests: view all new and unfinished requests for user.
# - All active requests: view all new and unfinished requests for everyone.
# - User finished requests: view all finished requests for user.
# - All active requests: view all finished requests for everyone.

# ChangeLog:
# 06/06/2000 Prasanth Kumar
# - Added additional menu choices to allow viewing of all active.
# - Changed passed parameters to 'request' and 'who' variables
#   instead of arbitrary constants.
# - Use relative URLs when possible for ease of maintainance.
# 06/07/2000 Prasanth Kumar
# - Moved 'Job Tracking Menu' title to this screen instead of main.
# - Menu entries changed to display actual users name.
# 06/08/2000 Prasanth Kumar
# - Reformatted html for better organization.
# - Enabled perl -w option on first line.
# 06/16/2000 Prasanth Kumar
# - Start quoting all html parameters to remove warnings.

########## GET USERID FROM ENVIRONMENT VARIABLE ##########
$userID = $ENV{REMOTE_USER};

########## PRINT HEADER AND START FORMATTING HTML ##########
print 
    header(-expires=>'now'),
    start_html(-title=>"Job Tracking Menu", -bgcolor=>"#CCCCCC");

print '<center>',
    p(img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"}),
    h3({-align=>'center'}, "Job Tracking System"),
    '<HR>',
    '<BR>',
    '<a href="main.pl?request=active&who=user" target="main">',
    $userID, '\'s active requests</a>',
    '<BR><BR>',
    '<a href="main.pl?request=finished&who=user" target="main">',
    $userID, '\'s finished requests</a>',
    '<BR><BR>',
    '<a href="main.pl?request=active&who=all" target="main">',
    'All active requests</a>',
    '<BR><BR>',
    '<a href="main.pl?request=finished&who=all" target="main">',
    'All finished requests</a>',
    '<BR><BR>',
    '<a href="editList.pl" target="main">',
    'Edit job reassign list</a>',
    '<BR><BR>',
    '<a href="/" target="_top">',
    'Back to the main page</a>',
    '<BR><BR>',
    '<HR>',
    '</center>';

print end_html;
