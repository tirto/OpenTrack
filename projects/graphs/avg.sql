set PAGESIZE 1000
select trunc(j1.datereceived) as "Date Started", 
  round(avg(j2.datefinished-j2.datereceived)) as "Avg Days"
  from jobmanage j1, jobmanage j2
  where trunc(j1.datereceived) in
    (select distinct trunc(j3.datereceived) from jobmanage j3)
    and (j1.datereceived-j2.datereceived) <= 30
    group by trunc(j1.datereceived);