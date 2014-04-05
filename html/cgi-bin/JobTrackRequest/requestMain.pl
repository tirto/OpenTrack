#! /usr/bin/perl -w

use DBI;
use CGI qw/:standard :html3/;
use misclib;
use infolib;
use 5.004;

# Projects: Job Tracking System
# File:     requestMain.pl
# By:       Prasanth Kumar
# Date:     Jun 22, 2000

# Description:
# Handles user job request form. Depending of which parameters are
# passed in, different portions of the form are printed as noted below.

# Parameters passed in:
#  firstname    blank => print_name_form()
#  lastname     blank => print_name_form()
#  firstname    invalid => print_name_form(invalid)
#  lastname     invalid => print_name_form(invalid)
#  machine_type blank => print_query_form()
#  OS           blank => print_query_form()
#  description  blank => print_query_form(invalid)

# ChangeLog:
# 06/16/2000 Prasanth Kumar
# - cleaned up file formatting
# 06/20/2000 Prasanth Kumar
# - do hashed matches
# - make parts query form noneditible
# - autodetect machine type and OS
# - started using frames

BEGIN
{
  $ENV{ORACLE_HOME} = "/projects/oracle";
  $ENV{ORACLE_SID} = "rdb1";
}

########## DEFINE SOME CONSTANTS ##########
# list of valid machine types
my @MACHINES = ('None', 'PC', 'Mac', 'DEC5000', 'DEC5100', 'HP XTerminal',
		'HP9000', 'RS/6000', 'MIPS', 'IBM Powerstation', 'Other');

# form a hash of machine types for fast matches
my %MACHINES;
for (@MACHINES) { $MACHINES{$_} = 1 }

# list of valid OS types
my @OSYS = ('None', 'Win3.1', 'Win95', 'Win98', 'WinNT', 'MacOS', 'Linux',
	    'Unix', 'AIX', 'Solaris', 'Irix', 'Ultrix', 'BSD', 'HP UX',
	    'Other');

# form a hash of OS types for fast matches
my %OSYS;
for (@OSYS) { $OSYS{$_} = 1 }

# list of valid buildings. The keys are from the name database
# while the values are full names used in the job database
my %BUILDINGS = ('ENG' => 'College of Engineering',
		 'IS' => 'Industrial Studies',
		 'AB' => 'Aviation');

################ PRINT HEADER AND START TO FORMAT HTML #############
print header(-expires=>'now'),
    start_html(-title=>'Job Request System', -bgcolor=>'white');

if (param()) {
    my %valuepairs; # holds validated input parameters
    
    # cleanup and format names for a database search
    my $firstname = trim_spaces( param("firstname"));
    my $lastname = trim_spaces(param("lastname"));
    my $search = $firstname . "_and_" . $lastname; 

    # query the name databse by name and validate
    my ($err, $result) = SearchByName($search); 
    if ($err == 1) {
	print_name_form("First name field is missing.");
    } elsif ($err == 2) {
	print_name_form("Last name field is missing.");
    } elsif ($err == 3) {
	print_name_form("The first and last name fields are missing.");
    } elsif ($err == 4) {
	print_name_form("That name was not found in the database!");
    } else {
	my $ref_ary = $result->[0];
	my $machine_type = param("machine_type");
	my $OS = param("OS");
	my $description = param("description");
	my $validated = 0;

	# extract validated data for this person
	$valuepairs{"firstname"} = $ref_ary->[1];
	$valuepairs{"lastname"} = $ref_ary->[2];
	$valuepairs{"email"} = $ref_ary->[4];
	$valuepairs{"phone"} = substr($ref_ary->[11],2,4);
	$valuepairs{"building"} = $BUILDINGS{$ref_ary->[12]};
	$valuepairs{"room"} = $ref_ary->[13];
	
	# validate OS or reset to a guessed value from client
	if ($OSYS{$OS}) {
	    $validated++;
	} else {
	    $OS = guess_os(user_agent());
	}
	$valuepairs{"OS"} = $OS;

	# validate machine type or reset to default
	if ($MACHINES{$machine_type}) {
	    $validated++;
	} else {
	    $machine_type = guess_machine(user_agent());
	}
	$valuepairs{"machine_type"} = $machine_type;

	# validate length of description
	$valuepairs{"description"} = $description;
	if ($validated == 2) {
	    if ($description eq '') {
		print_query_form(\%valuepairs,
				 "Please fill in the request field.");
	    } elsif ($description =~ /^.{0,500}$/s) {
		update_database(\%valuepairs);
	    } else {
		print_query_form(\%valuepairs,
				 "Please limit the request field to under 500 characters.");
	    }
	} else {
	    print_query_form(\%valuepairs);
	}
    }   
} else {
    print_name_form();
}  

