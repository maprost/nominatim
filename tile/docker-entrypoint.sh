#!/bin/bash
IMPORTED=/var/lib/postgresql/12/main/imported
if [ -f $IMPORTED ]
then
	echo 'DATA has been imported.'
else
	chown renderer /var/lib/mod_tile
	/run.sh import
	touch $IMPORTED
fi
/run.sh run
