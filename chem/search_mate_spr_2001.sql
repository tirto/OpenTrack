SPOOL students_spring_2001.csv
SET TERMOUT OFF
SET TRIMOUT ON
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 100

-- Query for students who meet the following criteria:
--  in the current term(eg. 012), they are enrolled 
--  as a major in MATE or ENR1
SELECT '"' || rtrim(t.trm_sid) || '","' || -- student's sid
       initcap(rtrim(b.bio_name)) || '","' || -- student's name
       initcap(rtrim(m.mc_major_name)) || '"' -- major name
       FROM warehouse.wh_term t,
	    warehouse.wh_maj_codes m,
	    warehouse.wh_bio_demo b
--	    warehouse.wh_career c
	    WHERE t.trm_term='012'
		  AND t.trm_major_1 IN ('MATE', 'ENR1')
		  AND t.trm_major_1 = m.mc_major
		  AND t.trm_sid = b.bio_sid
--		  AND t.trm_sid = c.car_sid
--		  AND t.trm_career = c.car_career
		      ORDER BY t.trm_major_1, b.bio_sid;
SPOOL OFF
QUIT
/
