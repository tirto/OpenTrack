-- Project: CMPE Student Advising
-- File:    create_wh_student.sql
-- By:      Wai-Kwong(Tommy) So
-- Date:    July 26, 2000
--
-- Description:
--   This file contains SQL statement to create a table "wh_student" and an index "wh_student_name_index"
--
--   Description of the table columns:
--   s_sid         : student ID
--   s_name        : student full name 
--   s_type        : address type
--   s_phone       : student phone number 
--   s_discip_code : discipline problem code
--   c_gpa_req     : major GPA requirement message


DROP TABLE wh_student;

CREATE TABLE wh_student (
       s_sid		VARCHAR2(9) NOT NULL,
       s_name		VARCHAR2(32) NOT NULL,
       s_type		VARCHAR(1),
       s_phone		VARCHAR2(10),
       s_discip_code	VARCHAR2(1),
       s_gpa_req	VARCHAR2(80),
       CONSTRAINT pk_wh_student
       PRIMARY KEY (s_sid)
	       USING INDEX
	       TABLESPACE advising );

CREATE INDEX wh_student_name_index ON wh_student (s_name);

QUIT
