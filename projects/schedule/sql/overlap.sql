SELECT department, codenumber, section
       FROM classmeetingx
            WHERE days like '%M%W%'
                 AND not ((starttime < '0700') OR (stoptime < '0600')) 
                 AND roomnumber = '232'
                 AND building = 'ENG'				
				       