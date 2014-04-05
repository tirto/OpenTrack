update jobmanage jm set jm.clientname = (
	select distinct e.firstname || ' ' || e.lastname
		from employee e, jobrequest jr
		here e.email = jr.email
		and jm.datereceived = jr.datereceived )
	where jm.clientname not in (
		select j2.clientname
		from jobmanage j2
		where j2.clientname not in (
			select firstname || ' ' || lastname from employee ));