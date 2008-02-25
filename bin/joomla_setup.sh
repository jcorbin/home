#!/bin/sh
WEBSERVER_GROUP=www-data

WRITABLE_DIRS="cache"
WRITABLE_DIRS="$WRITABLE_DIRS language templates components media modules"
WRITABLE_DIRS="$WRITABLE_DIRS mambots mambots/search mambots/editors-xtd mambots/system mambots/content mambots/editors"
WRITABLE_DIRS="$WRITABLE_DIRS images images/stories images/banners"
WRITABLE_DIRS="$WRITABLE_DIRS administrator/templates administrator/backups administrator/components administrator/modules"

TARFILE=$1

if [ -z "$TARFILE" ]; then
	echo "Missing Joomla tarfile" >&2
	exit 1
fi

if [ -z "$2" ]; then
	INSTDIR=$(pwd);
else
	INSTDIR=$2
fi

[ -d $INSTDIR ] || mkdir -p $INSTDIR || exit 1

cd $INSTDIR

case $TARFILE in
	*.tar.gz|*.tgz)
		tar -xzf $TARFILE || exit 1
		;;
	*.tar.bz2)
		tar -xjf $TARFILE || exit 1
		;;
	none)
		;;
	*)
		echo "Don't know what to do with $TARFILE" >&2
		exit 1
		;;
esac

touch configuration.php

sudo chgrp $WEBSERVER_GROUP $WRITABLE_DIRS configuration.php
sudo chmod g+w $WRITABLE_DIRS configuration.php
