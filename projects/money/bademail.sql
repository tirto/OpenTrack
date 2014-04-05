select j.clientname "Client Name", j.email "Bad Email", e.email "Correct Email"
	from jobrequest j, employee e
	where j.clientname = e.firstname || ' ' || e.lastname
		and j.email != e.email;
