# Wordpress on nginx/phpfpm/baseimage

A single container to run wordpress blog and persist its data.


# Run it

Just run and attach it to your load balancer.

    docker run -p 80 -v /home/docker/mysql:/data -v /home/docker/wp:/var/www/wordpress createspb/blog

On the first run a database and a WP will be copied over the directories you provided as volume mount points.