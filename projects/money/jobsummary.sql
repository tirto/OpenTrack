select s.description, count(*)
	from jobmanage j, employee e, position p, staffdept s
	where j.clientname = e.firstname || ' ' || e.lastname
	and e.id = p.employeeid and p.staffdept = s.id
	group by s.description order by count(*) desc;