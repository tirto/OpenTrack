<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue">
<center>
<?php
    
/*
 * lab_list.php
 * for displaying all the laboratory labs
 *
 * @version 1.0 
 * @date 12-14-00
 * @author Tirto Adji
 *
 * @update 01-09-01
 * # added link to classroom schedule by passing bldg and room param
 * #   
 */

// include common function library
include ("commonlib.php");

if ($room) {
    print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"3\" cellpadding=\"5\">\n";
    $room_id = $room;
    if ($software) { 
         print "<BR><H2 ALIGN='center'>$bldg $room  Software Info</H2>";
	 $tablename = 'newsoftware';
         $stmt = OCIParse($conn,"select * from $tablename where building = '$bldg' and roomnumber = '$room'");
	 OCIExecute($stmt);
	 $nrows = OCIFetchStatement($stmt,$results);
	 $soft_id = $results["ID"];
	 $dept = trim($results["DEPARTMENT"][0]);
         if ( $nrows > 0 ) {
	     print "<TR><TD align=left colspan=\"3\">Click the Room Number to Update/Delete Entry</a>\n";
             print "    <TD align=right colspan=\"3\"><a href=input.php?bldg=$bldg&room=$room&dept=$dept>Add New Lab Software</a></TD></TR>\n";
	     print "<TR>\n";
	     while ( list( $key, $val ) = each( $results ) ) {
		 if ($key == 'ID') {
		     //do nothing
		 }
		 else {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">$key</TH>\n";
	         }
	     }

	     print "</TR>\n";
             $rec_per_page = 10; 
	     if (!$page) {
		 $startidx = 0;
		 $page=$rec_per_page;
	     }
	     else {
		 $maxpage = $nrows/$rec_per_page+1;
                 if ($page >= $maxpage) { // we decrement the page if greater than maxpage
                     $page--;
                 }
                 $page *= $rec_per_page;
		 $startidx = $page - $rec_per_page;
	     }

	     for ( $i = $startidx; $i < $page; $i++ ) {
		 reset($results);
		 print "<TR>\n";
		 while ( $column = each($results) ) {   
		     $data = $column['value'];
		     $colname = $column['key'];
		     if ($colname == 'ID') {
		     }
		     elseif ($colname == 'ROOMNUMBER') {
                         $curpage=$page/$rec_per_page; 
                         $room = $data[$i];
                         print "<TD><a href=edit_soft.php?bldg=$bldg&room=$room&page=$curpage&id=$soft_id[$i]>$room</a></td>";

		     } 
		     elseif ($colname == 'DEPARTMENT') {
			 $deptName = convertDept(trim($data[$i]));
			 print "<TD>$deptName</TD>";
		     }	
		     else {
			 print "<TD>$data[$i]</TD>\n";
	             }		 
		 }
		 print "</TR>\n";
	     }
	     print "</TABLE>\n";
	     $recordnum = $startidx+1;
	     if ($page > $nrows) {
		 $page = $nrows;
	     }
	     print "<br>Displaying record $recordnum to $page of $nrows records";

	     if ($nrows > $rec_per_page) { 
               print "<br><br>Go to page &nbsp; &nbsp; &nbsp;  "; 
 	         $prev = $curpage - 1;
 	         $next = $curpage + 1;
	         if ($prev != 0) {
      		     print "<a href=$PHP_SELF?bldg=$bldg&room=$room&page=$prev&software=yes>Prev</a>&nbsp; &nbsp; &nbsp  ";
                 }
                   
               for ($pageidx = 1; $pageidx < $nrows/$rec_per_page +1; $pageidx++) {
		 if ($pageidx == $curpage) {
		     print "<font color=red>$pageidx</font>&nbsp; &nbsp; &nbsp  ";
		 }
		 else {
		     print "<a href=$PHP_SELF?bldg=$bldg&room=$room&page=$pageidx&software=yes>$pageidx</a>&nbsp; &nbsp; &nbsp  ";
		 }
	       }

	       if ($next < $nrows/$rec_per_page+1) {
   		     print "<a href=$PHP_SELF?bldg=$bldg&room=$room&page=$next&software=yes>Next</a>&nbsp; &nbsp; &nbsp  ";
                }

             }
             
	 } else {
	     echo "No data found<BR>\n";
     	     print "<br><br><a href=input.php?bldg=$bldg&room=$room>Add New Lab Software</a>";
	 }	

	 print "<br><br><a href=$PHP_SELF?bldg=$bldg&room=$room_id>Back to lab info</a>";
	 OCIFreeStatement($stmt);
	 OCILogoff($conn);
 	 return;
 	
    }
    elseif ($hardware) {
        print "<BR><H2 ALIGN='center'>$bldg $room  Hardware Info</H2>";
	 $tablename = 'newhardware';
         $stmt = OCIParse($conn,"select * from $tablename where building = '$bldg' and roomnumber = '$room'");
	 OCIExecute($stmt);
	 $nrows = OCIFetchStatement($stmt,$results);
	 $soft_id = $results["ID"];
 	 $dept = trim($results["DEPARTMENT"][0]);
	 $room_id = $room;
         if ( $nrows > 0 ) {
	     print "<TR><TD align=left colspan=\"3\">Click the Room Number to Update/Delete Entry</a>\n";
	     print "<TD align=right colspan=3><a href=input_hard.php?bldg=$bldg&room=$room&dept=$dept>Add New Lab Hardware</a></TD></TR>\n";
             print "<TR>\n";
	     while ( list( $key, $val ) = each( $results ) ) {
		 if ($key == 'ID') {
		     //do nothing
		 }
		 else {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">$key</TH>\n";
	         }
	     }

	     print "</TR>\n";
             $rec_per_page=10;
	     if (!$page) {
		 $startidx = 0;
		 $page=$rec_per_page;
	     }
	     else {
		 $maxpage = $nrows/$rec_per_page+1;
                 if ($page >= $maxpage) { // we decrement the page if greater than maxpage
                     $page--;
                 }
                 $page *= $rec_per_page;
		 $startidx = $page - $rec_per_page;
	     }

	     for ( $i = $startidx; $i < $page; $i++ ) {
		 reset($results);
		 print "<TR>\n";
		 while ( $column = each($results) ) {   
		     $data = $column['value'];
		     $colname = $column['key'];
		     if ($colname == 'ID') {
		     }
		     elseif ($colname == 'ROOMNUMBER') {
                         $curpage=$page/$rec_per_page; 
                         $room = $data[$i];
                         print "<TD><a href=edit_hard.php?bldg=$bldg&room=$room&page=$curpage&id=$soft_id[$i]>$room</a></td>";
		     } 
		     elseif ($colname == 'DEPARTMENT') {
			 $deptName = convertDept(trim($data[$i]));
			 print "<TD>$deptName</TD>";
		     }	
		     else {
			 print "<TD>$data[$i]</TD>\n";
	             }		 
		 }
		 print "</TR>\n";
	     }
	     print "</TABLE>\n";
	     $recordnum = $startidx+1;
	     if ($page > $nrows) {
		 $page = $nrows;
	     }
	     print "<br>Displaying record $recordnum to $page of $nrows records";

	     if ($nrows > $rec_per_page) { 
               print "<br><br>Go to page &nbsp; &nbsp; &nbsp;  "; 
 	         $prev = $curpage - 1;
 	         $next = $curpage + 1;
	         if ($prev != 0) {
      		     print "<a href=$PHP_SELF?bldg=$bldg&room=$room&page=$prev>Prev</a>&nbsp; &nbsp; &nbsp  ";
                 }
                 
               for ($pageidx = 1; $pageidx < $nrows/$rec_per_page +1; $pageidx++) {
		 if ($pageidx == $curpage) {
		     print "<font color=red>$pageidx</font>&nbsp; &nbsp; &nbsp  ";
		 }
		 else {
		     print "<a href=edit_hard.php?bldg=$bldg&room=$room&page=$pageidx>$pageidx</a>&nbsp; &nbsp; &nbsp  ";
		 }
	       }

	        if ($next < $nrows/$rec_per_page+1) {
   		     print "<a href=edit_soft.php?bldg=$bldg&room=$room&page=$next>Next</a>&nbsp; &nbsp; &nbsp  ";
                }

             }

	 } else {
	     echo "No data found<BR>\n";
	     print "<br><br><a href=input_hard.php?bldg=$bldg&room=$room>Add New Lab Hardware</a>";
	 }	

	 print "<br><br><a href=$PHP_SELF?bldg=$bldg&room=$room_id>Back to lab info</a>";
	 OCIFreeStatement($stmt);
	 OCILogoff($conn);
 	 return;
    }
    
    elseif ($usage) {
         print "<BR><H2 ALIGN='center'>$bldg $room  Usage Info</H2>";
	 $tablename = 'laboratory';
         $stmt = OCIParse($conn,"select * from $tablename where building= '$bldg' and roomnumber = '$room'");
	 OCIExecute($stmt);
	 $nrows = OCIFetchStatement($stmt,$results);
	 $soft_id = $results["ID"];
         if ( $nrows > 0 ) {
	     print "<TR><TD align=left colspan=\"6\">Click the Room Number to Update/Delete Entry</a></TD>";
	     print "<TD align=right colspan=5><a href=input_lab.php?bldg=$bldg>Add New Lab Usage</a></TD></TR>\n";
	     while ( list( $key, $val ) = each( $results ) ) {
		 if ($key == 'ID') {
		     //do nothing
		 }
		 elseif ($key == 'BUILDING') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">BLDG</TH>\n";
		 } 
		 elseif ($key == 'ROOMNUMBER') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">ROOM</TH>\n";
		 }
		 elseif ($key == 'DEPARTMENT') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">DEPT</TH>\n";
		 }
		 elseif ($key == 'SUPPORTDESCRIPTION') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">SUPPORT</TH>\n";
		 } 
		 elseif ($key == 'DIRECTORFIRSTNAME') {
		     //print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">FIRST</TH>\n";
		 }
		 elseif ($key == 'DIRECTORLASTNAME') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">DIRECTOR</TH>\n";
		 }
		 elseif ($key == 'INTERNETACCESS') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\"><FONT SIZE=-1>INTERNET<BR>ACCESS</FONT></TH>\n";
		 }
		 elseif ($key == 'TRAFFICSPRING') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\"><FONT SIZE=-1>TRAFFIC<BR>SPRING</FONT></TH>\n";
		 }
		 elseif ($key == 'TRAFFICFALL') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\"><FONT SIZE=-1>TRAFFIC<BR>FALL</FONT></TH>\n";
		 }
		 elseif ($key == 'USEDOVERBREAKS') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\"><FONT SIZE=-1>OVER<BR>BREAKS<BR>USAGE</FONT></TH>\n";
		 }
		 elseif ($key == 'SUPPORTHOURSPERWEEK') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\"><FONT SIZE=-1>HRs<br>per<br>WEEK</FONT></TH>\n";
		 }
		 else {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">$key</TH>\n";
	         }
	     } // end while
	     print "</TR>\n";
	     reset($results);
	     print "<TR>\n";
	     $i = 0;
	     $page = 5;
		 while ( $column = each($results) ) {   
		     $data = $column['value'];
		     $colname = $column['key'];
		     
		     if ($colname == 'ROOMNUMBER') {
                         $curpage=$page/5; 
                         $room = $data[$i];
                         print "<TD><a href=edit_lab.php?bldg=$bldg&room=$room&page=$curpage&id=$room>$room</a></td>";
		     } 
		     elseif ($colname == 'DIRECTORFIRSTNAME'){
                         $sfirstname = $data[$i];
			 $fn = urlencode($sfirstname);
		     }
		     elseif ($colname == 'DIRECTORLASTNAME'){
			 $slastname = $data[$i];
			 $ln = urlencode($slastname);
			 print "<TD><a href=http://dolphin.engr.sjsu.edu/cgi-bin/public/searchbyname.cgi?search=Search&sbool=and&sfirstname=$fn&slastname=$ln>$sfirstname $slastname</a></TD>";
		     }
		     elseif ($colname == 'DEPARTMENT') {
			 $deptName = convertDept(trim($data[$i]));
			 print "<TD>$deptName</TD>";
		     }	  
		     else {
			 print "<TD>$data[$i]</TD>\n";
	             }		 
		 }
		 print "</TR>\n";
	 } // end if nrows > 0
         else {
	     echo "No data found<BR>\n";
	     print "<br><br><a href=input_lab.php?bldg=$bldg>Add New Lab Usage</a>";

	 }	
	 print "</TABLE>";
	 print "<br><br><a href=$PHP_SELF?bldg=$bldg&room=$room_id>Back to lab info</a>";
	 OCIFreeStatement($stmt);
	 OCILogoff($conn);
 	 return;
	
    } // end usage
    

    else {
	print "<BR><H2 ALIGN='center'>$bldg $room  Laboratory Info</H2>";
        print "<TR><TD align=left colspan=\"6\">Click the Link Below for More Info</TD></TR>\n";
	print "<TR><TD><a href=lab_info.php?usage=yes&bldg=$bldg&room=$room>Usage</a></TD></TR>";
	print "<TR><TD><a href=lab_info.php?software=yes&bldg=$bldg&room=$room>Software</a></TD></TR>";
	print "<TR><TD><a href=lab_info.php?hardware=yes&bldg=$bldg&room=$room>Hardware</a></TD></TR>";
	print "<TR><TD><a href=http://ecs-staff14.engr.sjsu.edu/cgi-bin/schedule/schedule.pl?bldg=$bldg&room=$room>Schedule</a></TD></TR>";
	print "</TABLE>";
    }

}

print "</BODY>";
print "</HTML>";




?>    

