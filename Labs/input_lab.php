<html>
<head>
<body bgcolor="white" >
<center>
<?php

include ("commonlib.php"); 
?>    
<BR><H2 ALIGN='center'>Lab Usage Add Page</H2><P ALIGN="center">(*) You must fill in this field</P>       
 <!-- display edit entry form -->
        <form method="post" action="insert_newlab.php" onSubmit = "return validate()">
            
           <TABLE ALIGN="center" CELLSPACING="2" BORDER="2" CELLPADDING="2">
              <TR>
                <TH colspan=4 align=center>Lab Info</TH>
              </TR>
              <TR>      
              <TR>
                <TD BGCOLOR="#CCEEFF">Building(*)</TD> 
                <TD>
                  <?php
                     if ($bldg) {
			 building_popup_menu($bldg);
		     }

                     else {
                  ?>			 
		       <select name='building'>
                         <option value='ENG' selected>Engineeering</option>
                         <option value='AVI'>Aviation</option>
                         <option value='IS'>Industrial Studies</option>
                       </select>
	          <?php
		     }
                  ?>  
                </TD> 
                <TD BGCOLOR="#CCEEFF">Room number(*)</TD> 
                <TD><INPUT TYPE="text" NAME="roomnumber"></TD>
              </TR>
              <TR>
                <TD BGCOLOR="#CCEEFF">Lab Name(*)</TD> 
                <TD><INPUT TYPE="text" NAME="name"></TD> 
                <TD BGCOLOR="#CCEEFF">Department(*)</TD>
                <TD>
                  <?php
                        department_selection('');
                  ?>
                </TD>  
                          
              </TR>
           </TABLE>
           <TABLE ALIGN="center" CELLSPACING="2" BORDER="2" CELLPADDING="2">

              <TR>
                <TH colspan=4 align=center BGCOLOR="white">Director Name</TH>
              </TR>
              <TR>        
                <TD BGCOLOR="#CCEEFF">First(*)</TD> 
                <TD><INPUT TYPE="text" NAME="directorfirstname"></TD> 
                <TD BGCOLOR="#CCEEFF">Last(*)</TD> 
                <TD><INPUT TYPE="text" NAME="directorlastname"></TD>     
             </TR>
              <TR>
                <TH colspan=4 align=center BGCOLOR="white">Lab Usage</TH>
             </TR>
             <TR>
                <TD BGCOLOR="#CCEEFF">Internet Access(*)</TD> 
                <TD><INPUT NAME='internetaccess' TYPE=RADIO VALUE='Y' checked>Yes&nbsp;&nbsp;<INPUT NAME='internetaccess' TYPE=RADIO VALUE='N'>No               </TD> 
                <TD BGCOLOR="#CCEEFF">Over Breaks Usage(*)</TD> 
                <TD>
                   <INPUT NAME='usedoverbreaks' TYPE=RADIO VALUE='Y' checked>Yes&nbsp;&nbsp;<INPUT NAME='usedoverbreaks' VALUE='N' TYPE=RADIO>No 
                </TD>         
             </TR>
             
             <TR>
                <TD BGCOLOR="#CCEEFF">Traffic in Spring(*)</TD> 
                <TD>
                   <INPUT NAME='trafficspring' TYPE=RADIO VALUE='Hvy' checked>Heavy&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO  VALUE='Med'>Medium&nbsp;&nbsp;<INPUT NAME='trafficspring' TYPE=RADIO VALUE='Lite'>Lite    
                </TD>
                <TD BGCOLOR="#CCEEFF">Traffic in Fall(*)</TD> 
                <TD>
                    <INPUT NAME='trafficfall' TYPE=RADIO VALUE='Hvy' checked>Heavy&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Med'>Medium&nbsp;&nbsp;<INPUT NAME='trafficfall' TYPE=RADIO VALUE='Lite' >Lite  
                </TD>  
             </TR>
             <TR>
                <TD BGCOLOR="#CCEEFF">Support</TD>
                <TD colspan=1><TEXTAREA NAME="support" ROWS=2 COLS=20 WRAP="virtual"></TEXTAREA></TD>
                <TD BGCOLOR="#CCEEFF">Hrs/week</TD>
                <TD><INPUT TYPE="text" NAME="hrsperweek"></TD>
              </TR>
            </TABLE>
            <TABLE ALIGN="center" CELLSPACING="5" BORDER="0" CELLPADDING="0">
            <TR>
                <TD ALIGN="center"><input type="submit" name="submit" value="Add"></TD>
                <TD ALIGN="center"><INPUT TYPE="reset" value="Reset"></TD>
            </TR>
            </TABLE>
        </form>
        <!-- end edit entry form -->    

</center>
</body>
</html>



