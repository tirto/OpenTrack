<html>
<body bgcolor = "white" alink="blue" vlink="blue">
<?php

/*
 * insert_newsoft.php
 * for inserting new record into the newsoftware table
 *
 * @version 1.0 
 * @date 09-28-00
 * @author Tirto Adji
 */

######################## END FUNCTIONS ###################################

// include common function library
include ("commonlib.php");
   
function insert($conn,$b, $r, $s, $c, $cmts, $d) {
    $rowid = OCINewDescriptor($conn,OCI_D_ROWID);
    
    $stmt = OCIParse($conn, "insert into newsoftware values (software_ids.nextval,".
		            ":sbuilding,:sroomnumber,:software,:scopies,:scomments,:sdepartment) ".
		            " returning ROWID into :rid"); 
	OCIBindByName ($stmt, ":sbuilding", &$b, 32);
	OCIBindByName ($stmt, ":sroomnumber", &$r, 32);
	OCIBindByName ($stmt, ":software", &$s, 32);
	OCIBindByName ($stmt, ":scopies", &$c, 32);
	OCIBindByName ($stmt, ":scomments", &$cmts, 32);
	OCIBindByName ($stmt, ":sdepartment", &$d, 32);
        OCIBindByName ($stmt,":rid",&$rowid,-1,OCI_B_ROWID);
    
	$exec_result = OCIExecute($stmt);
    
	OCIFreeStatement($stmt);
        OCICommit($conn);
    	return ($exec_result);

}

######################## END FUNCTIONS ###################################

if (!$building | !$roomnumber | !$software | !$copies |!$department) {
    print "<br><b>Missing input, update failed!</b>";
    print "<br><br><a href=input.php>Back to add software</a>";
    return;
}
if (!eregi("^[0-9]{3}\D*$", $roomnumber)) { 
    print "Invalid roomnumber";
    print "<br><br><a href=input.php>Back to add software</a>";
    return;
}
if (!ereg("^[0-9]{1,3}$", $copies)) {
    print "Invalid copies";
    print "<br><br><a href=input.php>Back to add software</a>";
    return;
}

else {
  /****** process form ********/
  $check_room_exist = "SELECT roomnumber from laboratory where roomnumber = '$roomnumber'"; 
  $rs1 = select($conn,$check_room_exist);
  $nrows = $rs1[0];
  if ($nrows == 0 ) { // room does not exist, must add lab usage first
    print "<br>Room does not exist. Please add lab usage first.";
    print "<br><br><a href=input_lab.php>Add new lab usage</a>";
  }
  else {
    $check_newsoft = "SELECT id, building, roomnumber, software, copies from newsoftware 
                      where building = '$building' and roomnumber = '$roomnumber' and department = '$department' 
                      and software = '$software'";
    $rs = select($conn,$check_newsoft);
    $nrows = $rs[0];
    $results = $rs[1];
    $idArray = $results["ID"];
    $id = $idArray[0];
    if ($nrows > 0 ) { // software exist, so we increment the copies
       $results = $rs[1];
       $idArray = $results["ID"];
       $id = $idArray[0];
       $copiesArray = $results["COPIES"];
       $old_copies = $copiesArray[0];
       print "<BR>Software with title of $software already exist in $building $roomnumber";
       print "<br>Updating copies";
       print "<br>Old copies = $old_copies";
       print "<br>Copies = $copies";
       $new_copies = $old_copies + $copies;
       print "<br>New copies = $new_copies";
       $update_copies = "UPDATE newsoftware set copies = '$new_copies' where id = '$id'";
       execute($conn,$update_copies);
       $place_marker=$id;
       echo "<br><br><b>Copies updated!</b>";
       print "<br><br><a href=input.php?room=$roomnumber&bldg=$building&dept=$department>Add more entry</a>";
       print "<br><br><a href=lab_info.php?room=$roomnumber&bldg=$building&software=yes>Back to lab info</a>";		 
	       
    }
    else { // new software entry
       print "<br>Inserting new software"; 
       $updated_row = insert($conn,$building,$roomnumber,$software,$copies,$comments,$department);
       if ($updated_row > 0) {
           $update_dept = convertDept($department);
           print "<table border=0>";
	   print "<tr><th colspan=3>You have entered the following info:</td></tr> ";
           print "<tr><td>Building      </td><td> :  </td><td>$building</td></tr>";
           print "<tr><td>Room no       </td><td> :  </td><td>$roomnumber</td></tr>";
           print "<tr><td>Software title</td><td> :  </td><td>$software</td></tr>";
           print "<tr><td>Copies        </td><td> :  </td><td>$copies</td></tr>";
           print "<tr><td>Department    </td><td> :  </td><td>$update_dept</td></tr>";
           print "<tr><td>Comments      </td><td> :  </td><td>$comments</td></tr>";
           print "</table>";
           print "<br><b>Thank you, new information entered.</b>\n";		 
	   print "<br><br><a href=input.php?room=$roomnumber&bldg=$building&dept=$department>Add more entry</a>";		 
           print "<br><br><a href=lab_info.php?room=$roomnumber&bldg=$building&software=yes>Back to lab info</a>";		 
       }
       else {
	   print "<br>Insert failed";
       }	  
    }
  }
}

?>
</body>
</html>






