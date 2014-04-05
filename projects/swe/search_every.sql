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
SELECT initcap(rtrim(b.bio_name))
       FROM warehouse.wh_term t,
	    warehouse.wh_bio_demo b
	    WHERE t.trm_term='012'
	    AND t.trm_college='52'
	    AND t.trm_sid = b.bio_sid
	    AND b.bio_sex = 'F'
		ORDER BY b.bio_name;
SPOOL OFF
QUIT
/
