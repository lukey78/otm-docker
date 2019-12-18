#!/bin/sh
set -e

if [ ! -d "/var/lib/postgresql/10/main" ]; then
  pg_dropcluster 10 main
  mkdir -p /var/lib/postgresql
  chown -R postgres /var/lib/postgresql
  pg_createcluster 10 main

  /etc/init.d/postgresql start
fi

if [ ! -d "/mnt/tiles" ]; then
  mkdir -p /mnt/tiles/opentopomap
  mkdir -p /mnt/tiles/example
  chmod -R 777 /mnt/tiles
fi

/etc/init.d/postgresql start
/etc/init.d/rsyslog start
/etc/init.d/tirex-backend-manager start
/etc/init.d/tirex-master start
/etc/init.d/ssh start

sed -i 's/$SERVER_NAME/'"$DOMAIN"'/g' /etc/apache2/sites-available/tileserver_site.conf
sed -i 's/$WHITELIST/'"$WHITELIST"'/g' /etc/apache2/sites-available/tileserver_site.conf

# start the letsencrypt bot to obtain certificate
#certbot -n --apache --cert-name mapserver --redirect --agree-tos --email $EMAIL --domain $DOMAIN

apachectl stop
sleep 10
apachectl -DFOREGROUND
