<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<HTML>
<HEAD><TITLE>Laboratory Inventory Management</TITLE>
<script language='JavaScript'>
<!-- Hide the script from old browser
function validate() {
	if (document.entry.building.value == "") {
		alert('Please enter building');
		document.entry.building.focus();
		return false;
	}

	invalidRegex = /[\'\"]+/gi; 

	if (invalidRegex.test(document.entry.building.value)) {
		alert('Building cannot contain \' or \" character');
		document.entry.building.focus();
		return false;
	}
	if (document.entry.roomnumber.value == "") {
		alert('Please enter roomnumber');
		document.entry.roomnumber.focus();
		return false;
	}
	if (invalidRegex.test(document.entry.roomnumber.value)) {
		alert('Roomnumber cannot contain \' or \" character');
		document.entry.roomnumber.focus();
		return false;
	}
	roomRe = /^[0-9]{3}\D*$/gi;

	if (!roomRe.test(document.entry.roomnumber.value)) {
		alert('Room number has to be either 123 or 123a');
		document.entry.roomnumber.focus();
		return false;
	}
	if (document.entry.software.value == "") {
		alert('Please enter software title');
		document.entry.building.focus();
		return false;
	}
	if (invalidRegex.test(document.entry.software.value)) {
		alert('Software cannot contain \' or \" character');
		document.entry.software.focus();
		return false;
	}
	if (document.entry.copies.value == "") {
		alert('Please enter copies');
		document.entry.copies.focus();
		return false;
	}
	if (invalidRegex.test(document.entry.copies.value)) {
		alert('Copies cannot contain \' or \" character');
		document.entry.copies.focus();
		return false;
	}
	if (invalidRegex.test(document.entry.comments.value)) {
		alert('Comments cannot contain \' or \" character');
		document.entry.comments.focus();
		return false;
	}
}	
// End of the script -->
</script>
</HEAD>
<BODY BGCOLOR="White">
<BR>
<H2 ALIGN="center">Lab Hardware Inventory Add Page</H2>
<?php
    include ("commonlib.php");
?>
<form method="post" name="entry" action="insert_newhard.php" onSubmit="return validate()">
<P ALIGN="center">(*) You must fill in this field</P>
<TABLE ALIGN="center" CELLSPACING="2" BORDER="2" CELLPADDING="5">
  <TR>
    <TD BGCOLOR="#CCEEFF">Building(*)</TD> 
    <TD> 
      <?php
        if ($bldg) {
	  building_popup_menu($bldg);
        }
        else {
      ?>
          <SELECT NAME='building'>
            <OPTION value='ENG'>ENGINEERING</OPTION>
            <OPTION value='AVI'>AVIATION</OPTION>
            <OPTION value='IS'>INDUSTRIAL STUDIES</OPTION>
          </SELECT>
      <?php
	}
      ?>	   
    </TD>
    <TD BGCOLOR="#CCEEFF">Room number(*)</TD> 
    <TD><INPUT TYPE="text" NAME="roomnumber" VALUE="<?php echo $room?>"></TD>
  </TR> 
  <TR>
    <TD BGCOLOR="#CCEEFF">Designation(*)</TD> 
    <TD><INPUT TYPE="text" NAME="designation"></TD> 
    <TD BGCOLOR="#CCEEFF">Quantities(*)</TD> 
    <TD><INPUT TYPE="text" NAME="quantities"></TD>
  </TR> 
  <TR>
    <TD BGCOLOR="#CCEEFF">Department(*)</TD>
    <TD colspan=4>
        
                  <?php
                        department_selection($dept);
                  ?>
        
    </TD>            
  <TR>
  <TR>
    <TD BGCOLOR="#CCEEFF">Comments</TD> 
    <TD colspan=4><TEXTAREA NAME="comments" ROWS=5 COLS=60 WRAP="virtual"></TEXTAREA></TD>
  </TR>
</TABLE>
<TABLE ALIGN="center" CELLSPACING="5" BORDER="0" CELLPADDING="0">
  <TR>
    <TD ALIGN="center"><INPUT TYPE="submit" NAME="submit" VALUE="Add"></TD> 
    <TD ALIGN="center"><INPUT TYPE="reset" VALUE="Reset"></TD>
  </TR>
</TABLE>
</FORM>
</BODY>
</HTML>



