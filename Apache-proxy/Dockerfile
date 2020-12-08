FROM centos:7

EXPOSE 8080

RUN yum install yum-utils wget httpd -y

RUN yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
 && yum-config-manager --enable remi-php73 \
 && yum install -y epel-release \
 && yum install -y php php-zip php-gd php-intl php-mbstring php-soap php-xmlrpc php-pgsql \
      php-opcache php-mysqli \
 && yum clean all \
 && wget https://wordpress.org/latest.tar.gz \
 && tar -xzf latest.tar.gz -C /var/  \
 && rm -f latest.tar.gz \
 && mv -f /var/wordpress/* /var/www/html \
 && chown -R apache:apache /var/www/html \
 && chmod 775 /var/www/html -R  \
 && sed -i 's/80/8080/g' /etc/httpd/conf/httpd.conf \
 && wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O /usr/local/bin/cloud_sql_proxy \ 
 && chmod +x /usr/local/bin/cloud_sql_proxy

COPY cloud-run-entrypoint.sh /usr/local/bin/
RUN chmod 777 /usr/local/bin/cloud-run-entrypoint.sh
      
COPY wp-config.php /var/www/html/wp-config.php

ENTRYPOINT ["cloud-run-entrypoint.sh"]

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

