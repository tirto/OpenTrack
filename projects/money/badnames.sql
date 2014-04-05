select clientname, count(*) from jobmanage
	where clientname not in (
		select firstname || ' ' || lastname from employee )
	group by clientname order by count(*) desc, clientname;