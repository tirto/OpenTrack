SPOOL students.csv
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
/// incomplete code
SELECT '"' || initcap(rtrim(t.trm_sid)) || '","' ||
       initcap(rtrim(b.bio_name)) || '","' ||
       initcap(rtrim(m.mc_major_name)) || '","' ||
       rtrim(t.trm_class) || '","' ||
       initcap(rtrim(a1.add_street_1)) || '","' ||
       initcap(rtrim(a1.add_street_2)) || '","' ||
       initcap(rtrim(a1.add_city)) || '","' ||
       rtrim(a1.add_state) || '","' ||
       rtrim(a1.add_zip_code) || '","' ||
       initcap(rtrim(a1.add_country)) || '","' ||
       initcap(rtrim(a1.add_phone)) || '"'
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
				       WHERE a2.add_sid = a1.add_sid)
		ORDER BY t.trm_major_1, b.bio_name;

SPOOL OFF
QUIT

-- Required fields:
--*  trm_sid=(bio_sid, add_sid)
--*  trm_major_1=(mc_major)
--*  trm_class
--*  mc_major_name
--*  bio_name
--*   add_type
--  add_street_1
--  add_street_2
--  add_city
--  add_state
--  add_zip_code
--  add_country
--  add_phone
/
