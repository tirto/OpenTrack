update jobrequest set j1.clientname = e1.firstname || ' ' || e1.lastname
	from employee e1, jobrequest j1
	where clientname not in (
		select j2.clientname
		from jobrequest j2
		where j2.clientname not in (
			select firstname || ' ' || lastname from employee ))
	and e1.email = j.email;
