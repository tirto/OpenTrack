select last_day(trunc(datereceived)) As "Month", count(*) AS "Requests"
  from jobmanage group by last_day(trunc(datereceived));