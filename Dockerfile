FROM ubuntu:trusty

ENV DEBIAN_FRONTEND noninteractive

RUN \
  apt-get update && \
  apt-get -y install mysql-server-5.6 --no-install-recommends && \
  apt-get -y clean && \
  apt-get -y autoclean && \
  rm -rf /var/lib/apt/lists/* 

RUN \
   ln -sf /dev/stderr /var/log/mysql/error.log && \
   sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf

COPY config.sh /

VOLUME ["/var/lib/mysql"]

EXPOSE 3306 

ENTRYPOINT ["/config.sh"]
