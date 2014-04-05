update jobmanage jm set jm.clientname = (
		select cn.new from correct_name cn where jm.clientname = cn.old )
	where jm.clientname in ( select old from correct_name );

update jobrequest jr set jr.clientname = (
		select cn.new from correct_name cn where jr.clientname = cn.old )
	where jr.clientname in ( select old from correct_name );

commit;
