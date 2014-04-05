#!/usr/bin/perl

require 5.004;
use strict;
#use common;

use CGI;
#use CGI::Carp qw/fatalsToBrowser/;
use CGI qw/:standard :html3/;
use DBI;

BEGIN

{
        $ENV{ORACLE_HOME} = "/projects/oracle";
        $ENV{ORACLE_SID} = "rdb2";
}

my $query = new CGI;
#my $dbh   = common::getDBH();
my $oracleUsername = "insider";
my $oraclePassword = "master";
my $dbh = DBI->connect('DBI:Oracle:', $oracleUsername, $oraclePassword, {RaiseError=>1});

{

	if ($query->request_method eq 'GET')
	{
		&doGet();
	}
	else
	{
		&doPost();
	}
}

sub doGet
{
	#Validating request:
	#-------------------
	# 1. If svyId == NEW then create a new survey
	# 2. else must have a svyId to display information for.

		showAssess();
}

sub doPost
{
	&showRpt();
}

sub showAssess
{
	#Display Assessment information

	print $query->header;

	print "<SCRIPT>\n";
	print "function winOpen( Target ) {msg=window.open(Target, 'DisplayWindow','toolbar=yes,width=640,height=480,directories=no,status=no,scrollbars=yes,resizable=yes,menubar=no,location=no');} </SCRIPT>\n";

	print $query->start_html('Assessment');

	&displayAssessment();

	print $query->end_html;
}

#Display the Survey specific section of this page

