SPOOL chem1b.csv
SET TERMOUT OFF
SET TRIMOUT ON
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 150

-- Query for students who meet the following criteria:
--  in the current term(eg. 012), they registered for
--  chem1b and are still enrolled.

SELECT '"' || initcap(rtrim(b.bio_name)) || '","' || -- student's name
       initcap(rtrim(a1.add_street_1)) || '","' ||   -- address line 1
       initcap(rtrim(a1.add_street_2)) || '","' ||   -- address line 2
       initcap(rtrim(a1.add_city)) || '","' ||	     -- city
       rtrim(a1.add_state) || '","' ||		     -- state
       rtrim(a1.add_zip_code) || '"'		     -- zipcode
       FROM warehouse.wh_address a1,
	    warehouse.wh_bio_demo b,
	    warehouse.wh_crswork w
	    WHERE w.cwk_term = '012'		     -- current term?
	    AND (w.cwk_sp_course LIKE 'CHEM001B01%'  -- registered course?
	    OR w.cwk_sp_course LIKE   'CHEM001B21%')
	    AND w.cwk_sp_status = 'E'		     -- still enrolled?
	    AND w.cwk_sid = b.bio_sid
	    AND b.bio_sid = a1.add_sid
	    AND a1.add_sid = w.cwk_sid
	    AND a1.add_type IN (SELECT max(a2.add_type)
				       FROM warehouse.wh_address a2
				       WHERE a2.add_sid = a1.add_sid
				       AND a2.add_type IN ('D', 'H', 'M'))
		ORDER BY b.bio_name;
SPOOL OFF
QUIT
/
