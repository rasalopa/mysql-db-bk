#!/usr/bin/env bash

source mybk.conf

function logDate() {
    `echo "[ $NOW ] #####" >> mybk.log`
}

function mysqlCreateCredentialsFile() {
    let success=1

    `echo "[client]" > .access.cnf 2>&1`

    if [ -n "$MYSQL_HOST" ] && [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWD" ]; then
	`echo "host=$MYSQL_HOST" >> .access.cnf 2>&1`
	`echo "user=$MYSQL_USER" >> .access.cnf 2>&1`
	`echo "password='$MYSQL_PASSWD'" >> .access.cnf 2>&1`
	success=0
    fi

    return $success
}

function testMysqlConnection() {
    while ! `$MYSQL --defaults-file=.access.cnf -e "USE $DATABASE;" >> mybk.log 2>&1`; do
	return 1
    done
}

function sendEmail() {
    if ! `echo "El script que genera el resplado de base de datos a terminado, para mas informacion vea mybk.log" | mail -s "$version" $TO`; then
	return 1
    fi
}

function mysqlService() {
    SERVICE='mysqld'
    if [ -e "$MYSQL" ] && [ -e "$MYSQL_SOCK" ] && [ -e "$MYSQLDUMP" ]; then
	if ! `ps ax | grep -v grep | grep $SERVICE >> /dev/null`; then
	    return 1
	fi
    else
	return 1
    fi
}

function valConnectionData() {
    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_HOST" ] && [ -n "$DATABASE" ] && [ -n "$MYSQL_PASSWD" ]; then
	return 0
    else
	return 1
    fi
}

function backupDatabase() {
    databases=`$MYSQL --defaults-file=.access.cnf -e "SHOW DATABASES;" | grep $DATABASE`

    for db in $databases; do
	`mkdir -m 755 -p $BACKUP_DIR/$db`

	# Guarda el dump completo de la base de datos en un solo archivo, ejem. database.sql
	#$MYSQLDUMP --force --opt --defaults-file=.access.cnf --lock-tables=false --databases $db | gzip > "$BACKUP_DIR/$db/$db.gz"

	tables=`$MYSQL --defaults-file=.access.cnf $db -e "SHOW TABLES;"`

	for x in $tables; do
	    if [ "$x" != "Tables_in_$DATABASE" ]; then

		# Guarda el dump de cada una de las tablas en la base de datos, ejem. table(n).sql
		if [ "$LOCK_TABLES" = true ]; then
		    dump=`$MYSQLDUMP --defaults-file=.access.cnf $db $x > "$BACKUP_DIR/$db/$x.sql"; >> mybk.log 2>&1`
		else
		    dump=`$MYSQLDUMP --defaults-file=.access.cnf --lock-tables=false $db $x > "$BACKUP_DIR/$db/$x.sql"; >> mybk.log 2>&1`
		fi

		while ! $dump; do
		    return 1
		done
	    fi
	done
    done
}

function tarCompress() {
    if ! `tar -cvf $TMP_DIR/$DATABASE-$TIMESTAMP.tar -C $BACKUP_DIR/ . > /dev/null`; then
	return 1
    fi
}

function sendToRemoteHost() {
    if [ "$COMPRESS" = true ]; then
	while ! `scp $TMP_DIR/$DATABASE-$TIMESTAMP.tar $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR`; do
	    return 1
	done
    else
	while ! `scp -r $BACKUP_DIR/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR`; do
	    return 1
	done
    fi
}

function delLocalBK() {
    if ! `rm -rfv $TMP_DIR/$DATABASE-$TIMESTAMP.tar $BACKUP_DIR >> mybk.log 2>&1`; then
	return 1
    fi
}
