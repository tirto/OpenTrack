<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue">
<center>
<?php

/*
 * edit_lab.php
 * for editing or deleting the laboratory table
 *
 * @version 1.0 
 * @date 11-08-00
 * @author Tirto Adji
 */

######################## START FUNCTIONS ###################################

include ("commonlib.php");

function internet_access($int) {
    if ($int == 'Y') {
	print "<INPUT NAME='internetaccess' TYPE=RADIO VALUE='Y' checked>Yes";
	print "&nbsp;&nbsp;<INPUT NAME='internetaccess' TYPE=RADIO VALUE='N'>No";
    }
    else {
	print "<INPUT NAME='internetaccess' TYPE=RADIO VALUE='Y'>Yes";
	print "&nbsp;&nbsp;<INPUT NAME='internetaccess' TYPE=RADIO VALUE='N' checked>No";
    }  	
} 

function usage_over_breaks($u) {
    if ($u == 'Y') {
	print "<INPUT NAME='usedoverbreaks' TYPE=RADIO VALUE='Y' checked>Yes";
	print "&nbsp;&nbsp;<INPUT NAME='usedoverbreaks' VALUE='N' TYPE=RADIO>No";
    }
    else {
	print "<INPUT NAME='usedoverbreaks' TYPE=RADIO VALUE='Y'>Yes";
	print "&nbsp;&nbsp;<INPUT NAME='usedoverbreaks' VALUE='N' TYPE=RADIO checked>No";
    }  	
} 

function traffic_fall($fa) {
    if ($fa == 'Hvy') {
	print "<INPUT NAME='trafficfall' TYPE=RADIO checked VALUE='Hvy'>Heavy";
	print "&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Med'>Medium";
	print "&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Lite'>Lite";
    }
    elseif ($fa == 'Med') {
	print "<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Hvy'>Heavy";
	print "&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Med' checked>Medium";
	print "&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Lite' >Lite";
    }
    elseif ($fa == 'Lite') {
	print "<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Hvy' >Heavy";
	print "&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Med'>Medium";
	print "&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO  VALUE='Lite' checked>Lite";
    }   	
} 

function traffic_spring($sp) {
    if ($sp == 'Hvy') {
	print "<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Hvy' checked>Heavy";
	print "&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Med'>Medium";
	print "&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Lite'>Lite";
    }
    elseif ($sp == 'Med') {
	print "<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Hvy' >Heavy";
	print "&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO  VALUE='Med' checked>Medium";
	print "&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Lite'>Lite";
    }
    elseif ($sp == 'Lite') {
	print "<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Hvy'>Heavy";
	print "&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Med'>Medium";
	print "&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Lite' checked>Lite";
    }   	
} 

######################## END FUNCTIONS ###################################

$tablename = "laboratory";

