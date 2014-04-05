# number of times to retry on failures
count = 3;
do {
    eval {
	# lots of work and database updates

	# commit changes
	$dbh->commit;
    };

    if ($@) {
	# rollback on failure
	$dbh->rollback;
	count--;
    } else {
	# else exit on success
	last;
    }
} while (count > 0);
