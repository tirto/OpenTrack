<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue" >
<center>
<?php
    
/*
 * lab_list.php
 * for displaying all the laboratory labs
 *
 * @version 1.0 
 * @date 12-14-00
 * @author Tirto Adji
 */

// include common function library
include ("commonlib.php");

$tablename = 'laboratory';

// display ENGR lab listings
$stmt = OCIParse($conn,"select roomnumber from $tablename where building='ENG' order by roomnumber");
OCIExecute($stmt);
$nrows = OCIFetchStatement($stmt,$results);
if ( $nrows > 0 ) {
     $bldg = 'ENG';
     print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"3\" cellpadding=\"5\">\n";
     print "<BR><H2 ALIGN='center'>COE Lab Listings</H2>";
     print "<TR>";
     print "    <TD align=left colspan=\"5\">Click the Room Number for More Info</TD>";
     print "    <TD align=right colspan=5><a href=input_lab.php?bldg=$bldg>Add New Lab Usage</a></TD>";
     print "</TR>\n";
     print "<TR>\n";
     while ( $column = each( $results ) ) {
	 $data = $column['value'];
	 for ($i = 0; $i < $nrows; $i++) {
	     if ($i%10 == 0) {
		 print "</TR><TR>";
	     }
	     $room = $data[$i];
	     $bgcolor = "antiquewhite";
	     if ($room>99 and $room<200) {
		 $bgcolor = "lightyellow";
	     }
	     else if ($room>199 and $room<300) {
		 $bgcolor = "lightgrey";
	     }
	     else if ($room>299 and $room <400) {
		 $bgcolor = "lightgreen";
	     }
	     print "<TH ALIGN=\"center\" width=50 BGCOLOR=\"$bgcolor\"><a href=lab_info.php?bldg=$bldg&room=$room>$room</TH>\n";
	 }
     }
     print "</TR>\n";
}

print "<TR></TR>";
print "</TABLE>";

// display AVI lab listings
$stmt2 = OCIParse($conn,"select roomnumber from $tablename where building='AVI' order by roomnumber");
OCIExecute($stmt2);
$nrows2 = OCIFetchStatement($stmt2,$results2);
if ( $nrows2 > 0 ) {
     $bldg = 'AVI';
     print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"3\" cellpadding=\"5\">\n";
     print "<BR><H2 ALIGN='center'>Aviation Lab Listings</H2>";
     print "<TR>";
     print "    <TD align=left colspan=\"5\">Click the Room Number for More Info</TD>";
     print "    <TD align=right colspan=5><a href=input_lab.php?bldg=$bldg>Add New Lab Usage</a></TD>";
     print "</TR>\n";
     print "<TR>\n";
     while ( $column2 = each( $results2 ) ) {
	 $data2 = $column2['value'];
	 for ($i2 = 0; $i2 < $nrows2; $i2++) {
	     if ($i2%10 == 0) {
		 print "</TR><TR>";
	     }
	     $room = $data2[$i2];
	     $bgcolor = "antiquewhite";
	     if ($room>99 and $room<200) {
		 $bgcolor = "lightyellow";
	     }
	     else if ($room>199 and $room<300) {
		 $bgcolor = "lightgrey";
	     }
	     else if ($room>299 and $room <400) {
		 $bgcolor = "lightgreen";
	     }
	     print "<TH ALIGN=\"center\" width=50 BGCOLOR=\"$bgcolor\"><a href=lab_info.php?bldg=$bldg&room=$room>$room</TH>\n";
	 }
     }
     print "</TR>\n";
}

print "<TR></TR>";
print "</TABLE>";

// display IS lab listings
$stmt3 = OCIParse($conn,"select roomnumber from $tablename where building='IS' order by roomnumber");
OCIExecute($stmt3);
$nrows3 = OCIFetchStatement($stmt3,$results3);
if ( $nrows3 > 0 ) {
     $bldg = 'IS';
     print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"3\" cellpadding=\"5\">\n";
     print "<BR><H2 ALIGN='center'>Industrial Studies Lab Listings</H2>";
     print "<TR>";
     print "    <TD align=left colspan=\"5\">Click the Room Number for More Info</TD>";
     print "    <TD align=right colspan=5><a href=input_lab.php?bldg=$bldg>Add New Lab Usage</a></TD>";
     print "</TR>\n";
     print "<TR>\n";
     while ( $column3 = each( $results3 ) ) {
	 $data3 = $column3['value'];
	 for ($i3 = 0; $i3 < $nrows3; $i3++) {
	     if ($i3%10 == 0) {
		 print "</TR><TR>";
	     }
	     $room = $data3[$i3];
	     $bgcolor = "antiquewhite";
	     if ($room>99 and $room<200) {
		 $bgcolor = "lightyellow";
	     }
	     else if ($room>199 and $room<300) {
		 $bgcolor = "lightgrey";
	     }
	     else if ($room>299 and $room <400) {
		 $bgcolor = "lightgreen";
	     }
	     print "<TH ALIGN=\"center\" width=50 BGCOLOR=\"$bgcolor\"><a href=lab_info.php?bldg=$bldg&room=$room>$room</TH>\n";
	 }
     }
     print "</TR>\n";
}
print "<TR></TR>";
print "</TABLE>";
print "<TABLE width=500>";
print "<TR><TH colwidth=10> Legends: </TH> ";
print "  <TD colwidth=20 bgcolor='lightyellow'>&nbsp&nbsp&nbsp&nbsp</TD><TD>1st floor</TD>";
print "  <TD colwidth=20 bgcolor='lightgrey'>&nbsp&nbsp&nbsp&nbsp</TD><TD>2nd floor</TD>";
print "  <TD colwidth=20 bgcolor='lightgreen'>&nbsp&nbsp&nbsp&nbsp</TD><TD>3rd floor</TD>";
print "  <TD colwidth=20 bgcolor='antiquewhite'>&nbsp&nbsp&nbsp&nbsp</TD><TD>4th floor</TD>";
print "</TR>";
print "</TABLE>";

?>    
</html>
