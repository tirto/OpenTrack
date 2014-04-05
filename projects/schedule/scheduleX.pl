#!/usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3 *table *Tr/;
use FindBin qw($Bin);
use lib "$Bin/../Common";
use Misclib;
use 5.004;

BEGIN
{
    $ENV{ORACLE_HOME} = "/projects/oracle";
    $ENV{ORACLE_SID} = "rdb1";
}

sub valid_bldg($);
sub valid_room($);
sub read_schedule(\%$$);
sub print_schedule(\%$$$);
		  
my %schedule;
my ($term,$bldg, $room, $usage);

$term = '014';
		   
print header;
print start_html(-title=>'classroom Utilitization',
		 -bgcolor=>'white'), "\n";
print h3({-align=>'center'}, "SJSU Classroom Utilization Schedule");

# validate building name (or assume it to be 'ENG')
if (param('bldg') and valid_bldg(param('bldg'))) {
    $bldg = param('bldg');
} else {
    $bldg = 'ENG';
}

if (param('room')) {
    $room = param('room');
    if (valid_room(param('room'))) {
	my ($usage, $session) = read_schedule(%schedule, $bldg, $room);
	if ($session > 0) {
	    # print the query form to allow further requests
	    # print_query_form();

	    # print the schedule table from 6 AM to midnight
	    my $title = "Schedule for Room $bldg $room ($usage students, $session sessions)";

	    print_schedule(%schedule, '0600', '2400', $title);
	} else {
	    print_query_form("Room number was not found in the database.");
	}
    } else {
	print_query_form("Room number $room is invalid.");
    }
} else {
    print_query_form();
}

print end_html, "\n";
exit;

sub print_query_form {
# Desc: print a query form to ask for the building
#   and room name and submit back to this script
# Input: optional error message
# Output: none
    print p({-align=>'center'},
	    "Please enter the building and classroom you wish to ",
	    "see the schedule for. (eg. ENG 333)");

    if (@_) {
	print p({-align=>'center'}, font({-color=>'red'}, @_));
    }

    print start_form;
    print table({-align=>'center', -border=>0, -cellspacing=>2},
		Tr(td({-align=>'right'}, "Building:"),
		   td(textfield(-name=>'bldg', -size=>4, -maxlength=>4,
				-default=>'ENG'))),
		Tr(td({-align=>'right'}, "Room Number:"),
		   td(textfield(-name=>'room', -size=>4, -maxlength=>4))),
		Tr(td({-align=>'center', -colspan=>2},
		      submit(-name=>'search', -label=>'Proceed'))));
    print end_form;
}

sub read_schedule(\%$$) {
# Desc: reads the schedule for a building/room and
#   stores it into the schedule_ref array.
# Input: schedule_ref, building name and room name
# Output: room usage by students and number of sessions

    my ($schedule_ref, $bldg, $room) = @_;

    my $dbh = open_database("/home/httpd/.dolphinAccess");

    my $sth = $dbh->prepare(qq{
	SELECT department, codenumber, section, days, starttime,stoptime, 'enrolled',
	'instructor', 'department' 
	    FROM classmeetingproj
	    	WHERE term = $term
		    AND building LIKE ?
		    AND roomnumber LIKE ?});
    
    $sth->bind_param(1, '%' . $bldg . '%');
    $sth->bind_param(2, '%' . $room . '%');
    $sth->execute or die "executing : $DBI::errstr";
 
    my $usage = 0;
    my $session = 0;
    
    # fetch one course entry at a time
    while (@row = $sth->fetchrow_array) {
	my ($department, $codenumber, $section_id, $days, $start_time, $stop_time,
	    $enrolled, $name, $dept) = @row;
	my $start_slot = get_start_slot($start_time);
	my $stop_slot = get_stop_slot($stop_time);
	$section = $department . $codenumber . " " . $section_id;
	# skip courses with undefined schedules
	next if ($days eq 'TBA');
	
	# increment room usage by number of students
	$usage = $usage + $enrolled;
	$session = $session + 1;
	
	# iterate through days for this course
	while ($days =~ /(\S)/go) {
	    # fill in time slots for this course for that day
	    for $i ($start_slot .. $stop_slot) {
		$schedule_ref->{$1}[$i] = [ $section, $enrolled,
					    $name, $dept ];
	    }
	}
    }

    $sth->finish;
    $dbh->disconnect;
    return ($usage, $session);
}

