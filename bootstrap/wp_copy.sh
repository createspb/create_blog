#!/usr/bin/env bash

# cp wordpress if the dir is empty
if [[ ! "$(ls -A /var/www/wordpress)" ]]; then
  cp -r /var/www/wordpress.orig/* /var/www/wordpress
  chown -R www-data:www-data /var/www/wordpress
fi
