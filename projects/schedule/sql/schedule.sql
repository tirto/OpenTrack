	SELECT c.mtg_room, c.mtg_section_id, c.mtg_days, c.mtg_start_time,
                     c.mtg_stop_time, e.enr_tally_enr, t.ctf_activity_type,
                     RTRIM(f.fac_first_name) || ' ' || INITCAP(RTRIM(f.fac_last_name)),
                     RTRIM(t.ctf_dept_of_record)
               FROM warehouse.wh_course_meets c,
                     warehouse.wh_course_enroll e,
                     warehouse.wh_course_faculty f,
                     warehouse.wh_course_term t
                   WHERE c.mtg_term = '012'
			AND c.mtg_bldg LIKE '%ENG%'
		    AND c.mtg_term = e.enr_term
		    AND c.mtg_section_id = e.enr_section_id
		    AND c.mtg_term = t.ctf_term
		    AND c.mtg_section_id = t.ctf_section_id
		    AND c.mtg_term = f.fac_term (+)
		    AND c.mtg_section_id = f.fac_section_id (+)
		    AND f.fac_counter (+) = 1;
