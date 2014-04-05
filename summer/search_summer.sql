SPOOL summer_eng.txt
SET TERMOUT OFF
SET TRIMOUT ON
SET PAGESIZE 0
SET HEADING OFF
SET FEEDBACK OFF
SET LINESIZE 75

-- Query for engineering courses taught over the summer.
SELECT DISTINCT rtrim(substr(c.ctf_section_id,1,4)), 
		rtrim(substr(c.ctf_section_id,5,4)),
		rtrim(substr(c.ctf_section_id,9,3)),
		rtrim(c.ctf_section_title),
		rtrim(m.mtg_bldg), rtrim(m.mtg_room)
		FROM warehouse.wh_course_term c,
		warehouse.wh_course_meets m
		WHERE c.ctf_term = '013'
		AND m.mtg_term = c.ctf_term
		AND m.mtg_section_id = c.ctf_section_id
		AND (c.ctf_section_id LIKE 'AE  %' OR
		     c.ctf_section_id LIKE 'AVIA%' OR
		     c.ctf_section_id LIKE 'CHE %' OR
		     c.ctf_section_id LIKE 'CMPE%' OR
		     c.ctf_section_id LIKE 'CE  %' OR
		     c.ctf_section_id LIKE 'EE  %' OR
		     c.ctf_section_id LIKE 'ENGR%' OR
		     c.ctf_section_id LIKE 'ISE %' OR
		     c.ctf_section_id LIKE 'MATE%' OR
		     c.ctf_section_id LIKE 'ME  %' OR
		     c.ctf_section_id LIKE 'TECH%');			
SPOOL OFF
QUIT
/
