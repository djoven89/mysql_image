FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y install mysql-server-5.6 supervisor \
    && apt-get -y clean && apt-get -y autoclean \
    && rm -rf /var/lib/apt/lists/* 

RUN ln -sf /dev/stderr /var/log/mysql/error.log \
    && sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf

COPY script.sh /

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

VOLUME ["db_data"]

EXPOSE 3306 

ENTRYPOINT ["/usr/bin/supervisord"]
