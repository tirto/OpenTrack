#! /usr/bin/perl

use DBI;

# Project: Classroom Scheduler
# File: course_meets.pl
# By: Phuoc Diec
# Date: August 26, 1999
# Description:
# Retrieve data from data warehouse and populate the locate database.

$term = '004';

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
  
  $term = $row[2];

  ########### Check if value is empty strings. If not, assign TBA ##########
  
  $days = $row[4];
  $days="TBA" if $days !~ /\w/;
  $start = $row[5];
  $start="TBA" if $start !~ /\w/;
  $stop = $row[6];
  $stop="TBA" if $stop !~ /\w/;
  $building = $row[7];
  $building = "TBA" if $building !~ /\w/;
  $roomnum = $row[8];
  $roomnum = "TBA" if $roomnum !~ /\w/;

  print "col1=$row[0]\n";
  print "col2=$course\n";
  print "col3=$course_num\n";
  print "col4=$section\n";
  print "col5=$row[2]\n";  
  print "col6=$row[3]\n";  
  
  print "col7=$days\n";
  print "col8=$start\n";
  print "col9=$stop\n";
  print "col10=$building\n";
  print "col11=$roomnum\n";  
         
  $sth2->bind_param(1,$row[0]);
  $sth2->bind_param(2,$course);
  $sth2->bind_param(3,$course_num);
  $sth2->bind_param(4,$section);
  $sth2->bind_param(5,$row[2]);
  $sth2->bind_param(6,$row[3]);
  $sth2->bind_param(7,$days);
  $sth2->bind_param(8,$start);
  $sth2->bind_param(9,$stop);
  $sth2->bind_param(10,$building);
  $sth2->bind_param(11,$roomnum);

  $sth2->execute or die "Executing: $sth2->errstr";
}

$sth2->finish;
$sth1->finish;

$dbh2->disconnect;
$dbh->disconnect;







