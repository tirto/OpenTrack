<html>
<body bgcolor = "white" alink="blue" vlink="blue">
<?php
    
/*
 * insert_newhard.php
 * for inserting new record into the newhardware table
 *
 * @version 1.0 
 * @date 09-28-00
 * @author Tirto Adji
 */

######################## START FUNCTIONS #########################

// include common function library
include ("commonlib.php");
 
function insert($conn, $b, $r, $s, $c, $cmts,$d) {
    $rowid = OCINewDescriptor($conn,OCI_D_ROWID);
    $stmt = OCIParse($conn, "insert into newhardware values (hardware_ids.nextval,".
		            ":sbuilding,:sroomnumber,:hardware,:quantities,:scomments,:dept)".
		            " returning ROWID into :rid"); 
	OCIBindByName ($stmt, ":sbuilding", &$b, 32);
	OCIBindByName ($stmt, ":sroomnumber", &$r, 32);
	OCIBindByName ($stmt, ":hardware", &$s, 32);
	OCIBindByName ($stmt, ":quantities", &$c, 32);
	OCIBindByName ($stmt, ":scomments", &$cmts, 32);
        OCIBindByName ($stmt, ":dept", &$d, 32);
        OCIBindByName ($stmt,":rid",&$rowid,-1,OCI_B_ROWID);
	$exec_result = OCIExecute($stmt);
	OCIFreeStatement($stmt);
        OCICommit($conn);
    	return ($exec_result);
}

######################## END FUNCTIONS ###################################

if (!$building | !$roomnumber | !$designation | !$quantities |!$department) {
    print "<br><b>Missing input, update failed!</b>";
    print "<br><br><a href=input_hard.php>Back to add hardware</a>";
    return;
}
if (!eregi("^[0-9]{3}\D*$", $roomnumber)) { 
    print "Invalid roomnumber";
    print "<br><br><a href=input_hard.php>Back to add hardware</a>";
    return;
}
if (!ereg("^[0-9]{1,3}$", $quantities)) {
    print "Invalid quantities";
    print "<br><br><a href=input_hard.php>Back to add hardware</a>";
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
    /********* check duplicate hardware entry ***********/
    $check_newhard = "SELECT id, building, roomnumber, designation, quantity from newhardware 
                      where building = '$building' and roomnumber = '$roomnumber' 
                      and designation = '$designation'";
    $rs = select($conn,$check_newhard);
    $nrows = $rs[0];
    $results = $rs[1];
    $idArray = $results["ID"];
    $id = $idArray[0];
    if ($nrows > 0 ) { // hardware exist, so we increment the copies
       /************** increment hardware quantities ***********/
       $results = $rs[1];
       $idArray = $results["ID"];
       $id = $idArray[0];
       $quantitiesArray = $results["QUANTITY"];
       $old_quantities = $quantitiesArray[0];
       print "<BR><BR>Hardware $designation already exist in $building $roomnumber";
       print "<br>Updating quantites";
       print "<br>Old quantities = $old_quantities";
       print "<br>Quantities = $quantities";
       $new_quantities = $old_quantities + $quantities;
       print "<br>New quantities = $new_quantities";
       $update_quantities = "UPDATE newhardware set quantity = '$new_quantities' where id = '$id'";
       execute($conn,$update_quantities);
       echo "<br><br><b>Quantities updated!</b>";
       print "<br><br><a href=input_hard.php?room=$roomnumber&bldg=$building&dept=$department>Add more entry</a>";
       print "<br><br><a href=lab_info.php?room=$roomnumber&bldg=$building&hardware=yes>Back to lab info</a>";		 
    }
    else { // new hardware entry
       /*********** inserting new hardware *******************/
       $ins_dept = convertDept($department);
       $updated_row = insert($conn,$building,$roomnumber,$designation,$quantities,$comments,$department);
       if ($updated_row > 0) {
           print "<table border=0>";
	   print "<tr><th colspan=3>You have entered the following info:</td></tr> ";
           print "<tr><td>Building      </td><td> :  </td><td>$building</td></tr>";
           print "<tr><td>Room no       </td><td> :  </td><td>$roomnumber</td></tr>";
           print "<tr><td>Hardware type </td><td> :  </td><td>$designation</td></tr>";
           print "<tr><td>Quantities    </td><td> :  </td><td>$quantities</td></tr>";
           print "<tr><td>Department    </td><td> :  </td><td>$ins_dept</td></tr>";
           print "<tr><td>Comments      </td><td> :  </td><td>$comments</td></tr>";
           print "</table>";
           print "<br><b>Thank you, new information entered.</b>\n";		 
	   print "<br><br><a href=input_hard.php?room=$roomnumber&bldg=$building&dept=$department>Add more entry</a>";
           print "<br><br><a href=lab_info.php?room=$roomnumber&bldg=$building&hardware=yes>Back to lab info</a>";		 
 
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