sub showRpt
{
	my(@name, $nm, $val);
	my(@name_key, $name_value);
	my(%sub_list);
	my($userfile, $adminfile, $td);
	my($correct_ans, $wrong_ans);
	my($sql, $case, $nmCrsr, $wrong_ans, $correct_ans, $printquest);
	my($ansText, $ansId, $ansVal, $qstText, $qstRef, $qstAns, $qstCat, $qstTot);
	my($wrong_cnt, $correct_cnt);
	my($query_val, $line, $ret_val, $ansFmt);

	$td = time();
	$userfile = "data/user_file_$td";
	$adminfile = "data/admin_file";

	open(uFile, ">$userfile");	# Open for output
	open(aFile, ">>$adminfile");	# Open for appending

	print $query->header;
	print $query->start_html('ASSESSMENT AND SOLUTIONS');

	print "<BODY BACKGROUND='/rdb2/img/lightgrey.gif'><center><b><font size=+1>ASSESSMENT RESULTS AND SOLUTIONS</font></b></center>";
	
	@name = $query->param;

	$name_value = $query->param('all_name');

	@name_key = split(/,/, $name_value);

	$wrong_cnt = 0;
	$correct_cnt = 0;
	$qstTot = 1;
	foreach $nm (@name_key) {
		$name_value = substr($nm, 0, 4);
		$val = $query->param($nm);

		$case = 0;

		if (substr($nm, 0, 4) eq 'txt_')
		{
			$nm =~ s/txt_//;
		}
			$sql = qq/select ans_text, ans_id, ans_val, ans_fmt, qst_text, qst_ref, qst_ans, qst_cat from question, answer where qst_id = $nm and ans_qst_id = qst_id and ans_val is not null/;
			#$sql = qq/select ans_text, ans_id, ans_val, qst_text, qst_ref, qst_ans from question, answer where qst_id = $nm and qst_ans = ans_id/;

		$nmCrsr = $dbh->prepare($sql);

		$nmCrsr->bind_columns(undef, \($ansText, $ansId, $ansVal, $ansFmt, $qstText, $qstRef, $qstAns, $qstCat));

		$nmCrsr->execute;

		$wrong_ans = '';
		$correct_ans = '';
		$printquest = 1;
		while($nmCrsr->fetch)
		{
			if ($printquest)
			{
				$printquest = 0;
				print uFile "<p><b><font size=+0>$qstTot. $qstText</font></b>\n";
				++$qstTot;
			}
			if ($ansVal eq '1')
			{
				$correct_ans = $ansText;
				$query_val = $query->param($nm);
				if ($ansId ne $query_val)
				{
					if($query_val eq '')
					{
						$wrong_ans = " ";
					}
					else
					{
						$wrong_ans = &getWrongAns($query_val);
						#$wrong_ans = "wrong";
					}
					
				}
			}
			else
			{
				$correct_ans .= $ansText . ' ';
				$correct_ans =~ s/_____/$ansVal/g;
				$query_val = $query->param("txt_$ansId");
				$ret_val = checkval($ansVal, $query_val, $ansFmt);
				if (!$ret_val)
				{
					$wrong_ans .= $ansText . ' ';
					$wrong_ans =~ s/_____/$query_val/g;
				}
			}
		}


		if ($wrong_ans ne '')
		{
			print uFile "<br><font size=+0><b>&nbsp;&nbsp;&nbsp; </b>Your answer was </font><font color='#FF0000'><font size=+1>wrong</font></font>\n";
			$wrong_cnt++;
		}
		else
		{
			print uFile "<br><font size=+0><b>&nbsp;&nbsp;&nbsp; </b>Your answer was </font><font color='#3333FF'><font size=+1>right</font></font>";
			$correct_cnt++;
		}

		print uFile "<br><font size=+0><b>&nbsp;&nbsp;&nbsp; </b>The correct answer is: $correct_ans</font>\n";

		
		if ($wrong_ans ne '')
		{
			print uFile "<br><font size=+0><b>&nbsp;&nbsp;&nbsp; </b>Your answer was: $wrong_ans</font>\n";
			print uFile "<br><font size=+0><font color='#FF0000'>&nbsp;&nbsp;&nbsp; </font><i><font color='#000000'>Please review Chapter $qstRef in your text book.</font></i></font>\n";
		}

		$nmCrsr->finish;
	}

	my $fname = $query->param("first_name");
	my $lname = $query->param("last_name");
	my $ssn = $query->param("ssn");
	
	my $tot_qst = $wrong_cnt + $correct_cnt;

	my $perc = ($correct_cnt/$tot_qst) * 100;

	my ($sec, $min, $hour, $mday, $mon, $year, $wday, $ydat, $iddst) = localtime();
	$mon = $mon + 1;
	my $date_str = "$mon/$mday/$year $hour:$min";

	print aFile "<br><b>Student Name</b>: &nbsp; $lname, $fname &nbsp; <b>SSN</b>: $ssn &nbsp; <b>Date</b>: $date_str &nbsp <b>Score</b>:", int($perc), "\n";

	close(uFile);
	close(aFile);

	print "<p><font size=+1>&nbsp;&nbsp;&nbsp; Student Name:&nbsp; </font><font size=+0>$lname, $fname</font>\n";
	print "<br><font size=+1>&nbsp;&nbsp;&nbsp; Student ID:&nbsp; </font><font size=+0>$ssn</font>\n";
	#print "<br><font size=+1>&nbsp;&nbsp;&nbsp; Date:&nbsp; </font><font size=+0>$date_str</font><br>\n";


	print "<br><br><center><table BORDER COLS=2 WIDTH='95%' ><tr><td><b>Total Questions</b>: $tot_qst</td>\n";
	print "<td><b>Total correct answers:</b> $correct_cnt</td></tr>\n";

	print "<tr><td><b>Total wrong answers:</b> $wrong_cnt</td>\n";

	#print "<td><b>Score</b>: ", $correct_ans/($correct_ans+$wrong_ans)*100, " %</td></tr></table></center>\n";
	print "<td><b>Score</b>: ", int($perc),  " %</td></tr></table></center>\n";

	print "<br><b>This report has been designed to provide you with feedback to improve your learning. The table at the beginning tells you the total number of correct and wrong answers. The correct answer for each question is then provided. If your answer for a paricular question was wrong, the relevant section of your textbook that you should review is also rpovided to assist you.</b><br>";
	
	open(tFile, "$userfile");	# Open for read
	
	while($line = <tFile>)
	{
		print $line;
	}
	
	print "</body>";
	print $query->end_html;



}

sub getWrongAns
{
	my ($ansId) = @_;
	my ($sql, $ansCrsr, $ansText);

	$sql = qq/select ans_text from answer where ans_id = $ansId/;

	$ansCrsr = $dbh->prepare($sql);

	$ansCrsr->bind_columns(undef, \($ansText));

	$ansCrsr->execute;

	$ansCrsr->fetchrow;

	return $ansText;
}
	


