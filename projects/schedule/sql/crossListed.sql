SELECT B.mtg_term, A.ctf_section_id,
             A.ctf_combined_sect, A.ctf_cross_list_permit, A.ctf_section_title
  FROM warehouse.wh_course_term A, warehouse.wh_course_meets B
	WHERE A.ctf_term = B.mtg_term
		AND A.ctf_section_id = B.mtg_section_id
                AND (A.ctf_section_id like 'ENGR%' OR A.ctf_section_id like 'CMPE%')
            	AND A.ctf_term = '012'
		AND A.ctf_cross_list_permit = 'Y'
		