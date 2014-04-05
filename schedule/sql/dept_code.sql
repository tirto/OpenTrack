update schedule set department = '18' where dept_abbrev like '%CMPE';
update schedule set department = '16' where dept_abbrev like '%CHE%'; 
update schedule set department = '8' where dept_abbrev like '%MATE';
update schedule set department = '19' where dept_abbrev like '%EE%';
update schedule set department = '1' where dept_abbrev like '%ENGR';
update schedule set department = '22' where dept_abbrev like '%ISE%';
update schedule set department = '21' where dept_abbrev like '%TECH';
update schedule set department = '20' where dept_abbrev like '%AE' or dept_abbrev like '%ME%';


select * from schedule;