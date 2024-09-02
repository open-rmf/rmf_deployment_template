#!/usr/bin/bash
set -e

sed -i "s,__RMF_SERVER_URL__,${RMF_SERVER_URL},g" /usr/share/nginx/html/dashboard/index.html
sed -i "s,__TRAJECTORY_SERVER_URL__,${TRAJECTORY_SERVER_URL},g" /usr/share/nginx/html/dashboard/index.html
sed -i "s,__AUTH_PROVIDER__,${AUTH_PROVIDER},g" /usr/share/nginx/html/dashboard/index.html
sed -i "s,__KEYCLOAK_URL__,${KEYCLOAK_URL},g" /usr/share/nginx/html/dashboard/index.html
sed -i "s,__REALM__,${REALM},g" /usr/share/nginx/html/dashboard/index.html
sed -i "s,__CLIENT_ID__,${CLIENT_ID},g" /usr/share/nginx/html/dashboard/index.html

