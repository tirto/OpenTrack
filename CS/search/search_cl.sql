 SELECT  A.cwk_sid,
               A.cwk_term,
	       A.cwk_sp_course,
               B.ctf_activity_type,
	       A.cwk_sp_grade	
                   FROM warehouse.wh_crswork A, warehouse.wh_course_term B
				 WHERE A.cwk_sid IN (SELECT DISTINCT C.trm_sid
						     FROM warehouse.wh_term C
						     WHERE C.trm_term = '012'
						     AND C.trm_major_1 = 'ENGR'
                                     AND C.trm_career = 'GR'  
							 AND C.trm_degree like '%MS%'
							 AND C.trm_class like '%CL%')
				     AND A.cwk_sp_status = 'E'
					 AND A.cwk_term = B.ctf_term
					 AND A.cwk_sp_course = B.ctf_section_id;
