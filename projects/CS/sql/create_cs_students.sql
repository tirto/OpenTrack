-- Project: Client Server Student Advising
-- File:    create_cs_students.sql
-- By:      Tirto Adji
-- Date:    Jan 16, 2001
--
-- Description:
--   This file contains SQL statement to create a table "cs_students" 
--
--   Description of the table columns:
--   cs_sid         : student ID
--   cs_lname       : student last name 
--   cs_fname       : student first name 
--   cs_class       : student classfication
--   cs_email       : student email address 
--   cs_phone       : student phone number 


DROP TABLE cs_students;

CREATE TABLE cs_students (
       cs_sid		VARCHAR2(9) NOT NULL, 
       cs_lname		VARCHAR2(32) NOT NULL,
       cs_fname         VARCHAR2(32) NOT NULL, 
       cs_class		VARCHAR(2),
       cs_email         VARCHAR2(32),
       cs_phone		VARCHAR2(10),
       primary key (cs_sid)
);

