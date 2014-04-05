<html>
<body bgcolor = "white" alink="blue" vlink="blue">
<?php

/*
 * insert_newlab.php
 * for inserting new record into the laboratory table
 *
 * @version 1.0 
 * @date 11-28-00
 * @author Tirto Adji
 */


######################## START FUNCTIONS #########################

// include common function library
include ("commonlib.php");
 
function insert($conn,$b,$r,$n,$d,$f,$l,$sp,$fa,$i,$u,$sup,$hrs) {
    $rowid = OCINewDescriptor($conn,OCI_D_ROWID);
    $stmt = OCIParse($conn, "insert into laboratory values(".
		            ":building,:roomnumber,:name,:department,:first,:last,:spring,:fall,:internet,:usage,:support,:hrs) ".
		            " returning ROWID into :rid"); 
	OCIBindByName ($stmt, ":building", &$b, 32);
	OCIBindByName ($stmt, ":roomnumber", &$r, 32);
	OCIBindByName ($stmt, ":name", &$n, 32);
	OCIBindByName ($stmt, ":department", &$d, 32);
	OCIBindByName ($stmt, ":first", &$f, 32);
	OCIBindByName ($stmt, ":last", &$l, 32);
	OCIBindByName ($stmt, ":internet", &$i, 32);
	OCIBindByName ($stmt, ":usage", &$u, 32);
	OCIBindByName ($stmt, ":spring", &$sp, 32);
	OCIBindByName ($stmt, ":fall", &$fa, 32);
	OCIBindByName ($stmt, ":support", &$sup, 32);
        OCIBindByName ($stmt, ":hrs", &$hrs, 32);
        OCIBindByName ($stmt,":rid",&$rowid,-1,OCI_B_ROWID);
	$exec_result = OCIExecute($stmt);
	OCIFreeStatement($stmt);
        OCICommit($conn);
    	return ($exec_result);
}

######################## END FUNCTIONS ###################################

$tablename = "laboratory";

if (!$directorlastname | !$roomnumber | !$name | !$support) {
    print "<br><b>Missing input, update failed!</b>";
    print "<br><br><a href=input_lab.php>Back to add page</a>";
    return;
}
if (!eregi("^[0-9]{3}\D*$", $roomnumber)) { 
    print "Invalid roomnumber";
    print "<br><br><a href=input_lab.php>Back to add page</a>";
    return;
}

else {
    /******* check duplicate input *********/
    $check_newhard = "SELECT roomnumber from $tablename 
                      where building = '$building' and roomnumber = '$roomnumber'";
    $rs = select($conn,$check_newhard);
    $nrows = $rs[0];
    $results = $rs[1];
    $roomNoArray = $results["ROOMNUMBER"];
    $roomNo = $roomNoArray[0];
    if ($nrows > 0) {
        print "<br>Duplicate input. Please click on the link below to modify room info....";
        print "<br><br><a href=edit_lab.php?id=$roomNo&bldg=$building>Modify</a>";
    }
    else {
    /****** process form ********/
    // insert new  entry
       print "<br>Inserting new entry"; 
       $updated_row = insert($conn,$building,$roomnumber,$name,$department,$directorfirstname,$directorlastname,$internetaccess,$trafficspring,$trafficfall,$usedoverbreaks,$support,$hrsperweek);
       if ($updated_row > 0) {
           $dept = convertDept($department);    
           print "<table border=0>";
	   print "<tr><th colspan=3>You have entered the following info:</td></tr> ";
           print "<tr><td>Lab name      </td><td> :  </td><td>$name</td></tr>";
           print "<tr><td>Building      </td><td> :  </td><td>$building</td></tr>";
           print "<tr><td>Room no       </td><td> :  </td><td>$roomnumber</td></tr>";
           print "<tr><td>Department    </td><td> :  </td><td>$dept</td></tr>";
           print "<tr><td>Director      </td><td> :  </td><td>$directorfirstname $directorlastname</td></tr>";
           print "<tr><td>Internet      </td><td> :  </td><td>$internetaccess</td></tr>";
           print "<tr><td>Used over breaks </td><td> :  </td><td>$usedoverbreaks</td></tr>";
           print "<tr><td>Traffic spring</td><td> :  </td><td>$trafficspring</td></tr>";
           print "<tr><td>Traffic fall  </td><td> :  </td><td>$trafficfall</td></tr>";
           print "<tr><td>Support       </td><td> :  </td><td>$support</td></tr>";
           print "<tr><td>Hrs/week      </td><td> :  </td><td>$hrsperweek</td></tr>";
           print "</table>";
           print "<br><b>Thank you, new information entered.</b>\n";		 
	   print "<br><br><a href=input_lab.php?bldg=$building>Add more entry</a>";		 
       }
       else {
	   print "<br>Insert failed";
       }	  
    }
}

?>
</body>
</html>