print end_html;

########## END OF MAIN ##########

########## PRINT THE NAME REQUEST FORM ##########
sub print_name_form {
# Description: display a page requesting the name.
# Input: warning message.
# Output: none.

    print h3({-align=>'center'}, "Job Request Login"),
    "This is the COE job request form to be used by the ",
    "faculty and staff of the SJSU College of Engineering. ",
    "Please enter your <B>first and last name</B> so that ",
    "that the system can proceed with your service request. ",
    "If you have trouble locating your name, please search ",
    "the <I>COE Information system</I> in the menu to the ",
    "left or contact <I>Donna Frank-Dunton</I>, the database ",
    "administrator, at x3978 if your name is missing.",
    "<br><br>";

    # Print any error messages if they exist.
    if (@_) {
	print "<center>", font({-color=>'red'}, @_), "</center>";
    }
    
    print start_form;
    print table({-align=>'center', -border=>0, -cellspacing=>5},
		Tr(td({-align=>'right'}, "First name:"),
		   td(textfield(-name=>"firstname", -default=>'',
				-size=>16, -maxlength=>16)),
		   td({-align=>'right'}, "Last name:"),
		   td(textfield(-name=>"lastname", -default=>'',
				-size=>16, -maxlength=>16))),
		Tr(td({-align=>'center', -colspan=>4},
		      submit(-name=>'search', -label=>'Proceed')))); 
    print end_form;

} # print_name_form

########## PRINT THE QUERY FORM ##########
sub print_query_form {
# Description: display the query form.
# Input: validated values and warning message.
# Output: none.

    my %valuepairs = %{shift(@_)};

    print h3({-align=>'center'}, "Job Request Entry"),
    start_form(),
    table({-align=>'center', -cellspacing=>2,
	   -cellpadding=>5, -border=>2},
	  Tr(td({-bgcolor=>'#CCEEFF'},"Requester"),
	     td({-colspan=>3},$valuepairs{"firstname"} . " " . $valuepairs{"lastname"})),
	  Tr(td({-bgcolor=>'#CCEEFF'},"Phone"),
	     td($valuepairs{"phone"}),
	     td({-bgcolor=>'#CCEEFF'},"Email"),
	     td($valuepairs{"email"})),
	  Tr(td({-bgcolor=>'#CCEEFF'},"Building"),
	     td($valuepairs{"building"}),
	     td({-bgcolor=>'#CCEEFF'},"Room Number"),
	     td($valuepairs{"room"}))),
    table({-align=>'center', -cellspacing=>2,
	   -cellpadding=>5, -border=>0},
	  Tr(td({-align=>'right'},"Machine Type:"),
	     td({-align=>'left'},
		popup_menu(-name=>"machine_type",-values=>\@MACHINES,
			   -default=>$valuepairs{"machine_type"})),
	     td({-align=>'right'},"OS:"),
	     td({-align=>'left'},
		popup_menu(-name=>"OS",-values=>\@OSYS,
			   -default=>$valuepairs{"OS"})))),
    table({-align=>'center', -cellspacing=>5,
	   -cellpadding=>0, -border=>0},  
	  Tr(td({-align=>'left'},
		"Describe your request: (Note: mandatory field, less than 500 characters.)")),
	  Tr(td({-align=>'center'},
		textarea(-name=>"description",
			 -rows=>5, -columns=>40,
			 -wrap=>'virtual',
			 -default=>$valuepairs{"description"})))),
    hidden(-name=>'firstname', -value=>$valuepairs{"firstname"}),
    hidden(-name=>'lastname', -value=>$valuepairs{"lastname"});

    # Print any error messages if they exist.
    if (@_) {
	print "<center>", font({-color=>'red'}, @_), "</center>";
    }

    print table({-align=>'center', -cellspacing=>5,
		 -cellpadding=>0, -border=>0},
		Tr(td({-align=>'center'},submit("Submit")),
		   td({-align=>'center'},reset("Reset")))),
    end_form;
    
} # End print_query_form

