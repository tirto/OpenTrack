-- create various indexes to speed up queries

CREATE INDEX jobmanage_personassigned
       ON jobmanage (personassigned, datereceived);

CREATE INDEX jobmanage_title 
       ON jobmanage (title, datereceived);

CREATE INDEX jobmanage_clientname 
       ON jobmanage (title, clientname, datereceived);

CREATE INDEX jobmanage_priority
       ON jobmanage (priority, datereceived);
