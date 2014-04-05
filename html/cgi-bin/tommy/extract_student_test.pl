#! usr/bin/perl -w

use DBI;

# Project: Classroom Scheduler
# File: extractdata.pl
# By: Phuoc Diec
# Date: August 26, 1999
# Description:
# Retrieve data from data warehouse and populate the locate database.

my $aTerm = '994';

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "ware";
}

$dbh = DBI->connect('DBI:Oracle:', 'kindness1/b4u4getit@ware', '', {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

# q{ ... } won't interpolate
$sth1 = $dbh->prepare(q{SELECT DISTINCT warehouse.wh_bio_demo.bio_sid,
                         warehouse.wh_bio_demo.bio_name,
			 warehouse.wh_admissions.adm_major,
			 warehouse.wh_crswork.cwk_term,
			 warehouse.wh_crswork.cwk_sp_course,
			 warehouse.wh_crswork.cwk_sp_grade,
			 warehouse.wh_course_term.ctf_section_title
			 
                         FROM warehouse.wh_bio_demo, warehouse.wh_admissions,
				warehouse.wh_crswork, warehouse.wh_course_term
			 WHERE warehouse.wh_bio_demo.bio_sid = '547532221' 
			 AND warehouse.wh_bio_demo.bio_sid = warehouse.wh_admissions.adm_sid
			 AND warehouse.wh_bio_demo.bio_sid = warehouse.wh_crswork.cwk_sid
			 AND warehouse.wh_course_term.ctf_section_id = 
                             warehouse.wh_crswork.cwk_sp_course
			 AND  warehouse.wh_crswork.cwk_sp_grade LIKE '%A %'
                         AND (
			 	    warehouse.wh_admissions.adm_major LIKE '%AE  %'
				 OR warehouse.wh_admissions.adm_major LIKE '%CHE %'
				 OR warehouse.wh_admissions.adm_major LIKE '%CE  %'
				 OR warehouse.wh_admissions.adm_major LIKE '%CMPE%'
				 OR warehouse.wh_admissions.adm_major LIKE '%ENGR%'
				 OR warehouse.wh_admissions.adm_major LIKE '%EE  %'
				 OR warehouse.wh_admissions.adm_major LIKE '%ISE %'
				 OR warehouse.wh_admissions.adm_major LIKE '%MATE%'
				 OR warehouse.wh_admissions.adm_major LIKE '%ME  %'
			)}
 );
$sth1->execute or die "Executing: $sth1->errstr";

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

$dbh2 = DBI->connect('DBI:Oracle:', $login, $password, {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

$sth2 = $dbh2->prepare(qq{INSERT INTO course values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)});

while (@row = $sth1->fetchrow_array) {
  print "$row[0] ";
  print "$row[1] ";
  print "$row[2] ";
  print "$row[3] ";
  print "$row[4] ";
  print "$row[5] ";
  print "$row[6]\n";
  
 # $sth2->bind_param(1,$row[0]);
 # $sth2->bind_param(2,$course);
 # $sth2->bind_param(3,$course_num);
 # $sth2->bind_param(4,$section);
 # $sth2->bind_param(5,$row[5]);
 # $sth2->bind_param(6,$row[4]);
 # $sth2->bind_param(7,$row[3]);
 # $sth2->bind_param(8,$row[9]);
 # $sth2->bind_param(9,$row[8]);
 # $sth2->bind_param(10,$row[7]);
 # $sth2->bind_param(11,$row[6]);
 # $sth2->bind_param(12,$row[2]);
 # $sth2->bind_param(13,$row[14]);
 # $sth2->bind_param(14,$row[11]);
 # $sth2->bind_param(15,$row[12]);
 # $sth2->bind_param(16,$row[13]);
 # $sth2->bind_param(17,$row[10]);

 # $sth2->execute or die "Executing: $sth2->errstr";
}

$sth2->finish;
$sth1->finish;

$dbh->disconnect;
$dbh2->disconnect;
