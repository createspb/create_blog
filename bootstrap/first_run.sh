
exec >> /var/log/first_run.sh.log 2>&1
set -x

pre_start_action() {

  echo "Initializing MySQL at $DATA_DIR"

  # Copy the data that we generated within the container to the empty DATA_DIR.
  cp -R /var/lib/mysql/* $DATA_DIR

  # Ensure postgres owns the DATA_DIR
  chown -R mysql $DATA_DIR
  # Ensure we have the right permissions set on the DATA_DIR
  chmod -R 755 $DATA_DIR
}

post_start_action() {

    mkdir /mysql
    MYSQL_PASSWORD=`pwgen -c -n -1 12` # genereate new pass
    echo MYSQL_PASSWORD > /mysql/root_pass
    MYSQL_PASSWORD=$(cat /mysql/root_pass)

    WORDPRESS_DB="wordpress"
    WORDPRESS_PASSWORD=`pwgen -c -n -1 12`
    echo $WORDPRESS_PASSWORD > /mysql/wordpress_pass

    sed -e "s/database_name_here/$WORDPRESS_DB/
    s/username_here/$WORDPRESS_DB/
    s/password_here/$WORDPRESS_PASSWORD/
    /'AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'SECURE_AUTH_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'LOGGED_IN_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'NONCE_KEY'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'SECURE_AUTH_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'LOGGED_IN_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/
    /'NONCE_SALT'/s/put your unique phrase here/`pwgen -c -n -1 65`/" /var/www/wordpress/wp-config-sample.php > /var/www/wordpress/wp-config.php

    mysqladmin -u root password $MYSQL_PASSWORD
    mysql -uroot -p$MYSQL_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES;"
    mysql -uroot -p$MYSQL_PASSWORD -e "CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost' IDENTIFIED BY '$WORDPRESS_PASSWORD'; FLUSH PRIVILEGES;"
}