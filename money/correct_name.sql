insert into correct_name (old, new)
select distinct j.clientname, e.firstname || ' ' || e.lastname
	from jobrequest j, employee e
		where j.clientname not in (
			select firstname || ' ' || lastname from employee )
	and e.email = j.email;
commit;