-- Project: Client Server Student Advising
-- File:    create_cs_courses.sql
-- By:      Tirto Adji
-- Date:    Jan 16, 2001
--
-- Description:
--   This file contains SQL statement to create a table "cs_courses" 
--
--   Description of the table columns:
--   cs_sid         : student ID
--   cs_term        : semester term 
--   cs_course      : course name
--   cs_type        : course type 
--   cs_grade       : student grade 


DROP TABLE cs_courses;

CREATE TABLE cs_courses (
       cs_sid		VARCHAR2(9) NOT NULL, 
       cs_term		VARCHAR2(3) NOT NULL,
       cs_course        VARCHAR2(11) NOT NULL,
       cs_type          VARCHAR2(3) NOT NULL,
       cs_grade		VARCHAR2(3),
       foreign key (cs_sid) references cs_students
);


