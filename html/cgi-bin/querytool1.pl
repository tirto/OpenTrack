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

#We get the login and password to access the database
open(FILE,"/home/httpd/.ROAccess");
$DBlogin = <FILE>;
$DBpassword = <FILE>;
#Let's get rid of that newline character
chop $DBlogin;
chop $DBpassword;
close(FILE);

print header(),
      start_html(-title=>'College Of Engineering General Request Tool',-BGCOLOR=>'white'),
      h1({-align=>center},"College Of Engineering General Request Tool"),
      p({-align=>center},img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"});


if (param()) {
  if (param('level') eq '1') {
    @selected_tables = param('table_list');
    $table_list_card = @selected_tables;

    for ($i=0; $i < $table_list_card; $i++) {
      print $selected_tables[$i],'<BR>';
    }

  } else {
    print 'Mistake in the code, please restart your query';
  }

} else {

  #getting the list of tables available for the user
  open(QUERY_CONFIG, "/home/httpd/QueryConfigFile") or die "Couldn't open QueryConfigFile: $!\n";
  $line = "";
  do {
    $line = <QUERY_CONFIG>;
    chop $line;
  } until $line =~ /UserTables/;

  $i = 0;
  for ($line = <QUERY_CONFIG>, chop $line; $line !~ /<nomore>/; $line = <QUERY_CONFIG>, chop $line) {
    @row = split(/;/, $line);
    $table_titles[$i] = $row[0];
    $table_labels[$i] = $row[1];
    $i++;  
  }
  $num_tables = $i;


  %label_first = ();
  for ($i=0; $i < $num_tables; $i++) {
    $label_first{$table_titles[$i]} = $table_labels[$i];
  }

  print '<CENTER>';
  print 'Please select the data fields you are interested into','<BR>';

  print start_form;
  print scrolling_list(-name=>'table_list',
                     -values=>\@table_titles,
                     -size=>13,
                     -multiple=>'true',
                     -labels=>\%label_first);
  print hidden('level','1');
  print '<BR>',submit("Next");
  print '</CENTER>';
  print end_form;
}

print end_html;
close(CONFIG_FILE);
