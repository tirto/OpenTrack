update jobrequest jm set jm.clientname = (
	select distinct e.firstname || ' ' || e.lastname
		from employee e
		where e.email = jm.email);
commit;