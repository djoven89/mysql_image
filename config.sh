#!/bin/bash -x

unset DEBIAN_FRONTEND

/usr/sbin/mysqld &
DBID=$!

CONEX=`mysqladmin -s --wait=20 -u root -h localhost ping | wc -l`

if [ $CONEX -eq 0 ]
  then
     echo 'No se ha podido establecer conexión con la base de datos.'
     exit 1
fi

if [ $MYSQL_ROOT_PASSWORD ]
  then
     mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}') ;"
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

if [ $MYSQL_USER ] && [ $MYSQL_PASSWORD ]
  then
     mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ; FLUSH PRIVILEGES ;"
  elif [ $MYSQL_USER ] 
     then
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER}' ; FLUSH PRIVILEGES ;"
  else
        echo 'No se pudo crear el usuario.'
fi

wait $DBID
