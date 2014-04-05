SPOOL chem_eng_spr_2001.csv
SET TERMOUT OFF
SET TRIMOUT ON
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 150

-- Query for students who meet the following criteria:
--  in the current term(eg. 012), they are enrolled 
--  as a major in CHEG, MATE, ENR1, or ENR2 and are
--  undergrads.
SELECT -- firstname and lastname
       '"' || initcap(rtrim(substr(b.bio_name, instr(b.bio_name, ',')+2))) || '","' ||
       initcap(rtrim(substr(b.bio_name, 1, instr(b.bio_name, ',')-1))) || '","' ||
       initcap(rtrim(m.mc_major_name)) || '","' ||   -- major name
       initcap(rtrim(a1.add_street_1)) || '","' ||   -- address line 1
       initcap(rtrim(a1.add_street_2)) || '","' ||   -- address line 2
       initcap(rtrim(a1.add_city)) || '","' ||	     -- city
       rtrim(a1.add_state) || '","' ||		     -- state
       rtrim(a1.add_zip_code) || '"'		     -- zip code     
       FROM warehouse.wh_term t,
	    warehouse.wh_address a1,
	    warehouse.wh_bio_demo b,
	    warehouse.wh_maj_codes m
	    WHERE t.trm_term = '012'
	    AND t.trm_major_1 IN ('CHEG', 'MATE', 'ENR1', 'ENR2')
	    AND t.trm_major_1 = m.mc_major
	    AND t.trm_career = 'UG'
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
