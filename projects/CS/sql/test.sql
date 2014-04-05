-- which college are CMPE majors in?
SELECT a.trm_college, count(*) FROM warehouse.wh_term a
       WHERE a.trm_term='004' AND a.trm_major_1='CMPE'
	     GROUP BY a.trm_college;
-- TR   COUNT(*)
-- -- ----------
-- 52       1595

-- what majors are all students in trm_college=52?
SELECT a.trm_major_1, count(*) FROM warehouse.wh_term a
       WHERE a.trm_term='004' AND a.trm_college='52'
	     GROUP BY a.trm_major_1;
-- MAJOR   COUNT(*)
-- ---- ----------
-- AERO        154
-- AVI1          1
-- AVI2         22
-- AVIA        195
-- CHEG        135
-- CMPE       1600
-- CVEG        294
-- ELEG       1286
-- ENGR        476
-- ENR1          8
-- ISEG        119
-- ITE1         76
-- ITE9         23
-- ITEC        160
-- ITQA          9
-- MATE         55
-- MECH        434
-- XIAR          1
-- XIT2          1
-- XIT5          4
-- XIT7          3
-- XIT8          6
-- YIND          3 

-- any engineering majors not in college?
SELECT a.trm_college, count(*) FROM warehouse.wh_term a
       WHERE a.trm_term='004' AND a.trm_college!='52' AND
	     (  a.trm_major_1='AERO'
	     OR a.trm_major_1='AVI1'
	     OR a.trm_major_1='AVI2'
	     OR a.trm_major_1='AVIA'
	     OR a.trm_major_1='CHEG'
	     OR a.trm_major_1='CMPE'
	     OR a.trm_major_1='CVEG'
	     OR a.trm_major_1='ELEG'
	     OR a.trm_major_1='ENGR'
	     OR a.trm_major_1='ENR1'
	     OR a.trm_major_1='ISEG'
	     OR a.trm_major_1='ITE1'
	     OR a.trm_major_1='ITE9'
	     OR a.trm_major_1='ITEC'
	     OR a.trm_major_1='ITQA'
	     OR a.trm_major_1='MATE'
	     OR a.trm_major_1='MECH'
	     OR a.trm_major_1='XIAR'
	     OR a.trm_major_1='XIT2'
	     OR a.trm_major_1='XIT5'
	     OR a.trm_major_1='XIT7'
	     OR a.trm_major_1='XIT8'
	     OR a.trm_major_1='YIND')
	     GROUP BY a.trm_college;
-- no rows selected

-- are there any students in trm_college=52 that have an a minor?
SELECT a.trm_minor, count(*) FROM warehouse.wh_term a
       WHERE a.trm_term='004' AND a.trm_college='52' 
	     AND a.trm_minor!='    ' GROUP BY a.trm_minor;
-- TRM_   COUNT(*)
-- ---- ----------
-- ARS1          2
-- BUS1        128
-- CHEM          2
-- CJAD          1
-- CSCI         13
-- DRA1          1
-- DSG1          1
-- DST1          1
-- ECON          1
-- ENGL          1
-- HUMN          1
-- JPN1          2
-- MATH         12
-- MUSC          1
-- MXAM          1
-- PHYS          2
-- SPAN          1
-- SPCH          1

-- are there students which have a engineering minor but not in the
-- engineering college (trm_college!=52)
SELECT a.trm_minor, a.trm_major_1 FROM warehouse.wh_term a
       WHERE a.trm_term='004' AND a.trm_college!='52' AND
	     (  a.trm_minor='AERO'
	     OR a.trm_minor='AERO'
	     OR a.trm_minor='AVI1'
	     OR a.trm_minor='AVI2'
	     OR a.trm_minor='AVIA'
	     OR a.trm_minor='CHEG'
	     OR a.trm_minor='CMPE'
	     OR a.trm_minor='CVEG'
	     OR a.trm_minor='ELEG'
	     OR a.trm_minor='ENGR'
	     OR a.trm_minor='ENR1'
	     OR a.trm_minor='ISEG'
	     OR a.trm_minor='ITE1'
	     OR a.trm_minor='ITE9'
	     OR a.trm_minor='ITEC'
	     OR a.trm_minor='ITQA'
	     OR a.trm_minor='MATE'
	     OR a.trm_minor='MECH'
	     OR a.trm_minor='XIAR'
	     OR a.trm_minor='XIT2'
	     OR a.trm_minor='XIT5'
	     OR a.trm_minor='XIT7'
	     OR a.trm_minor='XIT8'
	     OR a.trm_minor='YIND');
-- TRM_ TRM_
-- ---- ----
-- AVIA MATH
-- AVIA CJAD
-- AVIA SPAN
-- AVIA BUSK
-- AVIA POLS
-- AVIA GEOG
-- ITEC BUSG

-- what possibilities are there for career, degree, and class?
SELECT count(*), a.trm_career, a.trm_degree, a.trm_class
       FROM warehouse.wh_term a
	    WHERE a.trm_term='004' 
	    AND a.trm_college='52' 
	    GROUP BY a.trm_career, a.trm_degree, a.trm_class;
--  COUNT(*) CA DE  CLA
------------ -- --- ---
--         2 GR MA  CC
--         1 GR MA  CL
--       414 GR MS  CC
--       560 GR MS  CL
--         1 UG BA  SR
--         1 UG BS  CE3
--         7 UG BS  CE4
--      1091 UG BS  FR
--       506 UG BS  SO
--       784 UG BS  JR
--      1535 UG BS  SR
--        94 UG BS  SB

-- test query
SELECT t.trm_sid AS sid,		-- student ID
       t.trm_major_1 AS code,		-- student's major code
       m.mc_major_name AS major		-- student's major desc
       t.trm_class as class		-- classification
       FROM warehouse.wh_term t warehouse.wh_maj_codes m
	    WHERE t.trm_term='004'	-- for the current semester
	    AND m.mc_major = t.trm_major_1 -- join major code to desc
	    AND t.trm_college='52'	-- in the engineering college
	    AND t.trm_career='UG'	-- is an undergraduate(BS)
	    AND (t.trm_class='JR'	-- is a junior
		OR t.trm_class='SR'	-- or a senior
		OR t.trm_class='SB')	-- or a second degree
		ORDER BY t.trm_major_1, t.trm_sid;

-- what possibilities are there for address type?
SELECT add_type, count(*) FROM warehouse.wh_address GROUP BY add_type;
-- A   COUNT(*)
-- - ----------
-- M     336683
-- D      55889
-- B      19261
-- O       8677
-- H       3876

-- what is the address type of engineering students?
SELECT a.add_type, count(*)
       FROM warehouse.wh_term t, 
	    warehouse.wh_address a
	    WHERE t.trm_term='004'
	    AND t.trm_college='52'
	    AND t.trm_career='UG'
	    AND t.trm_class IN ('JR ', 'SR ', 'SB ')
	    AND t.trm_sid = a.add_sid
		GROUP BY a.add_type;
-- A   COUNT(*)
-- - ----------
-- M       2405
-- D        362
-- B        183
-- H        139
-- O         13

