#!/bin/sh
export PATH="$PATH:/usr/X11R6/bin:/projects/oracle/bin"
export LD_LIBRARY_PATH=/projects/oracle/lib
export ORACLE_HOME=/projects/oracle
export ORACLE_SID=rdb1
export ORACLE_DOC=/projects/oracle/doc
export ORACLE_TERM=xiterm

cd /home/tadji/CS/

echo -ne "\n****** Extracting C/S student records ******\n"
time perl client_server_students.pl
echo -ne "\n****** Extracting C/S coursework records *****\n"
time perl client_server_course.pl
