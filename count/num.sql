-- Determine the enrollment limit and enrolled tally for
-- courses from the current semester (004) which are taking
-- place in the specified building (ENG) in the specified
-- rooms (390-394).
SELECT sum(ce.enr_limit) AS "Enrolled Limit",
       sum(ce.enr_tally_enr) AS "Enrolled Tally"
       FROM warehouse.wh_course_enroll ce 
       WHERE ce.enr_term = '004' 
	     AND ce.enr_section_id IN 
		 (SELECT cm.mtg_section_id 
			 FROM warehouse.wh_course_meets cm 
			      WHERE cm.mtg_term = '004' 
			      AND cm.mtg_bldg = 'ENG  ' 
			      AND cm.mtg_room IN ('390   ', '391   ',
						  '392   ', '393   ',
						  '394   '))
-- Kindness,
-- This is the answer to your question.
-- Source code maybe found on
-- Dolphin in the file /tmp/num.sql.
--
-- Enrolled Limit Enrolled Tally
-- -------------- --------------
--          1920           1480
-- Prasanth
/
