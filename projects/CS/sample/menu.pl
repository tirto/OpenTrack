#! /usr/bin/perl -w

use CGI qw/:standard :html3 *center *table/;
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
# 08/11/2000 Prasanth Kumar
# - Add newlines to make html source look nicer.
# - Convert html tag strings to use CGI functions.
# 12/05/2000 Prasanth Kumar
# - Add menu item for keyword searches.
# 12/06/2000 Prasanth Kumar
# - Add menu item for charge summary.

########## PRINT HEADER AND START FORMATTING HTML ##########
my $user_id = remote_user();

print 
    header(-expires=>'now'),
    start_html(-title=>"Job Tracking Menu", -bgcolor=>"#CCCCCC");

print start_center(),
    p(img({-src=>"/sjsu-coe.jpg"})), "\n",
    h3({-align=>'center'}, "Job Tracking System"), hr, br, "\n",
    a({-href=>"main.pl?request=active&who=user", -target=>'main'},
      $user_id, '\'s active requests'), br, br, "\n",
    a({-href=>"main.pl?request=finished&who=user", -target=>"main"},
      $user_id, '\'s finished requests'), br, br, "\n",
    a({-href=>"main.pl?request=active&who=all", -target=>"main"},
      'All active requests'), br, br, "\n",
    a({-href=>"main.pl?request=finished&who=all", -target=>"main"},
      'All finished requests'), br, br, "\n",
    a({-href=>"main.pl?request=keyword&who=all", -target=>"main"},
      'Keyword search'), br, br, "\n",
    a({-href=>"chargeSummary.pl", -target=>"main"},
      'Charge summary'), br, br, "\n",
    a({-href=>"editList.pl", -target=>"main"},
      'Edit job reassign list'), br, br, "\n",
    a({-href=>"/", -target=>"_top"},
      'Back to the main page'), br, br, hr, "\n",
    end_center(), "\n";

print end_html;
