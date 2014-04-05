<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue">
<center>
<?php
    
/*
 * search_php.php
 * for searching student course info database by ssn
 *
 * @version 1.0 
 * @date 01-16-00
 * @author Tirto Adji
 *
 */

// include common function library
include ("commonlib.php");

if ($search) {
    
    if ($ssn!='') {
	$keywords = "%$ssn%";
	$clause = 'cs_sid';
    }
     
     $tablename = "cs_students";

     $stmt = OCIParse($conn,"select cs_sid, cs_lname, cs_fname, cs_class from $tablename where $clause like '$keywords'");
     OCIExecute($stmt);
     $nrows = OCIFetchStatement($stmt,$results);
     if ( $nrows > 0 ) {
        print "<TABLE BORDER=\"0\" align=\"center\" cellspacing=\"2\" cellpadding=\"2\">\n";
        print "<BR><H2 ALIGN='center'>Student Info</H2>";
        print "<TR>";
        print "    <TD align=left colspan=\"5\">Click the Student SSN for Course Info</TD>";
        print "</TR>\n";
        print "<TR>\n";
        while ( list( $key, $val ) = each( $results ) ) {
		 if ($key == 'CS_SID') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">SSN</TH>\n";
		 } 
		 elseif ($key == 'CS_LNAME') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">LAST NAME</TH>\n";
		 }
		 elseif ($key == 'CS_FNAME') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">FIRST NAME</TH>\n";
		 }
		 elseif ($key == 'CS_CLASS') {
		     print "<TH ALIGN=\"center\" BGCOLOR=\"#aaccff\">CLASSFICATION</TH>\n";
		 }
		 else {
		     // do nothing
	         }
	 }
	 print "<TR>\n";
	     $rec_per_page = 15;
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
		     if ($colname == 'CS_EMAIL' || $colname == 'CS_PHONE') {
		     }
		     elseif ($colname == 'CS_SID') {
                         $curpage=$page/$rec_per_page; 
                         $sid = $data[$i];
    		         print "<TD><a href=student_info.php?sid=$sid>$sid</a></td>";
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
                 
                for ($pageidx = 1; $pageidx < $nrows/$rec_per_page +1; $pageidx++) {
		   if ($pageidx == $curpage) {
		     print "<font color=red>$pageidx</font>&nbsp; &nbsp; &nbsp  ";
		   }
		   else {
			 print "<a href=$PHP_SELF?page=$pageidx>$pageidx</a>&nbsp; &nbsp; &nbsp  ";
		   }
		}  
	     }
       	
     } else {
	 echo "No data found<BR>\n"; 
	 print "<br><br><a href=search_ssn.php>Search by SSN Again</a>";
	 print "</TABLE>";
     }
}
else {
?>
    <center>
    <br><br><br><br><br>
    <FORM METHOD="POST"  action="<?php echo $PHP_SELF?>" ENCTYPE="application/x-www-form-urlencoded">
    <table border=0 cellspacing=2>
    <TR>
	<TD ALIGN="right">SSN:</TD>
	<TD><INPUT TYPE="text" NAME="ssn"  VALUE='' SIZE=16 MAXLENGTH=16></TD>
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
