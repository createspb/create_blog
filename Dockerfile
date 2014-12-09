FROM createdigitalspb/docker-baseimage

MAINTAINER Vladimir Shulyak <vladimir@shulyak.net>


# commons
RUN add-apt-repository -y ppa:nginx/stable
RUN apt-get update -qy
RUN apt-get install -qy wget unzip software-properties-common php5-cli php5-fpm php5-mysql php5-gd php5-mcrypt php5-intl\
    nginx mysql-server-5.5 mysql-client-5.5 pwgen inotify-tools


# configure php
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/fpm/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini


# configure nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
RUN sed -i "s/;catch_workers_output = yes/catch_workers_output = yes/" /etc/php5/fpm/pool.d/www.conf


# www & confs
RUN mkdir             /var/www
ADD conf/wordpress    /etc/nginx/sites-available/default
ADD bootstrap         /usr/bin
RUN chmod +x -R       /usr/bin


# wp
ADD https://github.com/WordPress/WordPress/archive/4.0.zip /var/tmp/4.0.zip
RUN unzip 4.0.zip
RUN cp -r WordPress-4.0 /var/www/wordpress
RUN cp -r WordPress-4.0 /var/www/wordpress.orig # backup for volume
RUN chown -R www-data:www-data /var/www/wordpress/


# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf


# bootstrap
ADD bootstrap/wp_copy.sh /etc/my_init.d/wp_copy.sh
RUN chmod +x /etc/my_init.d/wp_copy.sh


# init
ADD init        /etc/service
RUN chmod +x -R /etc/service


EXPOSE 80 3306

VOLUME ["/var/log", "/data", "/var/www/wordpress"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*