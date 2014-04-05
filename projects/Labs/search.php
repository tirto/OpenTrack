<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue">
<center>
<?php
    
/*
 * search.php
 * for search lab database
 *
 * @version 1.0 
 * @date 01-16-00
 * @author Tirto Adji
 *
 */

// include common function library
include ("commonlib.php");

if ($search) {
    if ($keywords=='') {
        print "<br><br><br><br><br>";
	print "You must enter a keyword.";
	print "<br><br><a href=search.php>Back to search</a>";
        return;
    }	 	
    if ($tablename=='newsoftware') {
	$field = 'software';
    }
    elseif ($tablename=='newhardware') {
	$field = 'designation';
    }
    else {
        $tablename =='laboratory';
	$field = 'name';
    }
    $field = strtoupper($field);
    $keywords = strtoupper($keywords);
     $stmt = OCIParse($conn,"SELECT *
                               FROM $tablename
				 WHERE upper($field) like '$keywords%'");

     OCIExecute($stmt);
     $nrows = OCIFetchStatement($stmt,$results);
     if ( $nrows > 0 ) {
        print "<TABLE BORDER=\"1\" align=\"center\" cellspacing=\"2\" cellpadding=\"2\">\n";
        print "<BR><H2 ALIGN='center'>Lab Inventory Information</H2>\n";
        if ($tablename == 'newhardware' || $tablename == 'newsoftware') {
	  while ( list( $key, $val ) = each( $results ) ) {
		 if ($key == 'ID') {
		     //do nothing
		 }
		 else {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">$key</TH>\n";
	         }
	     }
	}
	else {
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
       } 

	print "</TR>\n";
	for ( $i = 0; $i < $nrows; $i++ ) {
	    reset($results);
   	    print "<TR>\n";
	    if ($tablename  == 'newsoftware') {
		 while ( $column = each($results) ) {   
		     $data = $column['value'];
		     $colname = $column['key'];
		     if ($colname == 'ID') {
			 $softid = $data[$i];
		     }
		     elseif ($colname == 'ROOMNUMBER') {
                         $roomnumber = $data[$i];
	    	         print "<TD><a href=edit_soft.php?id=$softid>$roomnumber</a></td>";
		     } 
		     elseif ($colname == 'DEPARTMENT') {
			 $deptName = convertDept(trim($data[$i]));
			 print "<TD>$deptName</TD>";
		     }	
		     else {
			 print "<TD>$data[$i]</TD>\n";
	             }		 
		 }
           }
	   elseif ($tablename  == 'newhardware') {
		 while ( $column = each($results) ) {   
		     $data = $column['value'];
		     $colname = $column['key'];
  	             if ($colname == 'ID') {
			 $hardid = $data[$i];
		     }   	 
		     elseif ($colname == 'ROOMNUMBER') {
                         $roomnumber = $data[$i];
    		         print "<TD><a href=edit_hard.php?id=$hardid>$roomnumber</a></td>";
		     }
		     elseif ($colname == 'COMMENTS') {
			 print "<TD>$data[$i]</TD>\n";
		     }
		     elseif ($colname == 'DEPARTMENT') {
			 $deptName = convertDept(trim($data[$i]));
			 print "<TD>$deptName</TD>";
		     }
		     else {
			 print "<TD>$data[$i]</TD>\n";
	             }		 
		 }
           }
	   else {
	       while ( $column = each($results) ) {   
		     $data = $column['value'];
		     $colname = $column['key'];
		     
		     if ($colname == 'ROOMNUMBER') {
                         $roomnumber = $data[$i];
			 print "<TD><a href=edit_lab.php?id=$roomnumber>$roomnumber</a></td>";
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
	   }  
	   print "</TR>\n";
	}
	print "</TABLE>\n";
     } else {
         print "<br><br><br><br><br>";
	 echo "No data found<BR>\n"; 
	 print "<br><br><a href=search.php>Back to search</a>";
	 print "</TABLE>";
     }
}
else {
?>
    <center>
    <br><br><br><br><br>
    <FORM METHOD="POST"  action="<?php echo $PHP_SELF?>" ENCTYPE="application/x-www-form-urlencoded">
    Type in the software/hardware/lab name or keywords to find more info.<br> 
    <table border=0 cellspacing=2>
    <TR>
	<TD ALIGN="right"> Keywords:</TD>
        <TD ALIGN="left"><input name="keywords" length="32" type="text"></TD>
	<TD ALIGN="right"> Search in:</TD>
	<TD>
           <select name="tablename">
             <option value="newsoftware">Software</option>
             <option value="newhardware">Hardware</option>
             <option value="laboratory">Usage</option>
          </select>
	</TD>     
    </TR>
    </table>
    <INPUT TYPE="submit" NAME="search" VALUE="Search">
    </FORM>
    <br>
    <hr width=70%>
    </center>

<?
}    
print "</BODY>";
print "</HTML>";

?> 
