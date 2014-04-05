select d.description as "Department", count(c.amount) as "Charges",
	sum(c.amount) as "Total"
		from staffdept d, charges c
			where d.id = c.department (+)
			group by d.description
			order by d.description;