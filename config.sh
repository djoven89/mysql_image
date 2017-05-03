#!/bin/bash -x

unset DEBIAN_FRONTEND

/usr/sbin/mysqld &
DBID=$!

CONEX=`mysqladmin -s --wait=20 -u root -h localhost ping | wc -l`
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
		 echo 'Contraseña de root establecida.'
		 DBROOT=1
	elif [ $MYSQL_ROOT_PASSWORD ] && [ $DBCHECK -gt 0 ]
		then
			echo 'Root ya tenía contraseña'
		  DBROOT=1
  else
     echo 'Error al establecer la contraseña de root.'
     exit 1
fi

if [ $MYSQL_DATABASE ] && [ $DBCHECK -eq 0 ]
  then
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} ;"
		echo 'Tabla creada correctamente.'

		elif [ $MYSQL_DATABASE ] && [ $DBCHECK -gt 0 ] 
			then
				echo 'Ya exista la base de datos.'
  else
    echo 'Error al crear la base de datos.'
fi

DBUSER=`mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "select user from mysql.user where user='${MYSQL_USER}' ;" | wc -l `
if [ $DBUSER -eq 0 ] && [ $DBROOT -eq 1 ]
	then
  	 if [ $MYSQL_USER ] && [ $MYSQL_PASSWORD ] 
  		 then
     		 mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ; FLUSH PRIVILEGES ;"
				 echo 'Usuario con su contraseña creada.'
   	 elif [ $MYSQL_USER ] 
       then
         mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER}' ; FLUSH PRIVILEGES ;"
				 echo 'Usuario con contraseña por defecto creado.'
	 	 fi
   else
     echo 'El usuario ya existe.'
fi

wait $DBID
