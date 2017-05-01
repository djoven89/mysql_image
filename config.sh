#!/bin/bash -x

unset DEBIAN_FRONTEND

/usr/sbin/mysqld &
DBID=$!

CONEX1=`mysqladmin -s --wait=20 -u root -h localhost ping | wc -l`
CONEX1=`mysqladmin -s --wait=20 -u root -p${MYSQL_ROOT_PASSWORD} -h localhost ping | wc -l`

if [ $CONEX -eq 0 ] && [ $CONEX1 -eq 0 ]
   then
      echo 'No se ha podido establecer conexión con la base de datos.'
      exit 1
fi

DBCHECK=`mysql -u root -p${MYSQL_ROOT_PASSWORD} -e 'show databases;' | wc -l`
DBROOT=0

if [ $MYSQL_ROOT_PASSWORD ] && [ $DBCHECK -eq 0 ]
  then
     mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}') ;"
		 DBROOT=1
	elif [ $MYSQL_ROOT_PASSWORD ] && [ $DBCHECK -gt 0 ]
		then
			echo 'Correcto'
		  DBROOT=1
  else
     echo 'Error al establecer la contraseña de root.'
     exit 1
fi

if [ $MYSQL_DATABASE ]
  then
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} ;"
  else
   echo 'Error al crear la base de datos.'
fi

DBUSER=`mysql -u root -p${MYSQL_ROOT_PASSORD} -e "select user from mysql.user where user='${MYSQL_USER}' ;" | wc -l `
if [ $DBROOT -eq 1 ] && [ $DBUSER -eq 0 ]
	then
  	 if [ $MYSQL_USER ] && [ $MYSQL_PASSWORD ] 
  		 then
     		 mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ; FLUSH PRIVILEGES ;"
   	 elif [ $MYSQL_USER ] 
       then
         mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER}' ; FLUSH PRIVILEGES ;"
	 	 fi
   else
     echo 'No se pudo crear el usuario.'
fi

wait $DBID 
