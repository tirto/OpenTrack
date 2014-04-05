#!/usr/bin/perl -w
# Perl script that generates a form to add users to a mailing list and on
# return stores users data on a flat file
 
use CGI qw/:standard *Tr *table *blockquote *fieldset/;

use 5.004;
use Fcntl qw (:flock);

print header,start_html(-title=>'College of Engineering Alumni Mailing List',-BGCOLOR=>'white') , h1({-align=>center},"College of Engineering Alumni Mailing List");
print p({-align=>center},img{-src=>"http://www.engr.sjsu.edu/images/jpgs/sjsu-coe.jpg"});
if (param())
{ 
    @names = param();
    open(APPENDFILE,">>/data/mailinglist")|| die "Can't open mailinglist";
    flock(APPENDFILE,LOCK_EX);
    foreach $name(@names) 
    {
      if ($name ne "Submit Form") {print APPENDFILE $name,"=",param($name),","};
    }
    print APPENDFILE "\n";
    close APPENDFILE;
    print b("Thank You.",
             p("You Have been added to our mailing list."));  
    print b(font({-face=>"helvetica" -size=>5},a({-href=>"alumni.pl"},"Go to the start of the form")));      
}
else 
{
  print
  hr(),
  
  start_form(),
      
      table({-align=>center},
  Tr(td({-align=>right},"Name : "),
     td({-align=>left -colspan=>3},textfield("name","",40))),
  Tr(td({align=>right},"Title :"),
     td({-align=>left -colspan=>3},textfield("title","",40))),
  Tr(td({-align=>right},"Organization : "),
     td({-align=>left -colspan=>3
         -size=>40},textfield("organization","",40))),
  Tr(td({-align=>right},"Address : "),
     td({-align=>left -colspan=>3},textfield("address","",40))),
  Tr(td({-align=>right},"City :"),
     td({-align=>left -colspan=>3},textfield("city","",25))),
  Tr(td(),td({-align=>left},table({-border=>"1" },
  Tr(td(b("U.S. Residents Only"),br())),
	      Tr(td(table({-border=>"0"},
  Tr(td({-align=>right},"State : "),
     td({align=>right -colspan=>3},popup_menu(-name =>"state",
                                        -values=>['Alabama', 'Alaska', 'Arizona', 'Arkansas' ,'California' ,'Colorado', 'Conneticut' ,'Washington D.C.', 'Delaware', 'Florida', 'Georgia', 'Hawaii', 'Idaho' , 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland','Massachusetts', 'Michigan', 'Minnesota', 'Missisipi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pensylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas','Utah' ,'Vermont', 'Virgina', 'Washington', 'West Virginia', 'Wisconsin' ,'Wyoming'],   
    -default=>"Alabama"))),
  Tr(td({-align=>right},"Postal/ZIP code : "),
     td({-align=>left -colspan=>3 },textfield("zipcode","",6,6))),
  )))
  ))),
   Tr(td(),td{-align=>left -colspan=>3},(table({-border=>"1" },
  Tr(td(b("Non-U.S. Residents Only"),br())),
  Tr(td(table({-border=>"0"},
  Tr(td({-align=>right},"State/Province : "),
     td({-align=>left},textfield("state/province","",25))),
  Tr(td({-align=>right},"Postal code : "),
     td({-align=>left -colspan=>3 },textfield("postal code","",15))),
  Tr(td({-align=>right},"Country : "),
     td({-align=>left -colspan=>3},textfield("country","",25)))
  )))
  ))),
  Tr(td({-align=>right},"Phone Number : ("),
     td({-align=>left -colspan=>3},textfield("phone area code","",3,3),
         ")-",
	 textfield("phone number","",15))),
   Tr(td({-align=>right},"Fax Number : ("),
      td({-align=>left -colspan=>3 -maxlength=>3},textfield("fax area code","",3,3),
         ")-",
	 textfield("fax number","",15))),
  Tr(td({-align=>right} ,"Email adress : "),
     td({-align=>left -colspan=>3},textfield("email address","",40))),
  Tr(td({-align=>right} , "Comments : "),
     td({-align=>left -colspan=>3},textarea("comments","",5,40))),
  Tr(td(),td({-align=>right},checkbox(-name=>"survery choice",-checked=>"checked",-value=>"Add me",-label=>"  Yes ,I would like to be included in future surveys"))),
  ),#end table
  ;
  
  print hr(),
  p({-align=>right},reset("Reset Form"),submit("Submit Form"));
  print p({-align=>right},"Service provided by Engineering Computer Services");
  print end_form, hr,end_html;  
} 
