SELECT	DISTINCT
	      lower(substr(replace(b.bio_name,'-'), 1, least(instr(replace(b.bio_name,'-'), ', ')-1,6)) || substr(b.bio_sid,6,4)) AS userid,
	      to_char('MMDDYY',b.bio_birth_dt) AS password,
	      initcap(substr(b.bio_name, 1, instr(b.bio_name, ', ')-1)) AS family,
	      rtrim(initcap(substr(b.bio_name, instr(b.bio_name, ', ')+2))) AS given,
	      ' ' AS email,
	      decode(b.bio_sex,'F',1,'M',2) AS gender
			FROM warehouse.wh_bio_demo b,
		  	warehouse.wh_crswork c
		  	WHERE b.bio_sid = c.cwk_sid AND
						c.cwk_term = '012' AND
						c.cwk_sp_status = 'E' AND
					  	substr(c.cwk_sp_course,1,8) IN ('EE  098 ', 'EE  101 ' );