sub displayAssessment
{
	my($svyTitle, $sql, $dbCrsr, $svyGrpId, $svyTotCnt, $svyStatus);
	my($qstId, $qstText, $qstOrd, $qstCnt, $qstTot, $qstSelCnt);
	my($qstCat, $dbCrsr1, $qstText, $qstDisp);
	my($qstAns, $dbCrsr2, $ansText);
	my($ansId, $ansType, $all_name);
	my($ansStr);
	my @qst_arr;

	#retreive all Survey info from db.

	print "<BODY BACKGROUND='/rdb2/img/lightgrey.gif'><center><b><font size=+1>Materials Engineering 025 Assement</font></b></center>";

	#print $query->start_form;
	print "<script language='JavaScript'>";
	print "var mesg = 'This will terminate your assessment, Continue?'";
	print "</script>";
	print "<FORM METHOD='POST' ENCTYPE='application/x-www-form-urlencoded' onSubmit='return confirm(mesg)'>";

	my $fname = $query->param("first_name");
	my $lname = $query->param("last_name");
	my $ssn = $query->param("ssn");

	print "<input type='hidden' name='first_name' value='$fname'>\n";
	print "<input type='hidden' name='last_name' value='$lname'>\n";
	print "<input type='hidden' name='ssn' value='$ssn'>\n";

	$qstTot = 1;

	$sql = qq/select qst_cat, count(*), qst_cnt from question, categ_info where qst_cat = cat_id group by qst_cat, qst_cnt/;

	eval
	{
		$dbCrsr = $dbh->prepare($sql);

		$dbCrsr->bind_columns(undef, \($qstCat, $qstCnt, $qstSelCnt));

		$dbCrsr->execute;


		while ($dbCrsr->fetch)
		{

		@qst_arr = getrandarr($qstCnt, $qstSelCnt);
		foreach $qstOrd (@qst_arr)
		{
		$sql = qq/select qst_id, qst_text, qst_disp from question where qst_cat = $qstCat and qst_order = $qstOrd/;
		eval
		{
			$dbCrsr1 = $dbh->prepare($sql);

			$dbCrsr1->bind_columns(undef, \($qstId, $qstText, $qstDisp));

			$dbCrsr1->execute;

			$dbCrsr1->fetchrow;

			if ($qstDisp ne '')
			{
				print "<table WIDTH='100%' ><tr><td>\n";
			}
			print $query->h3($qstTot, '.  ', $qstText);
			$qstTot = $qstTot + 1;
		};
		
		$sql = qq/select ans_id, ans_text, ans_type from answer where ans_qst_id = $qstId order by ans_order/;
		
		eval
		{
			$dbCrsr2 = $dbh->prepare($sql);

			$dbCrsr2->bind_columns(undef, \($ansId, $ansText, $ansType));

			$dbCrsr2->execute;

			$ansStr = '';
			while ($dbCrsr2->fetch)
			{

			if ($ansType == 1)
			{
			print "<input type=radio name=$qstId value=$ansId>$ansText<br>\n";
			}
			else
			{
			$ansStr .= $ansText . ' ';
			$ansStr =~ s/_____/<input type=text name=txt_$ansId size=5 value=''>/;
			}
			}

			if ($ansType == 1)
			{
				$all_name .= $qstId . ',';
			}
			else
			{
				print "$ansStr<br>\n";
				$all_name .= "txt_$qstId" . ',';
			}

			$dbCrsr2->finish;

			if ($qstDisp ne '')
			{
				print "</td><td><div align=right><a href='/rdb2/img/$qstDisp' target=new><img SRC='/rdb2/img/$qstDisp' height=200 width=200><br><u>[Click the image to get enlarged picture]</u></div></td></tr></table>";
			}
		
		};

		} #end of foreach

		}

		print "<input type='hidden' name='all_name' value='$all_name'><br>";

		print $query->submit('submit', 'Submit');
		#print $query->end_form;
		print "</FORM>";

		print "</body>";

		$dbCrsr->finish;
	};	

	if ($@)
	{
		dbDie(__FILE__, __LINE__);
	}
}

