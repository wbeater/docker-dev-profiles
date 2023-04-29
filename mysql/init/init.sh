if [ !-f "/usr/bin/mysql" ]
then
	ln -s /usr/bin/mariadb /usr/bin/mysql
	ln -s /usr/bin/mariadbd /usr/bin/mysqld
fi

if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
	MYSQL_ROOT_PASSWORD=`pwgen 16 1`
	echo "[i] MySQL root Password: $MYSQL_ROOT_PASSWORD"
fi

MYSQL_DATABASE=${MYSQL_DATABASE:-""}
MYSQL_USER=${MYSQL_USER:-""}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

tfile=`mktemp`
if [ ! -f "$tfile" ]; then
	return 1
fi

cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES ;
GRANT ALL ON *.* TO 'root'@'%' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
GRANT ALL ON *.* TO 'root'@'localhost' identified by '$MYSQL_ROOT_PASSWORD' WITH GRANT OPTION ;
SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}') ;
DROP DATABASE IF EXISTS test ;
FLUSH PRIVILEGES ;
EOF

if [ "$MYSQL_DATABASE" != "" ]; then
	echo "[i] Creating database: $MYSQL_DATABASE"
	if [ "$MYSQL_CHARSET" != "" ] && [ "$MYSQL_COLLATION" != "" ]; then
		echo "[i] with character set [$MYSQL_CHARSET] and collation [$MYSQL_COLLATION]"
		echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET $MYSQL_CHARSET COLLATE $MYSQL_COLLATION;" >> $tfile
	else
		echo "[i] with character set: 'utf8' and collation: 'utf8_general_ci'"
		echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
	fi

	if [ "$MYSQL_USER" != "" ]; then
		echo "[i] Creating user: $MYSQL_USER with password $MYSQL_PASSWORD"
		echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
		echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
		echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
	fi
fi

MYSQL_CLIENT="/usr/bin/mariadb -uroot"
eval "${MYSQL_CLIENT} ${MYSQL_DATABASE} < $tfile"
#/usr/bin/mysqld --user=mysql --bootstrap --verbose=0 --skip-name-resolve --skip-networking=0 < $tfile
rm -f $tfile

MYSQL_CMD="/usr/bin/mariadb -u$MYSQL_USER -p$MYSQL_PASSWORD"
# Default scope is our newly created database
echo "init: adding ${MYSQL_CMD} ${MYSQL_DATABASE} < /docker-entrypoint-initdb.d/db.dump"
eval "${MYSQL_CMD} ${MYSQL_DATABASE} < /docker-entrypoint-initdb.d/db.dump"