sub print_schedule(\%$$$) {
# Desc: print a schedule in html table foramt spanning
# from start time to stop time.  Schedule data is in 
# a hash(of days) of array(of time slots) structure.
# Input: schedule data, start time and stop time strings.
# Output: none

    my ($schedule_ref, $start_time, $stop_time, $title) = @_;
    my $start_slot = get_start_slot($start_time);
    my $stop_slot = get_stop_slot($stop_time);
    my @header = qw(Time Monday Tuesday Wednesday Thursday Friday Saturday);
    my $days = 'MTWRFS';

    print start_table({-align=>'center', -border=>1, -width=>"95%",
		       -cellspacing=>0, -cellpadding=>2}), "\n";

    print start_Tr,"\n";
    print td({-colspan=>'4'},"Click on the Section ID to Edit/Delete Schedule"),"\n";
    print td({-colspan=>'3', -align=>'right'},
	      a({-href=>"add.pl?bldg=ENG&room=$room"}),
	      "Add Schedule","|",
	      a({-href=>"http://turtle/labs/lab_info.php?bldg=$bldg&room=$room"},
	      "Back to Lab Info"));
    # print title
    print_title_cell($title, $#header + 1);
	
    # print column headers
    print start_Tr;
    foreach $i (@header) {
	print_header_cell($i);
    }
    print end_Tr, "\n";
    
    for $i ($start_slot .. $stop_slot) {
	# print one row at a time
	print start_Tr;
	print_header_cell(get_slot_time($i));
	
	while ($days =~ /(\S)/go) {
	    unless (is_spanned($schedule_ref, $1, $i)) {
		print_data_cell($schedule_ref->{$1}[$i],
				$i, get_span($schedule_ref, $1, $i));
	    }
	}
	print end_Tr, "\n";
    }
    print end_table(), "\n";
    print h5({-align=>'center'},
	     "Note: Some courses have have unknown or overlapping schedules."),"\n";
}

sub get_start_slot($) {
# Desc: converts a 24-hour time string into a 15 minute
# time slot value.  Minutes are rounded downwards to
# make it suitable for use on start times.
# Input: 24-hour time string (in the format HHMM)
# Output: interger tiem slot value

	my $start_time = shift;
	my ($start_hour, $start_min);

	$start_hour = substr($start_time, 0, 2);
	$start_min = substr($start_time, 2, 2);
	
	# group minutes by (0-14) (15-29) (30-44) (45-59)
	return 4 * $start_hour + int($start_min / 15);
}

sub get_stop_slot($) {
# Desc: converts a 24-hour time string into a 15 minute
# time slot value. Minutes are rounded downward to
# make it suitable for use on start times.
# Input: 24-hour time string (in the format HHMM)
# Output: interger time slot value

	my $stop_time = shift;
	my ($stop_hour, $stop_min, $temp_hour, $temp_min);
	
	$stop_hour = substr($stop_time, 0, 2);
	$stop_min = substr($stop_time, 2, 2);

	# shift the minutes by 1 to account for the
	# grouping below
	$temp_min = $stop_min - 1;
	if ($temp_min < 0) {
		$temp_min = $temp_min + 60;
		$temp_hour = $stop_hour - 1;
	} else {
		$temp_hour = $stop_hour;
	}
	
	# group minutes by (1-15) (16-30) (31-45) (46-00)
	return 4 * $temp_hour + int($temp_min / 15);
}

sub get_slot_time($) {
# Desc: converts a 15 minute time slot value into a 24-hour
# time string of the format HH:MM
# Input: interger time slot value
# Output: 24-hour time string

	my $time_slot = shift;
	my ($slot_hour, $slot_min);
	
	$slot_hour = int($time_slot / 4);
	$slot_min = 15 * ($time_slot % 4);
	
	return sprintf("%2.2d:%2.2d", $slot_hour, $slot_min);
}

sub format_course($) {
# Desc: reformat a course description to look 'nicer.'
# Input: course description string
# Output: reformatted course description string

	my $desc = shift;
	
    #don't do anything with blank descriptions
    return undef unless defined $desc;

    my $dept = substr($desc, 0, 4);
    my $number = substr($desc, 4, 4);
    my $section = substr($desc, 8, 3);

    my $course_id = encode_url($desc);	
    return sprintf("<a href=edit.pl?room=$room&bldg=$bldg&section_id=$course_id>$desc</a>");
}

sub get_span(\%$$) {
# Desc: determines the number of consecutive time slots
#    taken by a course starting from a particular time.
#    this is useful for merging consecutive entries when
#    a table is output. Blank (undefined) time slots are
#    not spanned.
# Input: schedule data, day and time slot
# Output: span size
    my ($schedule_ref, $day, $slot) = @_;
    my ($span, $course);

    $span = 1;
    return $span unless defined $schedule_ref->{$day}[$slot];
    $course = $schedule_ref->{$day}[$slot][0];

    $slot++;
    while (defined $schedule_ref->{$day}[$slot] and
	   $schedule_ref->{$day}[$slot][0] eq $course) {
	# consecutive row matched
	$slot++;
	$span++;
    }
    return $span;
}

sub is_spanned(\%$$) {
# Desc: returns true if this time slot is part of the 
#    previous time slot, i.e. the course names matched up.
#    Blank (undefined) time slots are not spanned.
# Input: schedule data, day and time slot
# Output: boolean true if time slot is spanned.

    my ($schedule_ref, $day, $slot) = @_;

    # the first time slot is never spanned
    return 0 if $slot == 0;

    # blank time slots are not spanned
    return 0 unless defined $schedule_ref->{$day}[$slot];

    # check if it previous time slot is scheduled
    return 0 unless defined $schedule_ref->{$day}[$slot-1];

    # check if consecutive time slots matched up
    return ($schedule_ref->{$day}[$slot][0] eq
	    $schedule_ref->{$day}[$slot-1][0] );
}

sub print_data_cell($$$) {
# Desc: outputs a html table data entity with appropriate
#    text and row span for a data cell
# Input: text description and row span
# Output: none

    my ($ref, $row, $span) = @_;

    unless (defined $ref) {
        # unscheduled slots have alternatively shades of gray
        if ($row % 2 == 0) {
	    print td({-bgcolor=>'#b5b5b5', -rowspan=>$span,
		  -width=>'15%'}, '&nbsp;');
	} else
	{   print td({-bgcolor=>'#d5d5d5', -rowspan=>$span,
		  -width=>'15%'}, '&nbsp;');
	}
    } else {

	my ($desc, $tally, $name, $dept) = @$ref;

	$name = "(No Instructor)" if $name eq ' ';
	$tally = $tally . " Enrolled";
	$url = encode_url("edit.pl",
			 bldg=>$bldg,
			 room=>$room,
			 section_id=>$desc);
        # scheduled slots are colored light blue
	print td({-align=>'center', -bgcolor=>'#6788da', -rowspan=>$span,
		  -width=>"15%"}, font({-color=>'white', -size=>3},
				       a({href=>$url},"$desc"), br,
				       $tally, br,
				       $name, br));
    }
}

sub print_header_cell($) {
# Desc: outputs a html table data enity with appropriate
#    text and colors for a table header
# Input: text description
# Output: none

    my $desc = shift;

    # header cells are gold colored
    print td({-align=>'center', -bgcolor=>'gold', -width=>"10%"},
	     font({-size=>3},$desc));
}

sub print_title_cell($) {
# Desc: outputs a html table data entity with appropriate
#    text and colors for a table title
# Input: text description and column span
# Output: none

    my ($desc, $span) = @_;

    # title cells are gold colored
    print Tr(td({-align=>'center', -bgcolor=>'gold', -colspan=>$span},
	     b($desc)));
}

sub valid_bldg($) {
# Desc: returns true if a building name is valid (alpha)
# Input: building name text string
# Output: true if building name is valid

    my $bldg = shift;

    return $bldg =~ /^[A-Za-z]{1,4}$/;
}

sub valid_room($) {
# Desc: returns true if a room number is valid (alphanumeric)
# Input: room number text string
# Output: true if room number is valid

    my $bldg = shift;

    return $bldg =~ /^\w{1,4}$/;
}
