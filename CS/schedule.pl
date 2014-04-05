    #don't do anything with blank descriptions
    return undef unless defined $desc;

    my $dept = substr($desc, 0, 4);
    my $number = substr($desc, 4, 4);
    my $section = substr($desc, 8, 3);

    return sprintf("$dept $number $section");
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
    return $span unless defined $schedule_ref->{$day} [$slot];
    $course = $schedule_ref->{$day}[$slot];

    $slot++;
    while (defined $schedule_ref->{$day}[$slot] and
	   $schedule_ref->{$day}[$slot] eq $course) {
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
    return 0 if $slot = 0;

    # blank time slots are not spanned
    return 0 unless defined $schedule_ref->{$day}[$slot];

    # check if it previous time slot is scheduled
    return 0 unless defined $schedule_ref->{$day}[$slot-1];

    # check if consecutive time slots matched up
    return ($schedule_ref->{$day}[$slot] eq
	    $schedule_ref->{$day}[$slot-1] );
}

sub print_data_cell($$$) {
# Desc: outputs a html table data entity with appropriate
#    text and row span for a data cell
# Input: text description and row span
# Output: none

    my ($desc, $row, $span) = @_;

    unless (defined $desc) {
        # unscheduled slots have alternatively shades of gray
        if ($row % 2 == 0) {
	    print td({-bgcolor=>'#b5b5b5', -rowspan=>$span,
		  -width=>'15%'}, '&nbsp;');
	} else
	{   print td({-bgcolor=>'#d5d5d5', -rowspan=>$span,
		  -width=>'15%'}, '&nbsp;');
	}
    } else {
        # scheduled slots are colored light blue
	print td({-align=>'center', -bgcolor=>'gold', -width=>"10%"}, $desc);
    }
}

sub print_header_cell($) {
# Desc: outputs a html table data entity with appropriate
#    text and row span for a data cell
# Input: text description and row span
# Output: none

    my ($desc, $row, $span) = @_;

    unless (defined $desc) {
        # unscheduled slots have alternatively shades of gray
        if ($row % 2 == 0) {
	    print td({-bgcolor=>'#b5b5b5', -rowspan=>$span,
		  -width=>'15%'}, '&nbsp;');
	} else
	{   print td({-bgcolor=>'#d5d5d5', -rowspan=>$span,
		  -width=>'15%'}, '&nbsp;');
	}
    } else {
        # scheduled slots are colored light blue
	print td({-align=>'center', -bgcolor=>'#6788da', -rowspan=>$span,
		  -width=>"15%"}, $font({-color=>'white'}, $desc);
    }
}

sub print_header_cell($) {
# Desc: outputs a html table data entity with appropriate
#    text and colors for a table header
# Input: text description
# Output: none

    my $desc = shift;

    # header cells are gold colored
    print td({td-align=>'center', -bgcolor=>'gold', -width=>"10%"}, $desc);
}

sub print_title_cell($) {
# Desc: outputs a html table data entity with appropriate
#    text and colors for a table title
# Input: text description and column span
# Output: none

    my ($desc, $span) = @_;

    # title cells are gold colored
    print Tr(td({td-align=>'center', -bgcolor=>'gold', -colspan=>$span},
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
