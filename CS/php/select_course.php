<html>
<head>
<body bgcolor="white" alink="blue" vlink="blue">
<center>
<?php
    
/*
 * select_course.php
 * for listing previous student's course info database for a course
 *
 * @version 1.0 
 * @date 01-16-00
 * @author Tirto Adji
 *
 */

// include common function library
include ("commonlib.php");

if ($search) {
     $stmt = OCIParse($conn,"SELECT B.cs_sid, B.cs_lname, B.cs_fname, B.cs_class
                               FROM cs_students B
				 WHERE B.cs_sid IN (SELECT DISTINCT A.cs_sid
						     FROM cs_courses A
						     WHERE A.cs_term = '$cur_term'
						     AND A.cs_course like '$course%')
                                 ORDER BY cs_lname");

     OCIExecute($stmt);
     $nrows = OCIFetchStatement($stmt,$results);
     if ( $nrows > 0 ) {
        print "<TABLE BORDER=\"1\" align=\"center\" cellspacing=\"2\" cellpadding=\"2\">\n";
        print "<BR><H2 ALIGN='center'>$course Registered Students</H2>\n";
        print "Number of registered student: $nrows<br>";
 
        for ( $i = 0; $i < $nrows; $i++ ) {
	    reset($results);
            while ( $column = each($results) ) {   
                $data = $column['value'];
                $colname = $column['key'];
                if ($colname == 'CS_LNAME') {
                   print "<TR>"; 
                   print "<TD>$data[$i], ";
                }
                elseif ($colname == 'CS_CLASS') {
                   $class = $data[$i]=='CL'?'Y':'N';
                   print "<BR>Classfied? $class</TD>\n";
                         $stmt1 = OCIParse($conn,"SELECT cs_term, cs_course, cs_grade
                                    FROM cs_courses 
				         WHERE cs_sid = $sid
                                             AND (cs_type not like 'LAB%' or cs_course like 'ENGR295%')
                                                ORDER BY cs_term");

                   OCIExecute($stmt1);
                   $nrows1 = OCIFetchStatement($stmt1,$results1);
                   if ($nrows1 > 0) {
                      for ($j = 0; $j < $nrows1; $j++) {
                         reset($results1);
                         while ( $column1 = each($results1)) {
                            $data1 = $column1['value'];
                            $colname1 = $column1['key'];
                            if ($colname1 == 'CS_TERM') {
                                $term = $data1[$j];
		                $sem = convertSem(substr($term,-1));
		                $year = substr($term,0,2);
                                if ($j==0) {
       		                    print "<TD>$sem $year</TD>\n";
                                }
                                else {
       		                    print "<TD>$sem $year</TD>\n";
                               }
                            }
                            elseif ($colname1 == 'CS_COURSE') {
                                print "<TD>$data1[$j]</TD>";
                            }else {
                                print "<TD>$data1[$j]</TD></TR><TR><TD></TD>";
                            }
                         } 
                      }
                   }

                }
                elseif ($colname == 'CS_SID') {
                   $sid = $data[$i];
                }
                else {
                   print "$data[$i]\n";
                }
            }
	}
	print "</TABLE>\n";
        
     } else {
	 echo "No data found<BR>\n"; 
	 print "<br><br><a href=./select_course.php>Select a Course Again</a>";
	 print "</TABLE>";
     }
         OCIFreeStatement($stmt);
	 OCILogoff($conn);
}
else {
?>
    <center>
    <br><br><br><br><br>
    <?php
       $sem = convertSem(substr($cur_term,-1));
       $year = substr($cur_term,0,2);
    ?>
    <h2><?php echo "$sem $year"; ?></h2>  
    <FORM METHOD="POST"  action="<?php echo $PHP_SELF?>" ENCTYPE="application/x-www-form-urlencoded">
    <table border=0 cellspacing=2>
    
        <TD ALIGN="right">Course name:</TD>
	<TD>
            <?php
            	 cs_courses_popup_menu("ENGR261");
	     ?>
	</TD>     
    </TR>
    </table>
    <INPUT TYPE="submit" NAME="search" VALUE="Continue">
    </FORM>
    <br>
    <hr width=70%>
    </center>

<?
}    
print "</BODY>";
print "</HTML>";

?> 