sub deleteQuestionFromDB
{
	my($qstId) = @_;

 	my($sql, $dbCrsr, $atdCrsr, $ansId);
	

	#eval
	{
		$sql = qq/Delete RespondentDetail
					where Rspd_qst_id = $qstId/;
		$dbh->do($sql);

		$sql = qq/Select ans_id 
					from answer
					where ans_qst_id=$qstId/;
		$dbCrsr = $dbh->prepare( $sql );
		$dbCrsr->bind_columns(undef, \$ansId);
		$dbCrsr->execute;

		$sql = qq/Delete answerTextDetail
					where ans_id=?/;
		$atdCrsr = $dbh->prepare( $sql );

		while( $dbCrsr->fetch ) {
			$atdCrsr->bind_param( 1, $ansId );
			$atdCrsr->execute;
		}

		$sql = qq/Delete Answer
					where Ans_qst_id = $qstId/;
		$dbh->do($sql);

		$sql = qq/Delete Question
					where Qst_id = $qstId/;

		$dbh->do($sql);
	};

	if ($@)
	{
		dbDie(__FILE__, __LINE__);
	}
}

sub findSubmit
{
	my($type, $rcdId) = @_;

	if (defined $query->param('save'))
	{
		$$type = 'save';
		$$rcdId = -1;
		return;
	}

	if (defined $query->param('saveRet'))
	{
		$$type = 'saveRet';
		$$rcdId = -1;
		return;
	}

	if (defined $query->param('cancel'))
	{
		$$type = 'cancel';
		$$rcdId = -1;
		return;
	}

    my($key);

    foreach $key ($query->param)
	{
		if ($key =~ /(\d+)add/)
		{
			$$type = 'add';
			$$rcdId = $1;
			return;
		}

		if ($key =~ /(\d+)copy/)
		{
			$$type = 'copy';
			$$rcdId = $1;
			return;
		}

		if ($key =~ /(\d+)del/)
		{
			$$type = 'del';
			$$rcdId = $1;
			return;
		}

		if ($key =~ /(\d+)edit/)
		{
			$$type = 'edit';
			$$rcdId = $1;
			return;
		}

		if ($key =~ /(\d+)view/)
		{
			$$type = 'view';
			$$rcdId = $1;
			return;
		}
	}

	$$type='unknown';
	$$rcdId = '-1';
}

sub getrandarr()
{
	my($tot, $req) = @_;

	my $ind = 1;
	my @arr;
	my @ret_arr;
 	my ($randnum, $inum);
	my @rand_arr;

	while ($ind <= $tot)
	{
		push(@arr, $ind);
		$ind = $ind +1;
	}

	for ($inum=0; $inum < $req; ++$inum)
	{
		@ret_arr = randarr(@arr);

		($randnum, @arr) = @ret_arr;

		push(@rand_arr, $randnum);
	}

	return @rand_arr;
}

sub randarr()
{
	my @arr = @_;
	my ($len, @ret_arr, $idex, $i);

	$len = @arr;

	srand(time());
	$idex = (rand()*1000)%$len;

	push(@ret_arr, $arr[$idex]);

	for ($i=0; $i<$len; ++$i)
	{
		if ($i != $idex)
		{
			push(@ret_arr, $arr[$i]);
		}
	}
				
	return @ret_arr;
}

sub checkval()
{
    my ($inputval, $val, $fmt) = @_;
    my ($intpart, $margin, $min, $max, $ret_val, $i);

    my @all_fmt = split(/-/, $fmt);


    if ($all_fmt[0] =~ /^f.*/)
    {
        $intpart = substr($all_fmt[0], 1);
        $margin = $all_fmt[1];

        for ($i=0; $i<$intpart; ++$i)
        {
        $inputval *= 10;
        $val *= 10;
        $margin *= 10;
        }
    }
    else
    {
        $margin = $all_fmt[1];
    }

    $min = $val - $margin - 1;
    $max = $val + $margin + 1;

    if ($inputval < $max and $inputval > $min)
    {
        $ret_val = 1;
    }
    else
    {
        $ret_val = 0;
    }

    return $ret_val;
}
