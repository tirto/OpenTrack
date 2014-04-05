SELECT DISTINCT C.trm_sid
						     FROM warehouse.wh_term C
						     WHERE C.trm_term = '012'
						     AND C.trm_major_1 = 'ENGR'
							 AND C.trm_career = 'GR'
							 AND C.trm_degree like '%MS%'
							 AND C.trm_class like '%CL%';