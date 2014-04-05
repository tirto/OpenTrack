select trunc(logon), round (min(24*60*(logout-logon)))  as min, round (max(24*60*(logout-logon)))  as max,round (avg(24*60*(logout-logon)))  as avg
	from events 	
		where 24*60*(logout-logon) < 1000
			group by trunc(logon)