if ($id) { // id exist
    
    if ($submit) { // update record in the database
	if (!$roomnumber | !$name |!$directorlastname |!$directorfirstname |!$internetaccess) {
	    print "<br><b>Missing input, update failed!</b>";
	    if ($room) {
                print "<br><br><a href=$PHP_SELF?room=$room&id=$id>Back to update page</a>";
	    }
            else {
	        print "<br><br><a href=$PHP_SELF?id=$id&page=$page>Back to update page</a>";	     
            }
	    return;
	}
	
	if (!eregi("^[0-9]{3}[A-Za-z]{0,1}$", $roomnumber)) { 
	    print "<br><b>Invalid roomnumber</b>, roomnumber format must be 123 or 123A";
	    if ($room) {
                print "<br><br><a href=$PHP_SELF?room=$room&id=$id>Back to update page</a>";
	    }
            else {
	        print "<br><br><a href=$PHP_SELF?id=$id&page=$page>Back to update page</a>";	     
            }
	    return;
	}
        
	else {
         	$sth1 = "UPDATE $tablename SET BUILDING='$building', NAME='$name', DEPARTMENT='$department',
		         DIRECTORFIRSTNAME='$directorfirstname', DIRECTORLASTNAME = '$directorlastname',
		         INTERNETACCESS = '$internetaccess', TRAFFICSPRING='$trafficspring', TRAFFICFALL='$trafficfall', 
		         USEDOVERBREAKS='$usedoverbreaks', SUPPORTDESCRIPTION='$support', SUPPORTHOURSPERWEEK='$hrsperweek'
                         WHERE ROOMNUMBER='$id'";
		execute($conn,$sth1);
                $dept = convertDept($department);
                print "<table border=0>";
		print "<tr><th colspan=3>You have entered the following info:</td></tr> ";
                print "<tr><td>Lab Name      </td><td> :  </td><td>$name</td></tr>";
                print "<tr><td>Department    </td><td> :  </td><td>$dept</td></tr>";
                print "<tr><td>Director      </td><td> :  </td><td>$directorfistname $directorlastname</td></tr>";
                print "<tr><td>Building      </td><td> :  </td><td>$building</td></tr>";
                print "<tr><td>Room no       </td><td> :  </td><td>$roomnumber</td></tr>";
                print "<tr><td>Internet      </td><td> :  </td><td>$internetaccess</td></tr>";
                print "<tr><td>Spring        </td><td> :  </td><td>$trafficspring</td></tr>";
                print "<tr><td>Fall          </td><td> :  </td><td>$trafficfall</td></tr>";
                print "<tr><td>Used over breaks </td><td> :  </td><td>$usedoverbreaks</td></tr>";
                print "<tr><td>Support       </td><td> :  </td><td>$support</td></tr>";
                print "<tr><td>Hrs/week      </td><td> :  </td><td>$hrsperweek</td></tr>";
		print "</table>";
                print "<br><b>Thank you, information updated.</b>\n";		 
		if ($room) {
                   print "<br><br><a href=lab_info.php?bldg=$bldg&room=$room&id=$room>Back to Lab Info</a>";
	        }
		else {
	           print "<br><br><a href=$PHP_SELF?page=$page>Back to update page</a>";
                }
        } 
    } elseif ($delete) { // delete record from the database
      
      if ($delete=='Confirmed') {
        $sth4 = "DELETE FROM newhardware WHERE ROOMNUMBER='$id'";
        execute($conn,$sth4); 
        $sth3 = "DELETE FROM newsoftware WHERE ROOMNUMBER='$id'";
        execute($conn,$sth3); 
        $sth2 = "DELETE FROM $tablename WHERE ROOMNUMBER='$id'";
        execute($conn,$sth2);
        $dept = convertDept($department);
        print "<table border=0>";
	print "<tr><th colspan=3>You have deleted all entry of the following lab:</td></tr> ";
        print "<tr><td>Lab Name      </td><td> :  </td><td>$name</td></tr>";
        print "<tr><td>Building      </td><td> :  </td><td>$building</td></tr>";
        print "<tr><td>Room no       </td><td> :  </td><td>$roomnumber</td></tr>";
        print "<tr><td>Department    </td><td> :  </td><td>$dept</td></tr>";
	print "</table>";
        print "<br><b>Delete confirmed.</b>\n";		 
	if ($room) {
	   print "<br><br><a href=lab_list.php>Back to lab listing</a>";
	}
	else {
 	   print "<br><br><a href=$PHP_SELF?page=$page>Back to update page</a>";	
        }
      }

      else {
          print "<br><br>Are you sure to delete lab usage information in room $bldg $roomnumber?\n";
          print "<br><b>Note:</b> By clicking confirmed all software and hardware information in this lab will be deleted.\n";
          print "<form method='post' action=\"$PHP_SELF\">\n";
	  if ($room) {
	    print "<input type='hidden' name='room' value='$roomnumber'>\n";
	  }
          print "<input type='hidden' name='name' value='$name'>\n";
          print "<input type='hidden' name='building' value='$building'>\n";
          print "<input type='hidden' name='bldg' value='$bldg'>\n";
          print "<input type='hidden' name='roomnumber' value='$roomnumber'>\n";
          print "<input type='hidden' name='page' value='$page'>\n";
          print "<input type='hidden' name='id' value='$roomnumber'>\n";
          print "<input type='hidden' name='department' value='$department'>\n";
          print "<TABLE ALIGN='center' CELLSPACING='5' BORDER='0' CELLPADDING='0'>\n";
          print "<TR>";
          print " <TD ALIGN='center'><INPUT TYPE='submit' name='delete' VALUE='Confirmed'></TD>\n";
          print " <TD ALIGN='center'><INPUT TYPE='submit' name='cancel' VALUE='Cancel'></TD>\n";
          print "</TR>";
          print "</TABLE>\n";
          print "</form>\n";     		   
      }
       
    } else { // edit record
	print "<BR><H2 ALIGN='center'>Lab Usage Update Page</H2>";
        print "<P ALIGN=\"center\">(*) You must fill in this field</P>";
       	$stmt = OCIParse($conn,"select * from $tablename where roomnumber = '$id'");
	OCIExecute($stmt);
	OCIFetch($stmt);
	
?>
        <!-- display edit entry form -->
	<form method="post" action="<?php echo $PHP_SELF?>" onSubmit = "return validate()">
	    
           <TABLE ALIGN="center" CELLSPACING="2" BORDER="2" CELLPADDING="2">
	    <!-- pass current page and id info -->
            <input type=hidden name="id" value="<?php echo ociresult($stmt,"ROOMNUMBER") ?>">
            <input type=hidden name="page" value="<?php echo $page?>">
            <input type=hidden name="room" value="<?php echo $room?>">
            <input type=hidden name="bldg" value="<?php echo $bldg?>"> 
	       <TR>
                <TH colspan=4 align=center>Lab Info</TH>
	      </TR>
	      <TR>	
	      <TR>
		<TD BGCOLOR="#CCEEFF">Building(*)</TD> 
		<TD>
		    <?php 
			$bldg = trim(ociresult($stmt,"BUILDING"));
	                building_popup_menu($bldg)
		    ?>
		</TD> 
		<TD BGCOLOR="#CCEEFF">Room number(*)</TD> 
		<TD><INPUT TYPE="text" NAME="roomnumber" VALUE="<?php echo ociresult($stmt,"ROOMNUMBER")?>"></TD>
	      </TR>
	      <TR>
                <TD BGCOLOR="#CCEEFF">Lab Name(*)</TD> 
                <TD><INPUT TYPE="text" NAME="name" VALUE="<?php echo ociresult($stmt,"NAME")?>"></TD> 
                <TD BGCOLOR="#CCEEFF">Department(*)</TD> 
                <TD><?php 
		        $dept = trim(ociresult($stmt,"DEPARTMENT"));
	                department_selection($dept);
		     ?>
                </TD>          
	      </TR>
           </TABLE>
           <TABLE ALIGN="center" CELLSPACING="2" BORDER="2" CELLPADDING="2">

	      <TR>
                <TH colspan=4 align=center BGCOLOR="white">Director Name</TH>
	      </TR>
	      <TR>	  
	        <TD BGCOLOR="#CCEEFF">First(*)</TD> 
                <TD><INPUT TYPE="text" NAME="directorfirstname" VALUE="<?php echo ociresult($stmt,"DIRECTORFIRSTNAME")?>"></TD> 
                <TD BGCOLOR="#CCEEFF">Last(*)</TD> 
                <TD><INPUT TYPE="text" NAME="directorlastname" VALUE="<?php echo ociresult($stmt,"DIRECTORLASTNAME")?>"></TD>     
             </TR>
	      <TR>
                <TH colspan=4 align=center BGCOLOR="white">Lab Usage</TH>
	     </TR>
	     <TR>
                <TD BGCOLOR="#CCEEFF">Internet Access(*)</TD> 
                <TD><?php 
		       $internet= trim(ociresult($stmt,"INTERNETACCESS"));
	               internet_access($internet);
		     ?>
		</TD> 
                <TD BGCOLOR="#CCEEFF">Over Breaks Usage(*)</TD> 
		<TD>
		   <?php 
		       $usage= trim(ociresult($stmt,"USEDOVERBREAKS"));
	               usage_over_breaks($usage);
		     ?> 
		</TD>         
  	     </TR>
	     
	     <TR>
                <TD BGCOLOR="#CCEEFF">Traffic in Spring(*)</TD> 
                <TD>
		   <?php 
		       $spring= trim(ociresult($stmt,"TRAFFICSPRING"));
	               traffic_spring($spring);
		     ?>    
		</TD>
		<TD BGCOLOR="#CCEEFF">Traffic in Fall(*)</TD> 
                <TD>
		    <?php 
		       $fall= trim(ociresult($stmt,"TRAFFICFALL"));
	               traffic_fall($fall);
		     ?>  
		</TD>  
             </TR>
	     <TR>
	        <TD BGCOLOR="#CCEEFF">Support</TD>
		<TD colspan=1><TEXTAREA NAME="support" ROWS=2 COLS=20 WRAP="virtual"><?php echo ociresult($stmt,"SUPPORTDESCRIPTION")?></TEXTAREA></TD>
		<TD BGCOLOR="#CCEEFF">Hrs/week</TD>
		<TD><INPUT TYPE="text" NAME="hrsperweek" VALUE="<?php echo ociresult($stmt,"SUPPORTHOURSPERWEEK")?>"></TD>
	      </TR>
	    </TABLE>
	    <TABLE ALIGN="center" CELLSPACING="5" BORDER="0" CELLPADDING="0">
	    <TR>
		<TD ALIGN="center"><input type="submit" name="submit" value="Update information"></TD>
		<TD ALIGN="center"><INPUT TYPE="submit" name="delete" VALUE="Delete"></TD>
	    </TR>
	    </TABLE>
	</form>
	<!-- end edit entry form -->    

<?php

    } // end else id exist


} else {
         
	 // display lab list
         $clause = "order by building , roomnumber"; 
	 if ($room) {
	     $clause =  "where roomnumber = '$room' and building = 'bldg'";
	 }
	 $stmt = OCIParse($conn,"select * from $tablename $clause");
	 OCIExecute($stmt);
	 $nrows = OCIFetchStatement($stmt,$results);
	 $soft_id = $results["ID"];
	 if ( $nrows > 0 ) {
	     print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"3\" cellpadding=\"5\">\n";
	     print "<BR><H2 ALIGN='center'>COE Lab Usage</H2>";
	     print "<TR>";
             print "    <TD align=left colspan=\"6\">Click the Room Number for More Info</TD>";
             print "    <TD align=right colspan=5><a href=input_lab.php>Add New Lab Usage</a></TD>";
             print "</TR>\n";
	     print "<TR>\n";
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
	     }

	     print "</TR>\n";

	     $rec_per_page = 5;
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
		     
		     if ($colname == 'ROOMNUMBER') {
                         $curpage=$page/$rec_per_page; 
                         $roomnumber = $data[$i];
			 if ($room) {
			     print "<TD><a href=$PHP_SELF?bldg=$bldg&room=$room&page=$curpage&id=$roomnumber>$roomnumber</a></td>";
			 }
			 else {
			     print "<TD><a href=$PHP_SELF?page=$curpage&id=$roomnumber>$roomnumber</a></td>";
			 }    
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
	     }
	     print "</TABLE>\n";
	     $recordnum = $startidx+1;
	     if ($page > $nrows) {
		 $page = $nrows;
	     }
	     
	     if (!$room) {
		 print "<br>Displaying record $recordnum to $page of $nrows records";
             } 
	     if ($nrows > $rec_per_page ) {
	       print "<br><br>Go to page &nbsp; &nbsp; &nbsp;  ";
	       $prev = $curpage - 1;
 	       $next = $curpage + 1;
	       if ($prev != 0) {
                   print "<a href=$PHP_SELF?page=$prev>Prev</a>&nbsp; &nbsp; &nbsp  ";
               }
	       for ($pageidx = 1; $pageidx < $nrows/$rec_per_page +1; $pageidx++) {
		 if ($pageidx == $curpage) {
		     print "<font color=red>$pageidx</font>&nbsp; &nbsp; &nbsp  ";
		 }
		 else {
		     print "<a href=$PHP_SELF?page=$pageidx>$pageidx</a>&nbsp; &nbsp; &nbsp  ";
		 }
	       }	 
	       if ($next < $nrows/$rec_per_page+1) {
       	          print "<a href=$PHP_SELF?page=$next>Next</a>&nbsp; &nbsp; &nbsp  ";
	       }	  
	     }  

	 } else {
	     echo "No data found<BR>\n";
	 }	
	 
	 OCIFreeStatement($stmt);
	 OCILogoff($conn);
}
?>
</center>
</body>
</html>






