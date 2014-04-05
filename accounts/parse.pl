#!/usr/bin/perl -w

use lib '/usr/lib/perl5/site_perl/5.6.0/';
use Date::Manip;

while (chop($line = <>)) {
    $line='Jan 20, 2001' if $line =~/Never/;
    $date = ParseDate($line);
    $start = ParseDate('Apr 21, 2001');
    $diff = DateCalc($date, $start);
    @parts = split /:/, $diff;
    print $parts[2], "\n";
}
