<?php

######################## START FUNCTIONS #########################

/*
 * 
 * function for update or delete record 
 *
 * @param $conn -- connection object
 *        $sql  -- statement handle
 * @return void
 *
 */

$conn = OCILogon("girish","oracle8i");
$cur_term = '012';

function execute($conn,$sql) {
    $stmt = OCIParse($conn,$sql);
    OCIExecute($stmt);
}

/*
 * function for selecting data from database 
 *
 * @param $conn -- connection object
 *        $sql  -- statement handle
 * @return $nrows, $results
 *
 */
function select($conn,$sql) {
    $stmt = OCIParse($conn,$sql);
    OCIExecute($stmt);
    $nrows = OCIFetchStatement($stmt, $results);
    OCIFreeStatement($stmt);
    return array($nrows, $results);
}

$cs_courses = array ("ENGR261 01" => "ENGR261 - Mobile Obj Programming w/ Java",
		     "ENGR262 01" => "ENGR262 - C/S Overview",
		     "ENGR264 01" => "ENGR264 - C/S Distributed Object Section 1",
                     "ENGR264 03" => "ENGR264 - C/S Distributed Object Section 2",
		     "ENGR266 01" => "ENGR266 - C/S Data Access",
		     "ENGR268 01" => "ENGR268 - C/S Component",
		     "ENGR296H" => "ENGR296H - XML for E-Business",
		     "ENGR295A" => "ENGR295A - Project I",
		     "ENGR295B" => "ENGR295B - Project II"
);

function cs_courses_popup_menu($c) {
	print "<select name=course>\n";
	while (list ($key, $val) = each ($GLOBALS["cs_courses"])) {
		if ($key == $c) {
			print "\t\t\t <option value=\"$key\"selected>$val</option>\n";
		}
		else {
			print "\t\t\t <option value=\"$key\">$val</option>\n";
		}

	}
	print "\t\t    </select>\n";
}

function convertSem($semCode) {
    $temp1 = 'Extension Session';
    switch ($semCode) {
	case '1':
	    $temp1 = 'Winter';
            break;
	case '2':
	    $temp1 = 'Spring';
	    break;
	case '3':
	    $temp1 = 'Summer';
	    break;
	case '4':
	    $temp1 = 'Fall';
    	    break;
        case '5':
	    $temp1 = 'Spring Special Session';
    	    break;
	case '6':
	    $temp1 = 'Fall Special Session';
    	    break;    
    }
    return $temp1;
}
######################## END FUNCTIONS ###################################
?>	

