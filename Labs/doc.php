<html>
<META name="Author" content="Tirto Adji">    
<META name="date" content="2001-01-08T10:49:37+00:00">
<body bgcolor="white" alink="blue" vlink="blue">

<center>
<BR><H2 ALIGN='center'>Lab Management Module Documentation</H2>
</center>
<div>
<p>
    <h4>Overview</h4>
    This ECS project started in Fall Semester 2000 under supervision of <a href="http://www.engr.sjsu.edu/ecs/kindness.html">Kindness Israel</a>, ECS Director.
    <br>The purpose of this module is to enable user to manage (query, modify, delete) all the labs usage, software and hardware information in the SJSU's College of Engineering.
    <br>This web-based software module was written entirely with <a href=http://www.php.net target=_top>PHP</a> (PHP: Hypertext Preprocessor). It consists of 15 PHP files as follows:
    <ul>
     <li>Main pages (menu.php and labs.php) serve as the main entry to the application.</li>
     <li>Individual lab info files (lab_info.php and lab_list.php) that give information about specific lab and list available labs. </li>
     <li>A common library (common_lib.php) that has database access information and all the common functions to select, update or delete data from and to the database.</li>
     <li>Input pages (input.php, input_hard.php, input_lab.php) for accepting input data from the user.</li>
     <li>Insert pages (insert_newsoft.php, insert_newhard.php, insert_newlab.php) for inserting new lab information to the database.</li>
     <li>Update pages (edit_soft.php, edit_hard.php, edit_lab.php) for updating existing lab information.</li>
    </ul>    
</p>
<p>
   <h4>Database and Web Server</h4>
   The application uses <a href="http://www.oracle.com/ip/deploy/database/8i">Oracle 8 DBMS</a> and <a href="http://httpd.apache.org">Apache Web Server</a> and is hosted on ecs-staff14 machine.<br/>
   The database tables used in this module are <i>'laboratory'</i> to store laboratory usage information, <i>'newhardware'</i> to store hardware related information, and <i>'newsoftware'</i> to store software related info.<br/>
   <br>The following are the database table information:<br><br>
   
   <table border=1>
     <caption><strong><em>LABORATORY</em></strong></caption>
     <tr><th>Fields</th><th>Nullable?</th><th>Type</th></tr>
     <tr><td>BUILDING</td><td>no</td><td>Varchar2(5)</td></tr>
     <tr><td>ROOMNUMBER</td><td>no</td><td>Varchar2(6)</td></tr>
     <tr><td>NAME</td><td>no</td><td>Varchar(80)</td></tr>
     <tr><td>DEPARTMENT</td><td>no</td><td>NUMBER(2)</td></tr>
     <tr><td>DIRECTORFIRSTNAME</td><td>no</td><td>VARCHAR2(16)</td></tr>
     <tr><td>DIRECTORLASTNAME</td><td>no</td><td>VARCHAR2(16)</td></tr>
     <tr><td>INTERNETACCESS</td><td>no</td><td></td></tr>
     <tr><td>TRAFFICSPRING </td><td>no</td><td>VARCHAR2(6)</td></tr>
     <tr><td>TRAFFICFALL</td><td>no</td><td>VARCHAR2(6)</td></tr>
     <tr><td>USEDOVERBREAKS</td><td>no</td><td>VARCHAR2(1)</td></tr>
     <tr><td>SUPPORTDESCRIPTION</td><td></td><td>VARCHAR2(128)</td></tr>
     <tr><td>SUPPORTHOURSPERWEEK</td><td></td><td>NUMBER(4,1)</td></tr>
     <tr><td></td><td></td><td></td></tr>
   </table>
<br>
   <table border=1>
     <caption><strong><em>NEWHARDWARE</em></strong></caption>
     <tr><th>Fields</th><th>Nullable?</th><th>Type</th></tr>
     <tr><td>ID</td><td>no (PK)</td><td>NUMBER</td></tr>
     <tr><td>BUILDING</td><td>no</td><td>Varchar2(5)</td></tr>
     <tr><td>ROOMNUMBER</td><td>no</td><td>Varchar2(6)</td></tr>
     <tr><td>DESIGNATION</td><td>no</td><td>Varchar(32)</td></tr>
     <tr><td>QUANTITY</td><td>no</td><td>NUMBER(3)</td></tr>
     <tr><td>COMMENTS</td><td></td><td>VARCHAR2(128)</td></tr>
     <tr><td>DEPARTMENT</td><td>no</td><td>NUMBER(2)</td></tr>
     <tr><td></td><td></td><td></td></tr>
   </table>
<br>
   <table border=1>
     <caption><strong><em>NEWSOFTWARE</em></strong></caption>
     <tr><th>Fields</th><th>Nullable?</th><th>Type</th></tr>
     <tr><td>ID</td><td>no (PK)</td><td>NUMBER</td></tr>
     <tr><td>BUILDING</td><td>no</td><td>Varchar2(5)</td></tr>
     <tr><td>ROOMNUMBER</td><td>no</td><td>Varchar2(6)</td></tr>
     <tr><td>SOFTWARE</td><td>no</td><td>Varchar(32)</td></tr>
     <tr><td>COPIES</td><td>no</td><td>NUMBER(3)</td></tr>
     <tr><td>COMMENTS</td><td></td><td>VARCHAR2(255)</td></tr>
     <tr><td>DEPARTMENT</td><td>no</td><td>NUMBER(2)</td></tr>
     <tr><td></td><td></td><td></td></tr>
   </table>
</p>
              
<br>Additional documentation can be found in the source files.
     
    
   
</div>    
