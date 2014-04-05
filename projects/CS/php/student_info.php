<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue">
<center>
<?php
    
/*
 * student_info.php
 * for displaying all the laboratory labs
 *
 * @version 1.0 
 * @date 01-16-00
 * @author Tirto Adji
 *
 */

// include common function library
include ("commonlib.php");

    
if ($sid) {
    print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"2\" cellpadding=\"2\">\n";
    print "<BR><H2 ALIGN='center'>Student Course Info</H2>";
    $tablename = 'cs_students';
    $stmt = OCIParse($conn,"select cs_lname, cs_fname, cs_class from $tablename where cs_sid = $sid");
    OCIExecute($stmt);
    OCIFetch($stmt);
    $lname = ociresult($stmt, "CS_LNAME");
    $fname = ociresult($stmt, "CS_FNAME");
    $class = ociresult($stmt, "CS_CLASS")=="CL"?"Classfied":"Conditionally Classfied";
    
    print "<TR><TD colspan=2>$lname, $fname</TD><TD colspan=2>Classification: $class</TD></TR>";	
    
    $tablename = 'cs_courses';
    $stmt = OCIParse($conn,"select cs_term, cs_course, cs_type, cs_grade from $tablename where cs_sid = '$sid' order by cs_term, cs_course");
    OCIExecute($stmt);
    $nrows = OCIFetchStatement($stmt,$results);
    if ( $nrows > 0 ) {
	print "<TR>\n";
	while ( list( $key, $val ) = each( $results ) ) {
	    if ($key == 'CS_TERM') {
		print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">TERM</TH>\n";
	    }
	    elseif ($key == 'CS_COURSE') {
		print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">COURSE</TH>\n";
   	    }
	    elseif ($key == 'CS_TYPE') {
		print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">TYPE</TH>\n";
   	    }
	    elseif ($key == 'CS_GRADE') {
		print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">GRADE</TH>\n";
   	    }
	    else {
		print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">$key</TH>\n";
	    }
	}
        print "</TR>\n";

	for ( $i = 0; $i < $nrows; $i++ ) {
    	    reset($results);
	    print "<TR>\n";
	    while ( $column = each($results) ) {
		$data = $column['value'];
		$colname = $column['key'];
		if ($colname == 'CS_TERM') {
		    $term = $data[$i];
		    $sem = convertSem(substr($term,-1));
		    $year = substr($term,0,2);
       		    print "<TD>$sem $year</TD>\n";
                }
                else {
       		    print "<TD>$data[$i]</TD>\n";
                }
	    }
	        print "</TR>\n";
	}	 
	print "</TABLE>\n";

     } else {
	echo "No data found<BR>\n";
     	print "<br><br><a href=main.php target=_top>Back to Main Page</a>";
     }	
     OCIFreeStatement($stmt);
     OCILogoff($conn);
     return;
}
else {
     print "<br><br><a href=main.php>Back to Main Page</a>";
     print "</TABLE>";
}

print "</BODY>";
print "</HTML>";

?>    

