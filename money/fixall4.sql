update jobmanage jm set jm.clientname = (
	select distinct e.firstname || ' ' || e.lastname
		from employee e, jobrequest jr
		where e.email = jr.email
		and jm.datereceived = jr.datereceived );
commit;