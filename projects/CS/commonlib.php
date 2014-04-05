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

$buildings = array ("ENG"=>"ENGINEERING",
		    "AVI"=>"AVIATION",
		    "IS"=>"INDUSTRIAL STUDIES");

$departments = array ( "15"=>"Aviation",
		       "6" => "Biometric Research Center",
		       "7"=>"Career Center Liaison",
		       "16" => "Chemical and Materials Engineering",
		       "17"=>"Civil and Environmental Engineering",
		       "1"=>"College of Engineering",
		       "18" => "Computer and Information System Engineering",
		       "19"=>"Electrical Engineering",
		       "8" => "Electronic Materials and Devices",
		       "5"=>"Engineering Computing Systems",
		       "3"=>"Graduate Studies and Research",        
		       "9" => "Hewlett Packard DEI Program Center",
		       "12"=>"MESA Engineering Program Center",
		       "10" => "Manex Center",
		       "20"=>"Mechanical and Aerospace Engineering",
		       "11"=>"Mentornet Center",
		       "13" => "Microprocessor Engineering Center",
		       "14"=>"Process and Quality Improvement Center",
		       "4" => "Support Services",
		       "21"=>"Technologies (Industrial Studies)",
		       "2"=>"Undergraduate Studies"        
);

$cs_courses = array ("ENGR261" => "ENGR261 - Mobile Obj Programming w/ Java",
		     "ENGR262" => "ENGR262 - C/S Overview Object",
		     "ENGR264" => "ENGR264 - C/S Distributed Object",
		     "ENGR266" => "ENGR266 - C/S Data Access",
		     "ENGR268" => "ENGR268 - C/S Component",
		     "ENGR296H" => "ENGR296H - XML for E-Business"
);

function cs_courses_popup_menu($c) {
	print "<select name=course>\n";
	while (list ($key, $val) = each ($GLOBALS["cs_courses"])) {
		if ($key == $c) {
			print "\t\t\t <option value=$key selected>$val</option>\n";
		}
		else {
			print "\t\t\t <option value=$key>$val</option>\n";
		}

	}
	print "\t\t    </select>\n";
}

function building_popup_menu($m) {
	print "<select name=building>\n";
	while (list ($key, $val) = each ($GLOBALS["buildings"])) {
		if ($key == $m) {
			print "\t\t\t <option value=$key selected>$val</option>\n";
		}
		else {
			print "\t\t\t <option value=$key>$val</option>\n";
		}

	}
	print "\t\t    </select>\n";
}

function department_popup_menu($m) {
	print "<select name=department>\n";
	while (list ($key, $val) = each ($GLOBALS["departments"])) {
		if ($key == $m) {
			print "\t\t\t <option value=$key selected>$val</option>\n";
		}
		else {
			print "\t\t\t <option value=$key>$val</option>\n";
		}

	}
	print "\t\t    </select>\n";
}


function convertDept($dept) {
    $temp = '';
    switch($dept) {
	case '15': 
	    $temp = 'AVI';
	    break;
	case '6': 
	    $temp = 'BRC';
	    break;
 	case '7': 
	    $temp = 'CCL';
	    break;
	case '16': 
	    $temp = 'MATE';
	    break;
	case '17': 
	    $temp = 'CE';
	    break;
        case '1':
	    $temp = 'COE';
            break;
	case '18': 
	    $temp = 'CMPE';
	    break;
	case '19': 
	    $temp = 'EE';
	    break;
	case '8': 
	    $temp = 'EMD';
	    break;
	case '5': 
	    $temp = 'ECS';
	    break;
	case '3': 
	    $temp = 'GSR';
	    break;
	case '9': 
	    $temp = 'HP';
	    break;
	case '12': 
	    $temp = 'MESA';
	    break;
	case '10': 
	    $temp = 'MNX';
	    break;
	case '20': 
	    $temp = 'MAE';
	    break;
	case '11': 
	    $temp = 'MTN';
	    break;
	case '13': 
	    $temp = 'MEC';
	    break;
	case '14': 
	    $temp = 'PQI';
	    break;
	case '4': 
	    $temp = 'SS';
	    break;
	case '21': 
	    $temp = 'IS';
	    break;
	case '2': 
	    $temp = 'US';
	    break;
        default:
	    $temp = $dept;
	    
    }
    return $temp;
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

