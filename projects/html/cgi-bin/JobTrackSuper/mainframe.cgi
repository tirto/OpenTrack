#!/usr/bin/perl -w

use CGI qw/:standard :netscape/;

###############################################################################

# Project: Job Tracking System
# File:    mainframe.cgi
# By:      Phuoc Diec
# Date:    augus 2, 1999
# Description:
#   Generate a main window for management module. It is a frame set of three
#   subwindows. 

#   The first window is a menu bar. It includes searching request, listing 
#   requests, editing personel list, and exiting functions.

#   The second window is an option window. It displays options of listing
#   and searching functions and get inputs from users. It is also used to
#   display messages.

#   The third window is used to display results from users' inputs.

###############################################################################


print header;

print
  frameset({-cols=>'23%,*', -border=>'0', -frameborder=>'0'},
           frameset({-rows=>'25%,*', -border=>'0', -frameborder=>'0'},
                    frame({-name=>'menu',-src=>"/cgi-bin/JobTrackSuper/mainmenu.cgi"}),
                    frame({-name=>'options',-src=>"/cgi-bin/JobTrackSuper/mainoptions.cgi"})),
           frame({-name=>'display', -src=>"/cgi-bin/JobTrackSuper/maindisplay.cgi"})
          );








