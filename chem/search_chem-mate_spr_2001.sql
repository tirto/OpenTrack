SPOOL chem-mate_eng_spr_2001.csv
SET TERMOUT OFF
SET TRIMOUT ON
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 150

-- Query for students who meet the following criteria:
--  in the current term(eg. 012), they are enrolled 
--  as a undergraduate major in CHEG or MATE. Display
--  their overall gpa and their fall 2000 gpa along
--  with their mailing address.
--  NOTE: cannot determine fall 2000 gpa so not included.
SELECT '"' || initcap(rtrim(b.bio_name)) || '","' || -- student's name
       initcap(rtrim(t.trm_sid)) || '","' ||	     -- student's sid
       initcap(rtrim(m.mc_major_name)) || '","' ||   -- major name
--     rtrim(t.trm_class) || '","' ||		     -- classification
       initcap(rtrim(a1.add_street_1)) || '","' ||   -- address line 1
       initcap(rtrim(a1.add_street_2)) || '","' ||   -- address line 2
       initcap(rtrim(a1.add_city)) || '","' ||	     -- city
       a1.add_state || '","' ||			     -- state
       a1.add_zip_code || '","' ||		     -- zip code
--     t2.trm_curr_gpa || '","' ||		     -- fall 2000 gpa?
       c.car_stats_ov_gpa || '"'		     -- overall gpa
--     a1.add_country || '","' ||		     -- country
--     a1.add_phone || '"'			     -- phone
       FROM warehouse.wh_term t,		     -- spring 2001 term
--	    warehouse.wh_term t2,		     -- fall 2000 term
	    warehouse.wh_address a1,		     -- address table
	    warehouse.wh_maj_codes m,		     -- major description
	    warehouse.wh_bio_demo b,		     -- student name
	    warehouse.wh_career c		     -- student career
	    WHERE t.trm_term = '012'
	    AND t.trm_major_1 IN ('CHEG', 'MATE')
	    AND t.trm_major_1 = m.mc_major
	    AND b.bio_sid    = t.trm_sid
	    AND a1.add_sid   = t.trm_sid
	    AND c.car_sid    = t.trm_sid
--	    AND t2.trm_sid   = t.trm_sid
--	    AND t2.trm_term  = '004'
	    AND c.car_career = 'UG'
	    AND t.trm_career = c.car_career
	    AND a1.add_type IN (SELECT max(a2.add_type)
				       FROM warehouse.wh_address a2
				       WHERE a2.add_sid = a1.add_sid
				       AND a2.add_type IN ('H', 'M'))
				       		ORDER BY t.trm_major_1,
						t.trm_class, b.bio_name;

SPOOL OFF
QUIT
/
