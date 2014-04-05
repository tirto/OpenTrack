SELECT b.bio_sid, b.bio_name, b.bio_sex, substr(c.cwk_sp_course, 1, 8)
	FROM warehouse.wh_bio_demo b,
		  warehouse.wh_crswork c
		  WHERE b.bio_sid = c.cwk_sid AND
					  c.cwk_term = '012' AND
					  c.cwk_sp_status = 'E' AND (
					  		c.cwk_sp_course LIKE 'EE  098%' OR
							c.cwk_sp_course LIKE 'EE  101%' );
