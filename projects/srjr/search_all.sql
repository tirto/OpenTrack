SPOOL all_eng.csv
SET TERMOUT OFF
SET TRIMOUT ON
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 300

-- Query for students who meet the following criteria:
--  in the current term(eg. 004), they are enrolled in
--  the college of engineering(52) as undergraduate
--  students(UG) in the classification as junior,
--  senior or second degree (JR, SR, SB).
SELECT '"' || initcap(rtrim(b.bio_name)) || '","' || -- student's name
       initcap(rtrim(t.trm_sid)) || '","' ||	     -- student's sid
       initcap(rtrim(m.mc_major_name)) || '","' ||   -- major name
       rtrim(t.trm_class) || '","' ||		     -- classification
       initcap(rtrim(a1.add_street_1)) || '","' ||   -- address line 1
       initcap(rtrim(a1.add_street_2)) || '","' ||   -- address line 2
       initcap(rtrim(a1.add_city)) || '","' ||	     -- city
       a1.add_state || '","' ||			     -- state
       a1.add_zip_code || '","' ||		     -- zipcode
       a1.add_country || '","' ||		     -- country
       a1.add_phone || '"'			     -- phone
       FROM warehouse.wh_term t,
	    warehouse.wh_address a1,
	    warehouse.wh_maj_codes m,
	    warehouse.wh_bio_demo b
	    WHERE t.trm_term='004'
	    AND t.trm_college='52'
	    AND t.trm_career='UG'
	    AND t.trm_class IN ('JR ', 'SR ', 'SB ')
	    AND t.trm_major_1 = m.mc_major
	    AND t.trm_sid = b.bio_sid
	    AND t.trm_sid = a1.add_sid
	    AND a1.add_type IN (SELECT max(a2.add_type)
				       FROM warehouse.wh_address a2
				       WHERE a2.add_sid = a1.add_sid
				       AND a2.add_type IN ('H', 'M'))
		ORDER BY t.trm_major_1, t.trm_class, b.bio_name;
SPOOL OFF
QUIT
/
