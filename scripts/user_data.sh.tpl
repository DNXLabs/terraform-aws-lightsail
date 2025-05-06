#!/bin/bash

DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASS="${db_password}"
DB_HOST="${db_host}"

echo $DB_NAME >> /tmp/vars
echo $DB_USER >> /tmp/vars
echo $DB_PASS >> /tmp/vars
echo $DB_HOST >> /tmp/vars

WP_CONFIG="/opt/bitnami/wordpress/wp-config.php"
echo $WP_CONFIG >> /tmp/vars

PHPMYADMIN_CONFIG="/opt/bitnami/phpmyadmin/config.inc.php"
echo $PHPMYADMIN_CONFIG >> /tmp/vars

sed -i "s/define( 'DB_NAME'.*/define( 'DB_NAME', '$${DB_NAME}' );/" $WP_CONFIG
sed -i "s/define( 'DB_USER'.*/define( 'DB_USER', '$${DB_USER}' );/" $WP_CONFIG
sed -i "s/define( 'DB_PASSWORD'.*/define( 'DB_PASSWORD', '$${DB_PASS}' );/" $WP_CONFIG
sed -i "s/define( 'DB_HOST'.*/define( 'DB_HOST', '$${DB_HOST}' );/" $WP_CONFIG

sed -i "s/\$cfg\['Servers'\]\[\$i\]\['host'\].*/\$cfg['Servers'][\$i]['host'] = '$${DB_HOST}';/" $PHPMYADMIN_CONFIG

sudo /opt/bitnami/ctlscript.sh restart