########## UPDATE THE DATABASE ##########
sub update_database {
# Description: update the database with form input
# Input: validated values and warning message.
# Output: none.

    my %valuepairs = %{shift(@_)};
    
    my $dbh = open_database("/home/httpd/.jobDBAccess");
    my $sth = $dbh->prepare(qq{insert into jobRequest values
				   (sysdate,?,?,?,?,?,?,?,?)});

    $name = $valuepairs{"firstname"} . " " . $valuepairs{"lastname"};
    $sth->bind_param(1,$name);
    $sth->bind_param(2,$valuepairs{"room"});
    $sth->bind_param(3,$valuepairs{"phone"});
    $sth->bind_param(4,$valuepairs{"email"});
    $sth->bind_param(5,$valuepairs{"machine_type"});
    $sth->bind_param(6,$valuepairs{"OS"});
    $sth->bind_param(7,$valuepairs{"building"});
    $sth->bind_param(8,$valuepairs{"description"});
    my $rv = $sth->execute or die "executing:  $sth->errstr";
    $sth->finish;
    
    my $rc = $dbh->commit || die $dbh->errstr;
    
    # The DB has been updated, we can warn the right person
    # that a new request must be processed.
    $recipient = 'kindness@email.sjsu.edu';
    $subject = "New Request from : " . $name;
    $postinput = "Request author : " . $name . "\n";
    if ($valuepairs{"email"}) {
	$postinput .= "Email : " . $valuepairs{"email"} . "\n";
    }
    if ($valuepairs{"phone"}) {
	$postinput .= "Phone : (408) 924-" . $valuepairs{"phone"} . "\n";
    }
    $postinput .= "Building : " . $valuepairs{"building"} . "\tRoom : " . $valuepairs{"room"} . "\nDescription of Problem : " . $valuepairs{"description"};

    send_mail($recipient,"ECS Job Tracking", $subject, $postinput);

    # If the user gave an e-mail address, we confirm
    # the processing of the request.
    unless ($valuepairs{"email"} eq "None") {

	# Get ID number form the database by getting the data and time the
	# request was received.
	$sth = $dbh->prepare(qq{SELECT
				    TO_CHAR(datereceived, 'MMDDYYYYHH24MISS')
					FROM jobrequest
					    WHERE jobdescription = '$valuepairs{"description"}'});
	$sth->execute or die "execute: $sth->errstr";
	@id = $sth->fetchrow_array;
	$sth->finish;
	$recipient = $valuepairs{"email"};
	$subject = "Your request has been registered";
	$content = "This mail is a confirmation that we have received your request and will process it as soon as possible.\n\nID number of your request is $id[0].This ID is generated based on the date and time your request arrived to our system.\n\nYou may check below that the data you entered are correct.\n\n";
	$content .= $postinput . "\nMachine Type : " . $valuepairs{"machine_type"} ."\tOperating System : " . $valuepairs{"OS"};

	send_mail($recipient,"ECS Job Tracking", $subject, $postinput);
    }
    
    # Then we can display the confirmation screen
    print h3({-align=>'center'}, "Job Request Confirmation"),
    "Your request has been accepted and will be processed ",
    "as soon as possible. You will receive a confirmation ",
    "email in a short while. Please make another choice ",
    "from the menu to the left.";

} # End update_database
