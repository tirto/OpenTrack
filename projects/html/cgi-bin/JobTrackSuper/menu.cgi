#!/usr/bin/perl -w

use CGI qw/:standard :html3/;
use 5.004;

print header(),
    start_html(-title=>"Job Tracking Request Management", -bgcolor=>"#0000FF");


print '<center>';

print '<table cellpadding=0 cellspacing=1 border=0 width=146>';

print '<tr><td>&nbsp;</td></tr>';

print '<tr><td colspan=2 align=center><img src="http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg" width=137></td></tr>';

print '<tr><td>&nbsp;</td></tr>';

print '<tr><td align=center bgcolor="#FFFFCC" width=130 nowrap><font size=+1><a href="/cgi-bin/JobTrackSuper/jobManage.pl?page=1" onmouseover="window.status=\'Displays new, not yet affected requests\'; return true;" onmouseout="window.status=\'\'; return true;" target="main">New Requests</a></font></td>';
print '<td bgcolor="#00FF00" width=12>&nbsp;&nbsp;&nbsp;</a></td></tr>';

print '<tr><td align=center bgcolor="#FFFFCC" width=130 nowrap><font size=+1><a href="/cgi-bin/JobTrackSuper/jobManage.pl?page=2" onmouseover="window.status=\'Displays current, in process requests\'; return true;" onmouseout="window.status=\'\'; return true;" target="main">Processed Requests</a></font></td>';
print '<td bgcolor="#FFFF00" width=12>&nbsp;&nbsp;&nbsp;</a></td></tr>';

print '<tr><td align=center bgcolor="#FFFFCC" width=130 nowrap><font size=+1><a href="/cgi-bin/JobTrackSuper/jobManage.pl?page=3" onmouseover="window.status=\'Displays old, already finished requests\'; return true;" onmouseout="window.status=\'\'; return true;" target="main">Finished Requests</a></font></td>';
print '<td bgcolor="#FF00FF" width=12>&nbsp;&nbsp;&nbsp;</a></td></tr>';

print '<tr><td align=center bgcolor="#FFFFCC" width=130 nowrap><font size=+1><a href="/cgi-bin/JobTrackSuper/delJob.pl?" onmouseover="window.status=\'Displays old, already finished requests\'; return true;" onmouseout="window.status=\'\'; return true;" target="main">Delete Requests</a></font></td>';
print '<td bgcolor="#FF0000" width=12>&nbsp;&nbsp;&nbsp;</a></td></tr>';

print '<tr><td align=center bgcolor="#FFFFCC" width=130 nowrap><font size=+1><a href="/cgi-bin/JobTrackSuper/editList.pl" onmouseover="window.status=\'Click to edit the assign list\'; return true;" on mouseout="window.status=\'\'; return true;" target="main">Edit Assign List</a></font></td>';
print '<td bgcolor="#00CCFF" width=12>&nbsp;&nbsp;&nbsp;</td></tr>';

print '<tr><td align=center bgcolor="#FFFFCC" width=130 nowrap><font size=+1><a href="/" onmouseover="window.status=\'Returns to the Engineering Computing Service welcome page\'; return true;" on mouseout="window.status=\'\'; return true;" target="_parent">ECS Homepage</a></font></td>';
print '<td bgcolor="#000000" width=12>&nbsp;&nbsp;&nbsp;</td></tr>';

print '</table>';

print '</center>';

print end_html;



