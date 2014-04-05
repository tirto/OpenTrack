package misclib;

use Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(send_mail guess_os guess_machine open_database trim_spaces);

use DBI;
use CGI qw/:standard :html3/;

# Project: Job Tracking System
# File:    misclib.pl
# By:      Prasanth Kumar
# Date:    Jun 20, 2000

# Description:
# Library of misc subroutines

# ChangeLog:
# 06/20/2000 Prasanth Kumar
# - Add guess_machine() funciton.

# GLOBAL VARIABLES

BEGIN
{
	$ENV{ORACLE_HOME} = "/projects/oracle";
	$ENV{ORACLE_SID} = "rdb1";
}

# SUBROUTINE SECTION

sub send_mail($$$@) {
# Description: a simple e-mail routine which makes use of the sendmail
#   executable.
# Input: to address, from address, mail subject, mail body
# Output: none
    
    my $to_address = shift(@_);
    my $from_address = shift(@_);
    my $mail_subject = shift(@_);
    my @mail_body = @_;

    my $mailprog = '/usr/lib/sendmail';
    open (MAIL, "|$mailprog -t") || die "Can't open $mailprog!\n";

    print MAIL "To: " . $to_address . "\n";
    print MAIL "From: " . $from_address . "\n";
    print MAIL "Subject: " . $mail_subject . "\n\n" ;
    print MAIL @mail_body;

    close (MAIL);

} # send_mail

sub guess_os($) {
# Description: determines the operating system based on an
#   user agent string passed in from a cgi script.
# Input: user agent string
# Output: operating system string

    my $agent_str = shift(@_);

    return 'Win98' if ($agent_str =~/Win.*98/);
    return 'WinNT' if ($agent_str =~/Win.*NT/);
    return 'Win95' if ($agent_str =~/Win.*95/);
    return 'Win3.1' if ($agent_str =~/Win/);
    return 'MacOS' if ($agent_str =~/Mac/);
    return 'Linux' if ($agent_str =~/Linux/);
    return 'Solaris' if ($agent_str =~/Sun/);
    return 'Irix' if ($agent_str =~/IRIX/);
    return 'BSD' if ($agent_str =~/BSD/);
    return 'Unix' if ($agent_str =~/X11/);
    return 'Other';

} # guess_os

sub guess_machine($) {
# Description: determines the machine based on an
#   user agent string passed in from a cgi script.
# Input: user agent string
# Output: machine string

    my $agent_str = shift(@_);

    return 'PC' if ($agent_str =~/Win.*98/);
    return 'PC' if ($agent_str =~/Win.*NT/);
    return 'PC' if ($agent_str =~/Win.*95/);
    return 'PC' if ($agent_str =~/Win/);
    return 'Mac' if ($agent_str =~/Mac/);
    return 'PC' if ($agent_str =~/Linux/);
    return 'Other' if ($agent_str =~/Sun/);
    return 'MIPS' if ($agent_str =~/IRIX/);
    return 'Other' if ($agent_str =~/BSD/);
    return 'Other' if ($agent_str =~/X11/);
    return 'Other';

} # guess_machine

sub open_database($) {
# Description: get database login and password from file and open
#   a database.
# Onput: access file
# Output: handle to database    

    my $access_file = shift(@_);
    
    open(FILE, $access_file) or
	die "no password file $access_file";

    chop($DBlogin = <FILE>);
    chop($DBpassword = <FILE>);
    $dbh = DBI->connect('DBI:Oracle:', $DBlogin, $DBpassword,
			{PrintError=>1, RaiseError=>1}) or
			    die "connecting : $DBI::errstr";

    close(FILE);
    return $dbh;
    
} # open_database

sub trim_spaces($) {
# Description: removed leading and trailing spaces from a string.
#   code obtained from 'perl cookbook'.
# Onput: string scalar or list
# Output: string scalar or list  

    my @out = @_;
    for (@out) {
	s/^\s+//;
	s/\s$//;
    }
    return wantarray ? @out : $out[0];
    
} # trim_spaces

1;
