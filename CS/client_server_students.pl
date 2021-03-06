#!/usr/bin/perl

use DBI;

# Project: Client Server Course/Students Info
# File: client_server_students.pl
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

print "\nSelect conditionally classified students from warehouse........";
$sth1 = $dbh->prepare(qq{SELECT  A.bio_sid, A.bio_name
			     FROM warehouse.wh_bio_demo A
				 WHERE A.bio_sid IN (SELECT DISTINCT C.trm_sid
						     FROM warehouse.wh_term C
						     WHERE C.trm_term = '$term'
						       AND (C.trm_major_1 = 'ENGR'
						       OR C.trm_major_1 = 'CMPE'
						       OR C.trm_major_1 = 'CSCI')
						       AND C.trm_career = 'GR'  
						       AND C.trm_degree like '%MS%'
						       AND C.trm_class like '%CL%')});

$sth1->execute or die "Executing: $sth1->errstr";

BEGIN 
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

print "\nConnecting to local db.........";
$dbh2 = DBI->connect('DBI:Oracle:', 'girish', 'oracle8i', {PrintError=>1, RaiseError=>1}) or die "connecting: $DBI::errsrtr";

print "\nDrop index.......";
$sth4 = $dbh2->prepare(qq{DROP INDEX CS_COURSES_IDX});
$sth4->execute or die "Executing: $sth3->errstr";
$sth4->finish;

print "done";

print "\nDeleting rows.......";
$sth3 = $dbh2->prepare(qq{DELETE cs_courses});
$sth3->execute or die "Executing: $sth3->errstr";
$sth3->finish;

$sth4 = $dbh2->prepare(qq{DELETE cs_students});
$sth4->execute or die "Executing: $sth4->errstr";
$sth4->finish;
print "done";

print "\nInsert conditionally classified students to local table........";
$sth2 = $dbh2->prepare(qq{INSERT INTO cs_students values(?,?,?,'CL','','')});

while (@row = $sth1->fetchrow_array) {
 ($last, $first) = split(/,/,$row[1]);
  $sth2->bind_param(1,$row[0]);
  $sth2->bind_param(2,$last);
  $sth2->bind_param(3,$first);
  $sth2->execute or die "Executing: $sth2->errstr";
}

$sth2->finish;
$sth1->finish;

print "done";

print "\nSelect classified students from warehouse........";
$sth1 = $dbh->prepare(qq{SELECT  A.bio_sid, A.bio_name
			     FROM warehouse.wh_bio_demo A
				 WHERE A.bio_sid IN (SELECT DISTINCT C.trm_sid
						     FROM warehouse.wh_term C
						     WHERE C.trm_term = '$term'
						       AND (C.trm_major_1 = 'ENGR'
						       OR C.trm_major_1 = 'CMPE'
						       OR C.trm_major_1 = 'CSCI')
						       AND C.trm_career = 'GR'  
						       AND C.trm_degree like '%MS%'
						       AND C.trm_class like '%CC%')});

$sth1->execute or die "Executing: $sth1->errstr";
print "done";

print "\nInserting classfied students into local table.........";
$sth2 = $dbh2->prepare(qq{INSERT INTO cs_students values(?,?,?,'CC','','')});

while (@row = $sth1->fetchrow_array) {
 ($last, $first) = split(/,/,$row[1]);
  $sth2->bind_param(1,$row[0]);
  $sth2->bind_param(2,$last);
  $sth2->bind_param(3,$first);
  $sth2->execute or die "Executing: $sth2->errstr";
}

$sth2->finish;
$sth1->finish;

print "done";


print "\nReleasing connection....."; 
$dbh2->disconnect;
$dbh->disconnect;
print "done\n";

