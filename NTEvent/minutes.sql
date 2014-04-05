select username, round(24*60*(logout-logon))  as minutes,logon, logout from events order by minutes desc
