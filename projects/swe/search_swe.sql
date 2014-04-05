SPOOL swe_eng.csv
SET TERMOUT OFF
SET TRIMOUT ON
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 150

-- Query for students who meet the following criteria:
--  in the current term(eg. 012), they are enrolled in
--  the college of engineering(52) and female.
SELECT '"' || initcap(rtrim(b.bio_name)) || '","' || -- student's name
       initcap(rtrim(a1.add_street_1)) || '","' ||   -- address line 1
       initcap(rtrim(a1.add_street_2)) || '","' ||   -- address line 2
       initcap(rtrim(a1.add_city)) || '","' ||	     -- city
       rtrim(a1.add_state) || '","' ||		     -- state
       rtrim(a1.add_zip_code) || '"'		     -- zipcode
       FROM warehouse.wh_term t,
	    warehouse.wh_address a1,
	    warehouse.wh_bio_demo b
	    WHERE t.trm_term='012'
	    AND t.trm_college='52'
	    AND t.trm_sid = b.bio_sid
	    AND t.trm_sid = a1.add_sid
	    AND b.bio_sex = 'F'
	    AND a1.add_type IN (SELECT max(a2.add_type)
				       FROM warehouse.wh_address a2
				       WHERE a2.add_sid = a1.add_sid
				       AND a2.add_type IN ('D', 'H', 'M'))
		ORDER BY b.bio_name;
SPOOL OFF
QUIT
/
