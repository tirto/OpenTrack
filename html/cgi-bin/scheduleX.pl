#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use 5.004;

#GENERAL CONFIGURATION PARAMETERS

BEGIN 

{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

$term = '994';
@weekDays=("M","T","W","R","F","S","U");
@dayNames=("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday");

print header(),
      start_html(-title=>'College Of Engineering Scheduling System',-BGCOLOR=>'white'),
      h1({-align=>center},"College Of Engineering Scheduling System"),
      p({-align=>center},img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"});

print h2({-align=>center},"Term: ",$term);

  # We get the login and password to access the database
  open(FILE,"/home/httpd/.jobDBAccess");
  $DBlogin = <FILE>;
  $DBpassword = <FILE>;
  # Let's get rid of that newline character
  chop $DBlogin;
  chop $DBpassword;

  $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword, {PrintError=>1,RaiseError=>1}) or die "connecting :   $DBI::errsrtr";
  my $page  = param("page");

  $sth = $dbh->prepare(qq{DELETE FROM classmeetingproj});
  $sth->execute or die "executing: $sth->errstr";
  $sth->finish;
  
  $sth1 = $dbh->prepare(qq{SELECT term, department, codenumber, section, counter, count_total, days, starttime, stoptime
                         FROM classmeeting
                         WHERE term = '$term'
                         });
  $sth1->execute or die "Executing: $sth1->errstr";

  $sth2 = $dbh->prepare(qq{INSERT INTO classmeetingproj values(?,?,?,?,?,?,?,?,?,?,?)});

  while (@row = $sth1->fetchrow_array) {
    $sth2->bind_param(1,$row[0]);
    $sth2->bind_param(2,$row[1]);
    $sth2->bind_param(3,$row[2]);
    $sth2->bind_param(4,$row[3]);
    $sth2->bind_param(5,$row[4]);
    $sth2->bind_param(6,$row[5]);
    $sth2->bind_param(7,$row[6]);
    $sth2->bind_param(8,$row[7]);
    $sth2->bind_param(9,$row[8]);
    $sth2->bind_param(10," ");
    $sth2->bind_param(11," ");

    $sth2->execute or die "Executing: $sth2->errstr";
  }

  $sth2->finish;
  $sth1->finish;

  $sth = $dbh->prepare(qq{
	SELECT building, roomNumber, capacity
	FROM room
	WHERE category = 'classroom'
	ORDER BY capacity DESC
	});
  $sth->execute or die "executing: $sth->errstr";

  $roomIndex = 0;
  while (@row = $sth->fetchrow_array) {
    $room[$roomIndex] = $row[0];				#building
    $room[$roomIndex+1] = $row[1];				#roomNumber
    $room[$roomIndex+2] = $row[2];				#capacity
    $room[$roomindex+3] = int($row[2] * 1.05);	#overloaded capacity
    $room[$roomIndex+4] = '';					#string to store array of bits. 5h20 - 24h00 = 224 five-minute slots
    vec($room[$roomIndex+4], 0, 32) = 0;		#therefore we create a 224-entry array of bits
    vec($room[$roomIndex+4], 1, 32) = 0;		#this means 7 entries of 32 bits
    vec($room[$roomIndex+4], 2, 32) = 0;		#we must initialize the array at first
    vec($room[$roomIndex+4], 3, 32) = 0;		#by putting '0' in every slot
    vec($room[$roomIndex+4], 4, 32) = 0;		#which means that the slot is free
    vec($room[$roomIndex+4], 5, 32) = 0;		#when a course occupies the slot
    vec($room[$roomIndex+4], 6, 32) = 0;		#it will take a value of '1'
    $room[$roomIndex+5] = '';					#index+4 = Monday
    vec($room[$roomIndex+5], 0, 32) = 0;		#index+5 = Tuesday
    vec($room[$roomIndex+5], 1, 32) = 0;		#index+6 = Wednesday
    vec($room[$roomIndex+5], 2, 32) = 0;		#index+7 = thuRsday
    vec($room[$roomIndex+5], 3, 32) = 0;		#index+8 = Friday
    vec($room[$roomIndex+5], 4, 32) = 0;		#index+9 = Saturday
    vec($room[$roomIndex+5], 5, 32) = 0;		#index+10 = sUnday
    vec($room[$roomIndex+5], 6, 32) = 0;
    $room[$roomIndex+6] = '';
    vec($room[$roomIndex+6], 0, 32) = 0;
    vec($room[$roomIndex+6], 1, 32) = 0;
    vec($room[$roomIndex+6], 2, 32) = 0;
    vec($room[$roomIndex+6], 3, 32) = 0;
    vec($room[$roomIndex+6], 4, 32) = 0;
    vec($room[$roomIndex+6], 5, 32) = 0;
    vec($room[$roomIndex+6], 6, 32) = 0;
    $room[$roomIndex+7] = '';
    vec($room[$roomIndex+7], 0, 32) = 0;
    vec($room[$roomIndex+7], 1, 32) = 0;
    vec($room[$roomIndex+7], 2, 32) = 0;
    vec($room[$roomIndex+7], 3, 32) = 0;
    vec($room[$roomIndex+7], 4, 32) = 0;
    vec($room[$roomIndex+7], 5, 32) = 0;
    vec($room[$roomIndex+7], 6, 32) = 0;
    $room[$roomIndex+8] = '';
    vec($room[$roomIndex+8], 0, 32) = 0;
    vec($room[$roomIndex+8], 1, 32) = 0;
    vec($room[$roomIndex+8], 2, 32) = 0;
    vec($room[$roomIndex+8], 3, 32) = 0;
    vec($room[$roomIndex+8], 4, 32) = 0;
    vec($room[$roomIndex+8], 5, 32) = 0;
    vec($room[$roomIndex+8], 6, 32) = 0;
    $room[$roomIndex+9] = '';
    vec($room[$roomIndex+9], 0, 32) = 0;
    vec($room[$roomIndex+9], 1, 32) = 0;
    vec($room[$roomIndex+9], 2, 32) = 0;
    vec($room[$roomIndex+9], 3, 32) = 0;
    vec($room[$roomIndex+9], 4, 32) = 0;
    vec($room[$roomIndex+9], 5, 32) = 0;
    vec($room[$roomIndex+9], 6, 32) = 0;
    $room[$roomIndex+10] = '';
    vec($room[$roomIndex+10], 0, 32) = 0;
    vec($room[$roomIndex+10], 1, 32) = 0;
    vec($room[$roomIndex+10], 2, 32) = 0;
    vec($room[$roomIndex+10], 3, 32) = 0;
    vec($room[$roomIndex+10], 4, 32) = 0;
    vec($room[$roomIndex+10], 5, 32) = 0;
    vec($room[$roomIndex+10], 6, 32) = 0;
      
    $roomIndex += 11;
  }
  $sth->finish;

  $sth3 = $dbh->prepare(qq{UPDATE classmeetingproj
		SET building = ?, roomNumber = ?
		WHERE term = ? AND department = ? AND codenumber = ? AND section = ? AND counter = ?});

  $nbRooms = $roomIndex;
  #Each day is considered seperately        
  for ($weekIndex = 0; $weekIndex < 7; $weekIndex++) {
    $sth = $dbh->prepare(qq{
    SELECT co.department, co.codeNumber, co.section, cl.counter, co.maxEnrollment, cl.startTime, cl.stopTime, cl.days, LENGTH(rtrim(cl.days)), cl.building, cl.roomNumber
	FROM course co, classmeetingproj cl
	WHERE co.term = '$term'
	AND co.term = cl.term
	AND co.department = cl.department
	AND co.codenumber = cl.codenumber
	AND co.section = cl.section
	AND cl.days LIKE '%$weekDays[$weekIndex]%'
	AND co.activity <> 'LAB'
	ORDER BY co.maxEnrollment DESC, cl.startTime, LENGTH(cl.days) DESC
	});

    $sth->execute or die "executing: $sth->errstr";

    $meetingIndex = 0;
    while (@row = $sth->fetchrow_array) {
      if ($row[7] !~ /TBA/ and $row[5] !~ /TBA/ and $row[9] =~ /\W/) {
      #If row[9] not empty, the course has already been scheduled
	$meeting[$meetingIndex] = $row[0];			#department
	$meeting[$meetingIndex+1] = $row[1];		#codeNumber
	$meeting[$meetingIndex+2] = $row[2];		#section
	$meeting[$meetingIndex+3] = $row[3];		#counter
	$meeting[$meetingIndex+4] = $row[4];		#maxEnrollment
	$meeting[$meetingIndex+5] = $row[5];		#startTime
	$meeting[$meetingIndex+6] = $row[6];		#stopTime
	$meeting[$meetingIndex+7] = $row[7];		#days concerned
	$meeting[$meetingIndex+8] = $row[8];		#number of days
	$meeting[$meetingIndex+9] = "";				#We initialize the building for the course
	$meeting[$meetingIndex+10] = "";			#We initialize the roomNumber
 	$meetingIndex += 11;						#we set room for cl.building and cl.roomNumber
      }
    }
    $sth->finish;
     
    $nbMeetings = $meetingIndex;
    $conflictIndex = 0;
    for ($meetingIndex = 0; $meetingIndex < $nbMeetings; $meetingIndex+=11) {
      @start = unpack("c4",$meeting[$meetingIndex+5]);
      $hours = 10 * ($start[0] - ord('0')) + $start[1] - ord('0');
      $minutes = 10 * ($start[2] - ord('0')) + $start[3] - ord('0');
      $startIndex = ($hours - 6) * 12 + $minutes / 5;

      @finish = unpack("c4",$meeting[$meetingIndex+6]);
      $hours = 10 * ($finish[0] - ord('0')) + $finish[1] - ord('0');
      $minutes = 10 * ($finish[2] - ord('0')) + $finish[3] - ord('0');
      $stopIndex = ($hours - 6) * 12 + $minutes / 5;
      
      #We check all the rooms to reserve time for the course
      $conflict = 1;
      $allGoodRoomsIndex = 0;
      $goodRoomIndex = -1;
      @allGoodRooms = ();
      $minimumSlots = 224; #The maximum number of slots
      $maximumSlots = 0;
      #This loop checks for rooms available for that course on that day
      for ($roomIndex = 0; $roomIndex < $nbRooms; $roomIndex+=11) {
	$isGoodRoom = 1;

	#We test the room capacity (estimation of a 10% drop after start of classes)
	if ($room[$roomIndex+2] < 0.9 * $meeting[$meetingIndex+4]) {
	  $isGoodRoom = 0;					#Too bad! There is no compression algorithm for students (yet)
	  $roomIndex = $nbRooms;			#We jump out of the $roomIndex loop
	} else {
	  #We check if all slots are free for the period required by the course
	  for ($timeSlotIndex = $startIndex; $timeSlotIndex < $stopIndex; $timeSlotIndex++) {
	    if (vec($room[$roomIndex+4+$weekIndex], $timeSlotIndex, 1) == 1) {
	      $isGoodRoom = 0;				#Too bad! one slot has already been used
	      last;							#We jump out of the $timeSlotIndex loop
	    }
	  }
	}

	if ($isGoodRoom == 1) {
	  $allGoodRooms[$allGoodRoomsIndex++] = $roomIndex; #We wanna keep a trace of all matching rooms
	  $matchingRoomPrevSlots = 0;
	  #We count the number of free slots preceding the course first slot for that room	  
	  for ($prevSlotIndex = $startIndex-1; $prevSlotIndex > 0; $prevSlotIndex--) {
	    if (vec($room[$roomIndex+4+$weekIndex], $prevSlotIndex, 1) == 0) {
	      $matchingRoomPrevSlots++;
	    } else {
	      $prevSlotIndex = 0;			#We jump out of the $prevSlotIndex loop
	    }
	  } #end of $prevSlotIndex loop
	  
	  $allGoodRooms[$allGoodRoomsIndex++] = $matchingRoomPrevSlots;	#We rate the room's convenience
	  if ($matchingRoomPrevSlots < $minimumSlots) {
	    $minimumSlots = $matchingRoomPrevSlots;
	    $goodRoomIndex = $roomIndex;
	  }
	  elsif ($matchingRoomPrevSlots > $maximumSlots) {
	    $maximumSlots = $matchingRoomPrevSlots;
	  }
	  
	  $conflict = 0;					#There is not conflict for that course
	} #fi isGoodRoom
      } #end of $roomIndex loop

      if ($conflict == 0) {
        $moreDays = $meeting[$meetingIndex+8]-1;
	if ($moreDays > 0) {	#There are other days for that course counter
	  $goodRoomIndex = -1;		#We have to try the room for those other days
	  #We create an array of nbRoomsBigEnough, ordered by convenience for the first day
	  @daysRooms = ();
	  $daysRoomsIndex = 0;
	  for ($i = $minimumSlots; $i <= $maximumSlots; $i++) {
	    for ($j = 0; $j < $allGoodRoomsIndex; $j += 2) {
	      if ($allGoodRooms[$j+1] == $i) {
		$daysRooms[$daysRoomsIndex++] = $allGoodRooms[$j];
	      }
	    }
	  }
	  
	  #We create an array of all days spanned by the course
	  $dayIndices[0] = $weekIndex;
	  $dayIndicesCounter = 1;
	  for ($dayIndex = $weekIndex+1; $dayIndex < 7; $dayIndex++) { #We skip the first day, already calculated
	    if ($meeting[$meetingIndex+7] =~ /$weekDays[$dayIndex]/) {
	      #We register the day index
	      $dayIndices[$dayIndicesCounter++] = $dayIndex;
	    }
	  }
	  #We test if a room is free for all the days required by the course
	  for ($allGoodRoomsIndex = 0; $allGoodRoomsIndex < $daysRoomsIndex; $allGoodRoomsIndex++) {
	    $roomScore = 0;
	    $currentRoom = $daysRooms[$allGoodRoomsIndex];
	    for ($i = 1; $i < $dayIndicesCounter; $i++) { #We skip the first day, already calculated
	      #We check if all slots are free for the period required by the course
	      $isGoodRoom = 1;
	      $currentDay = $dayIndices[$i];
	      for ($timeSlotIndex = $startIndex; $timeSlotIndex < $stopIndex; $timeSlotIndex++) {
		if (vec($room[$currentRoom + 4 + $currentDay], $timeSlotIndex, 1) == 1) {
		  $isGoodRoom = 0;				#Too bad! one slot has already been used
		  last;							#We jump out of the $timeSlotIndex loop
		}
	      }
	      if ($isGoodRoom == 1) {
		$roomScore++;
	      }
	    }

	    if ($roomScore == $moreDays) {
	      $goodRoomIndex = $currentRoom;
	      last;
	    }
	  } #end of $allGoodRoomsIndex loop
	  if ($goodRoomIndex != -1) {
	    #Now, we lock the timeSlots alloted to that course
	    for ($i = 0; $i < $dayIndicesCounter; $i++) {
	      for ($timeSlotIndex = $startIndex; $timeSlotIndex < $stopIndex; $timeSlotIndex++) {
		vec($room[$goodRoomIndex+4+$dayIndices[$i]], $timeSlotIndex, 1) = 1;
	      }
	    }
	    $meeting[$meetingIndex+9] = $room[$goodRoomIndex];	#We register the building for the course
	    $meeting[$meetingIndex+10] = $room[$goodRoomIndex+1];	#We register the roomNumber	    

	    $sth3->bind_param(1,$room[$goodRoomIndex]);
	    $sth3->bind_param(2,$room[$goodRoomIndex+1]);
	    $sth3->bind_param(3,$term);
	    $sth3->bind_param(4,$meeting[$meetingIndex]);
	    $sth3->bind_param(5,$meeting[$meetingIndex+1]);
	    $sth3->bind_param(6,$meeting[$meetingIndex+2]);
	    $sth3->bind_param(7,$meeting[$meetingIndex+3]);

	    $sth3->execute or die "Executing: $sth3->errstr";
	  }
	  else {
	    $conflict = 1;
	  }
	  
	} else {	#only one day
	  #Now, we lock the timeSlots alloted to that course
	  for ($timeSlotIndex = $startIndex; $timeSlotIndex < $stopIndex; $timeSlotIndex++) {
	    vec($room[$goodRoomIndex+4+$weekIndex], $timeSlotIndex, 1) = 1;
	  }
	  $meeting[$meetingIndex+9] = $room[$goodRoomIndex];	#We register the building for the course
	  $meeting[$meetingIndex+10] = $room[$goodRoomIndex+1];	#We register the roomNumber

	  $sth3->bind_param(1,$room[$goodRoomIndex]);
	  $sth3->bind_param(2,$room[$goodRoomIndex+1]);
	  $sth3->bind_param(3,$term);
	  $sth3->bind_param(4,$meeting[$meetingIndex]);
	  $sth3->bind_param(5,$meeting[$meetingIndex+1]);
	  $sth3->bind_param(6,$meeting[$meetingIndex+2]);
	  $sth3->bind_param(7,$meeting[$meetingIndex+3]);

	  $sth3->execute or die "Executing: $sth3->errstr";
	} #fi $moreDays > 0
      }

      if ($conflict == 1) { #There is a conflict, no room available
	#We put a "N/A" mention to prevent further allocation of that course
	$sth3->bind_param(1,"NA");
	$sth3->bind_param(2," ");
	$sth3->bind_param(3,$term);
	$sth3->bind_param(4,$meeting[$meetingIndex]);
	$sth3->bind_param(5,$meeting[$meetingIndex+1]);
	$sth3->bind_param(6,$meeting[$meetingIndex+2]);
	$sth3->bind_param(7,$meeting[$meetingIndex+3]);

	$sth3->execute or die "Executing: $sth3->errstr";
      } #fi $conflict
    } #end of $meetingIndex loop

    $sth = $dbh->prepare(qq{
    SELECT co.department, co.codeNumber, co.section, cl.counter, cl.startTime, cl.stopTime, co.maxEnrollment, cl.days
	FROM course co, classmeetingproj cl
	WHERE co.term = '$term'
	AND co.term = cl.term
	AND co.department = cl.department
	AND co.codenumber = cl.codenumber
	AND co.section = cl.section
	AND cl.days LIKE '%$weekDays[$weekIndex]%'
	AND co.activity <> 'LAB'
	AND cl.building = 'NA'
	ORDER BY cl.startTime, co.maxEnrollment DESC
	});
    $sth->execute or die "executing: $sth->errstr";

     
    print h2({-align=>center},$dayNames[$weekIndex]," - Conflicting courses:");
    print "<TABLE ALIGN=CENTER>";
    print Tr({-bgcolor=>"#11EE88"},td("Department"),td("Codenumber"),td("Section"),td("Counter"),td("Starts"),td("Ends"),td("MaxEnrol"), td("Days"));

    while (@row = $sth->fetchrow_array) {
      print Tr(td($row[0]),td($row[1]),td($row[2]),td($row[3]),td($row[4]),td($row[5]),td($row[6]),td($row[7]));
    }

    print "</TABLE>";



    $sth = $dbh->prepare(qq{
    SELECT co.department, co.codeNumber, co.section, cl.counter, co.maxEnrollment, cl.startTime, cl.stopTime, cl.days, cl.building, cl.roomNumber
	FROM course co, classmeetingproj cl
	WHERE co.term = '$term'
	AND co.term = cl.term
	AND co.department = cl.department
	AND co.codenumber = cl.codenumber
	AND co.section = cl.section
	AND cl.days LIKE '%$weekDays[$weekIndex]%'
	AND cl.days <> 'TBA    '
	AND co.activity <> 'LAB'
	ORDER BY cl.startTime, co.maxEnrollment DESC
	});
    $sth->execute or die "executing: $sth->errstr";

    print h2({-align=>center},$dayNames[$weekIndex]," - All courses:");
    print "<TABLE ALIGN=CENTER>";
    print Tr({-bgcolor=>"#9999FF"}, td("Department"), td("Codenumber"), td("Section"), td("Counter"), td("Starts"), td("Ends"), td("MaxEnrol"), td("Days"), td("Building"), td("RoomNb"));

    while (@row = $sth->fetchrow_array) {
      print Tr(td($row[0]),td($row[1]),td($row[2]),td($row[3]),td($row[5]),td($row[6]),td($row[4]),td($row[7]),td($row[8]),td($row[9]));
    }

    print "</TABLE>";

  } #end of weekIndex loop
 
print end_html;
