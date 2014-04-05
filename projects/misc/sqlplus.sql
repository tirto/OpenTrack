-- listing indexes:
CREATE VIEW indexes AS
       SELECT index_name, index_type, table_name 
       FROM user_indexes;

-- listing tables:
CREATE VIEW tables AS
       SELECT table_name, tablespace_name
       FROM user_tables;

-- listing views:
CREATE VIEW views AS
       SELECT view_name, view_type 
       FROM user_views;

-- create course table index:
CREATE INDEX wh_course_term_only_index ON wh_course (c_term);

-- analyze tables (to optimize):
ANALYZE TABLE wh_student COMPUTE STATISTICS FOR TABLE;
ANALYZE TABLE wh_student COMPUTE STATISTICS FOR ALL INDEXES;
ANALYZE TABLE wh_course COMPUTE STATISTICS FOR TABLE;
ANALYZE TABLE wh_course COMPUTE STATISTICS FOR ALL INDEXES;

-- create a new user:
CREATE USER username IDENTIFIED BY password
       DEFAULT TABLESPACE default_tablespace_name
       TEMPORARY TABLESPACE temp_tablespace_name
       QUOTA 10M ON default_tablespace_name
       QUOTA 10M ON temp_tablespace_name
       PROFILE profile_name;
