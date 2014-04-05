<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue">
<center>
<?php


/*
 * edit_soft.php
 * for editing or deleting the newsoftware table
 *
 * @version 1.0 
 * @date 09-28-00
 * @author Tirto Adji
 */

include ("commonlib.php");

if ($id) { // id exist
    
    if ($submit) { // update record in the database
	if (!$building | !$roomnumber | !$software | !$copies |!$department) {
	    print "<br><b>Missing input, update failed!</b>";
	    if ($room) {
                print "<br><br><a href=lab_info.php?room=$room&id=$id&software=yes>Back to update page</a>";
	    }
            else {
	        print "<br><br><a href=$PHP_SELF?id=$id&page=$page>Back to update page</a>";	     
            }
	    return;
	}
	
	if (!eregi("^[0-9]{3}[A-Za-z]{0,1}$", $roomnumber)) { 
	    print "<br><b>Invalid roomnumber</b>, roomnumber format must be 123 or 123A";
	    if ($room) {
                print "<br><br><a href=lab_info.php?room=$room&id=$id&software=yes>Back to update page</a>";
	    }
            else {
	        print "<br><br><a href=$PHP_SELF?id=$id&page=$page>Back to update page</a>";	     
            }
	    return;
	}
        if (!ereg("^[0-9]{1,3}$", $copies)) {
            print "<br><b>Invalid copies</b>";
	    if ($room) {
                print "<br><br><a href=lab_info.php?room=$room&id=$id&software=yes>Back to update page</a>";
	    }
            else {
	        print "<br><br><a href=$PHP_SELF?id=$id&page=$page>Back to update page</a>";	     
            }
	    return;
        }
	else {
         	$sth1 = "UPDATE newsoftware SET ID='$id', BUILDING='$building',ROOMNUMBER='$roomnumber', 
	 	         SOFTWARE='$software', COPIES='$copies',COMMENTS='$comments', DEPARTMENT='$department' WHERE ID='$id'";
		execute($conn,$sth1);
                print "<table border=0>";
		print "<tr><th colspan=3>You have entered the following info:</td></tr> ";
                print "<tr><td>Building      </td><td> :  </td><td>$building</td></tr>";
                print "<tr><td>Room no       </td><td> :  </td><td>$roomnumber</td></tr>";
                print "<tr><td>Software title</td><td> :  </td><td>$software</td></tr>";
                print "<tr><td>Copies        </td><td> :  </td><td>$copies</td></tr>";
                print "<tr><td>Comments      </td><td> :  </td><td>$comments</td></tr>";
		$dept = convertDept($department);
                print "<tr><td>Department    </td><td> :  </td><td>$dept</td></tr>";
		print "</table>";
                print "<br><b>Thank you, information updated.</b>\n";		 
		if ($room) {
		    print "<br><br><a href=lab_info.php?bldg=$building&room=$room&page=$page&software=yes>Back to update page</a>";
		}
		else {
		    print "<br><br><a href=$PHP_SELF?page=$page>Back to update page</a>";	     
		}	
        } 
    } elseif ($delete) { // delete record from the database
	$sth2 = "DELETE FROM newsoftware WHERE id=$id";
        execute($conn,$sth2); 
        print "<table border=0>";
	print "<tr><th colspan=3>You have deleted the following info:</td></tr> ";
        print "<tr><td>Building      </td><td> :  </td><td>$building</td></tr>";
        print "<tr><td>Room no       </td><td> :  </td><td>$roomnumber</td></tr>";
        print "<tr><td>Software title</td><td> :  </td><td>$software</td></tr>";
        print "<tr><td>Copies        </td><td> :  </td><td>$copies</td></tr>";
        print "<tr><td>Comments      </td><td> :  </td><td>$comments</td></tr>";
        $dept = convertDept($department);
        print "<tr><td>Department    </td><td> :  </td><td>$dept</td></tr>";
        print "</table>";
        print "<br><b>Delete confirmed.</b>\n";
	if ($room) {
	    print "<br><br><a href=lab_info.php?bldg=$building&room=$roomnumber>Back to lab info</a>";
	}
        else {
	    print "<br><br><a href=$PHP_SELF?page=$page>Back to update page</a>";	     
        }	

    } else { // edit record
	print "<BR><H2 ALIGN='center'>Lab Software Inventory Update Page</H2>";
        print "<P ALIGN=\"center\">(*) You must fill in this field</P>";
        $sth3 = "select * from newsoftware where id = $id";
	$rs = select($conn,$sth3);
	$stmt = OCIParse($conn,"select * from newsoftware where id = $id");
	OCIExecute($stmt);
	OCIFetch($stmt);
	
?>
        <!-- display edit entry form -->
	<form method="post" action="<?php echo $PHP_SELF?>" onSubmit = "return validate()">
	    
           <TABLE ALIGN="center" CELLSPACING="2" BORDER="2" CELLPADDING="5">
	    <!-- pass current page and id info -->
            <input type=hidden name="id" value="<?php echo ociresult($stmt,"ID") ?>">
            <input type=hidden name="page" value="<?php echo $page?>">
	    <input type=hidden name="room" value="<?php echo $room?>"> 
	      <TR>
		<TD BGCOLOR="#CCEEFF">Building(*)</TD> 
		<TD BGCOLOR=white>
		    <?php 
			$bldg = ociresult($stmt,"BUILDING");
	                building_popup_menu($bldg)
		    ?>
		</TD> 
		<TD BGCOLOR="#CCEEFF">Room number(*)</TD> 
		<TD><INPUT TYPE="text" NAME="roomnumber" VALUE="<?php echo ociresult($stmt,"ROOMNUMBER")?>"></TD>
	      </TR>
	      <TR>
                <TD BGCOLOR="#CCEEFF">Software Title(*)</TD> 
                <TD><INPUT TYPE="text" NAME="software" VALUE="<?php echo ociresult($stmt,"SOFTWARE")?>"></TD> 
                <TD BGCOLOR="#CCEEFF">Number of copies(*)</TD> 
                <TD><INPUT TYPE="text" NAME="copies" VALUE="<?php echo ociresult($stmt,"COPIES")?>"></TD>
              </TR>
	      <TR>
	        <TD BGCOLOR="#CCEEFF">Department(*)</TD>
                <TD colspan=3> 
		    <?php 
			$dept = trim(ociresult($stmt,"DEPARTMENT"));
	                department_selection($dept);
		    ?>
		</TD>	
	      </TR>  
	      <TR>
	        <TD BGCOLOR="#CCEEFF">Comments</TD>
		<TD colspan=4><TEXTAREA NAME="comments" ROWS=5 COLS=60 WRAP="virtual"><?php echo ociresult($stmt,"COMMENTS")?></TEXTAREA></TD>
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
         
	 // display software list
         $clause = "order by building,roomnumber"; 
	 if ($room) {
	     $clause =  "where roomnumber = '$room' and building = '$bldg'";
	 }
	 $stmt = OCIParse($conn,"select * from newsoftware $clause");
	 OCIExecute($stmt);
	 $nrows = OCIFetchStatement($stmt,$results);
	 $soft_id = $results["ID"];

	 if ( $nrows > 0 ) {
	     print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"3\" cellpadding=\"5\">\n";
	     print "<BR><H2 ALIGN='center'>COE Lab Software Inventory</H2>";
	     print "<TR><TD align=left colspan=\"3\">Click the Room Number to Update/Delete Entry</a>\n";
	     if ($room) {
		 print "    <TD align=right colspan=3><a href=input.php?bldg=$bldg&room=$room>Add New Lab Software</a></TD></TR>";
	     }
	     else {
		 print "    <TD align=right colspan=3><a href=input.php>Add New Lab Software</a></TD></TR>";
	     }
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
                         $roomnumber = $data[$i];
			 if ($room) {
			     print "<TD><a href=lab_info.php?bldg=$bldg&room=$room&page=$curpage&id=$soft_id[$i]&software=yes>$roomnumber</a></td>";
			 }    
			 else {
			     print "<TD><a href=$PHP_SELF?page=$curpage&id=$soft_id[$i]>$roomnumber</a></td>";
			 }
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
                    if ($room) {
			 print "<a href=lab_info.php?bldg=$bldg&room=$room&page=$prev&software=yes>Prev</a>&nbsp; &nbsp; &nbsp  ";
                     }
		     else {
			 print "<a href=$PHP_SELF?page=$prev>Prev</a>&nbsp; &nbsp; &nbsp  ";
		     }	 
                 } 
                for ($pageidx = 1; $pageidx < $nrows/$rec_per_page +1; $pageidx++) {
		   if ($pageidx == $curpage) {
		     print "<font color=red>$pageidx</font>&nbsp; &nbsp; &nbsp  ";
		   }
		   else {
		     if ($room) {
			 print "<a href=lab_info.php?bldg=$bldg&room=$room&page=$pageidx&software=yes>$pageidx</a>&nbsp; &nbsp; &nbsp  ";
                     }
		     else {
			 print "<a href=$PHP_SELF?page=$pageidx>$pageidx</a>&nbsp; &nbsp; &nbsp  ";
		     } 
		   }
		}
		if ($next < $nrows/$rec_per_page+1) {
                    if ($room) {
			 print "<a href=lab_info.php?bldg=$bldg&room=$room&page=$next&software=yes>Next</a>&nbsp; &nbsp; &nbsp  ";
                     }
		     else {
			 print "<a href=$PHP_SELF?page=$next>Next</a>&nbsp; &nbsp; &nbsp  ";
		     }	 
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






