set PAGESIZE 1000
set LINESIZE 200
column personassigned format A10
column title format A40
column comments format A80 truncated
select datereceived AS "Started", 
  trunc(datefinished-datereceived) AS "Days", 
  rtrim(personassigned) AS "Assigned", 
  rtrim(title) AS "Title",
  rtrim(comments) AS "Comments"
  from jobmanage
  where trunc(datefinished-datereceived) > 100
  order by trunc(datefinished-datereceived) desc;
  
