#! usr/bin/perl

use DBI;

# Project: Classroom Scheduler
# File: course_meets.pl
# By: Phuoc Diec
# Date: August 26, 1999
# Description:
# Retrieve data from data warehouse and populate the locate database.
#
# Change Log:
# 03/20/01 Tirto Adji
# - change term = 014
# 

$term = '014';

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "ware";
}

$dbh = DBI->connect('DBI:Oracle:', 'kindness1/freedom4all@ware', '', {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

$sth1 = $dbh->prepare(qq{SELECT warehouse.wh_course_meets.mtg_term,
                         warehouse.wh_course_meets.mtg_section_id,
                         warehouse.wh_course_meets.mtg_counter,
                         warehouse.wh_course_meets.mtg_count_total,
                         warehouse.wh_course_meets.mtg_days,
                         warehouse.wh_course_meets.mtg_start_time,
                         warehouse.wh_course_meets.mtg_stop_time,
                         warehouse.wh_course_meets.mtg_bldg,
                         warehouse.wh_course_meets.mtg_room
                         FROM warehouse.wh_course_meets
                         WHERE warehouse.wh_course_meets.mtg_term = '$term'
                         AND (warehouse.wh_course_meets.mtg_section_id LIKE '%AE  %'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%CHE %'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%CE  %'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%CMPE%'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%ENGR%'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%EE  %'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%ISE %'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%MATE%'
                         OR warehouse.wh_course_meets.mtg_section_id LIKE '%ME  %'
                         )});
$sth1->execute or die "Executing: $sth1->errstr";

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

$dbh2 = DBI->connect('DBI:Oracle:', 'girish', 'oracle8i', {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";
$sth2 = $dbh2->prepare(qq{INSERT INTO classmeeting values(?,?,?,?,?,?,?,?,?,?,?)});

while (@row = $sth1->fetchrow_array) {
  $course = substr($row[1], 0, 4);
  $course_num = substr($row[1], 4, 4);
  $section = substr($row[1], 8, 3);
  print "$course\n";
  print "$course_num\n";
  print "$section\n";
  
  $sth2->bind_param(1,$row[0]);
  $sth2->bind_param(2,$course);
  $sth2->bind_param(3,$course_num);
  $sth2->bind_param(4,$section);
  $sth2->bind_param(5,$row[2]);
  $sth2->bind_param(6,$row[3]);
  $sth2->bind_param(7,$row[4]);
  $sth2->bind_param(8,$row[5]);
  $sth2->bind_param(9,$row[6]);
  $sth2->bind_param(10,$row[7]);
  $sth2->bind_param(11,$row[8]);

  $sth2->execute or die "Executing: $sth2->errstr";
}

$sth2->finish;
$sth1->finish;

$dbh2->disconnect;
$dbh->disconnect;
