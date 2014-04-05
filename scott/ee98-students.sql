-- selects all students taking EE98 and EE101 classes in Spring 2001
-- user id is up to 6 characters of last name followed by last 4 digits of their SID
-- password is birthdate in the format MMDDYY
-- students name is split into last name and first name plus middle name
-- email is not available and a fake one is used
-- gender is 1=female, 2=male

SELECT	DISTINCT
	      replace(lower(substr(b.bio_name, 1, least(instr(b.bio_name, ', ')-1,6))),'-') || substr(b.bio_sid,6,4) AS userid,
	      to_char(b.bio_birth_dt, 'MMDDYY') AS password,
	      initcap(substr(b.bio_name, 1, instr(b.bio_name, ', ')-1)) AS family,
	      rtrim(initcap(substr(b.bio_name, instr(b.bio_name, ', ')+2))) AS given,
	      'nobody@email.sjsu.edu' AS email,
	      decode(b.bio_sex,'F',1,'M',2) AS gender
			FROM warehouse.wh_bio_demo b,
		  	warehouse.wh_crswork c
		  	WHERE b.bio_sid = c.cwk_sid AND
						c.cwk_term = '012' AND
						c.cwk_sp_status = 'E' AND
					  	substr(c.cwk_sp_course,1,8) IN ('EE  098 ', 'EE  101 ' );
