#!/usr/bin/perl

use DBI;

# Project: Client Server Course/Students Info
# File: client_server_course.pl
# By: Tirto Adji	
# Date: Jan 16, 2001
# Description:
# Retrieve data from data warehouse and populate the locate database.

$term = '012';

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "ware";
}

print "\Connecting to warehouse......";
$dbh = DBI->connect('DBI:Oracle:', 'kindness1/freedom4all@ware', '', {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

print "\nSelect registered courses of client/server students from warehouse........";
$sth1 = $dbh->prepare(qq{SELECT  A.cwk_sid,
                                 A.cwk_term,
	                         A.cwk_sp_course,
                                 B.ctf_activity_type,
	                         A.cwk_sp_grade	
                                    FROM warehouse.wh_crswork A, warehouse.wh_course_term B
				       WHERE A.cwk_sid IN (SELECT DISTINCT C.trm_sid
						       FROM warehouse.wh_term C
						          WHERE C.trm_term = '012'
						            AND (C.trm_major_1 = 'ENGR'
							         OR C.trm_major_1 = 'CMPE'
								 OR C.trm_major_1 = 'CSCI')
						            AND C.trm_career = 'GR'  
						            AND C.trm_degree like '%MS%'
						            AND C.trm_class like '%C_%')
				          AND A.cwk_sp_status = 'E'
				          AND A.cwk_term = B.ctf_term
				          AND A.cwk_sp_course = B.ctf_section_id});

$sth1->execute or die "Executing: $sth1->errstr";

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

print "\nConnecting to local db.........";
$dbh2 = DBI->connect('DBI:Oracle:', 'girish', 'oracle8i', {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

print "\nInsert courses to local table........";
$sth2 = $dbh2->prepare(qq{INSERT INTO cs_courses values(?,?,?,?,?)});

while (@row = $sth1->fetchrow_array) {
  $sth2->bind_param(1,$row[0]);
  $sth2->bind_param(2,$row[1]);
  $sth2->bind_param(3,$row[2]);
  $sth2->bind_param(4,$row[3]);
  $sth2->bind_param(5,$row[4]);
  $sth2->execute or die "Executing: $sth2->errstr";
}

$sth2->finish;
$sth1->finish;
print "done";

print "\nCreate index on cs_courses...";
$sth6 = $dbh2->prepare(qq{CREATE INDEX "GIRISH"."CS_COURSES_IDX" ON "GIRISH"."CS_COURSES"("CS_COURSE")});
$sth6->execute or die "Executing: $sth3->errstr";
$sth6->finish;
print "done";

print "\nReleasing connection....."; 

$dbh2->disconnect;
$dbh->disconnect;
print "done\n";

