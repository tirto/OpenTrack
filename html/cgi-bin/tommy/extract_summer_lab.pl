#! usr/bin/perl

use DBI;

# Project: Classroom Scheduler
# File: extractdata.pl
# By: Phuoc Diec
# Date: August 26, 1999
# Description:
# Retrieve data from data warehouse and populate the locate database.

$aTerm = '003';

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "ware";
}

$dbh = DBI->connect('DBI:Oracle:', $login, $password, {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

$sth1 = $dbh->prepare(qq{SELECT warehouse.wh_course_term.ctf_term,
                         warehouse.wh_course_term.ctf_section_id,
                         warehouse.wh_course_term.ctf_site,
                         warehouse.wh_course_term.ctf_act_group_code,
                         warehouse.wh_course_term.ctf_activity_type,
                         warehouse.wh_course_term.ctf_section_title,
                         warehouse.wh_course_term.ctf_max_credit,
                         warehouse.wh_course_term.ctf_min_credit,
                         warehouse.wh_course_term.ctf_credit_type,
                         warehouse.wh_course_term.ctf_subtitle,
                         warehouse.wh_course_term.ctf_sched_print,
                         warehouse.wh_course_term.ctf_sched_note_1,
                         warehouse.wh_course_term.ctf_sched_note_2,
                         warehouse.wh_course_term.ctf_sched_note_3,
                         warehouse.wh_course_meets.mtg_days,
                         warehouse.wh_course_meets.mtg_start_time,
                         warehouse.wh_course_meets.mtg_stop_time
                         FROM warehouse.wh_course_term, warehouse.wh_course_meets
                         WHERE warehouse.wh_course_term.ctf_term = '$aTerm'
                         AND warehouse.wh_course_term.ctf_activity_type = 'LAB'
                         AND warehouse.wh_course_term.ctf_section_id = warehouse.wh_course_meets.mtg_section_id
                         AND warehouse.wh_course_meets.mtg_term = warehouse.wh_course_term.ctf_term
                         AND (warehouse.wh_course_term.ctf_section_id LIKE '%AE  %'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '%CHE %'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '%CE  %'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '%CMPE%'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '\%ENGR%'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '\%EE  %'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '%ISE %'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '%MATE%'
                         OR warehouse.wh_course_term.ctf_section_id LIKE '%ME  %'
                         )});
$sth1->execute or die "Executing: $sth1->errstr";

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

$dbh2 = DBI->connect('DBI:Oracle:', 'girish', 'oracle8i', {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

$sth2 = $dbh2->prepare(qq{INSERT INTO course values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)});

open (OUT, ">summer_lab.txt");

while (@row = $sth1->fetchrow_array) {
  $course = substr($row[1], 0, 4);
  $course_num = substr($row[1], 4, 4);
  $section = substr($row[1], 8, 3);
  print OUT "$row[1] $row[5] $row[14] $row[15] $row[16]\n";
  print "$row[2]\n";
  print "$row[3]\n";
  print "$row[5]\n";
 # print "$course\n";
 # print "$course_num\n";
 # print "$section\n";
 # print "$row[4]\n";
  print "$row[14]\n";
  print "$row[15]\n";
  print "$row[16]\n";
  
  $sth2->bind_param(1,$row[0]);
  $sth2->bind_param(2,$course);
  $sth2->bind_param(3,$course_num);
  $sth2->bind_param(4,$section);
  $sth2->bind_param(5,$row[5]);
  $sth2->bind_param(6,$row[4]);
  $sth2->bind_param(7,$row[3]);
  $sth2->bind_param(8,$row[9]);
  $sth2->bind_param(9,$row[8]);
  $sth2->bind_param(10,$row[7]);
  $sth2->bind_param(11,$row[6]);
  $sth2->bind_param(12,$row[2]);
  $sth2->bind_param(13,$row[14]);
  $sth2->bind_param(14,$row[11]);
  $sth2->bind_param(15,$row[12]);
  $sth2->bind_param(16,$row[13]);
  $sth2->bind_param(17,$row[10]);

#  $sth2->execute or die "Executing: $sth2->errstr";
}

$sth2->finish;
$sth1->finish;

$dbh->disconnect;
$dbh2->disconnect;

close (OUT);
