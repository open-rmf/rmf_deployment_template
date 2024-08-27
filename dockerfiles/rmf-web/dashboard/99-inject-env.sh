#!/usr/bin/bash
set -e

sed -i "s,__RMF_SERVER_URL__,${RMF_SERVER_URL},g" /usr/share/nginx/html/dashboard/index.html
sed -i "s,__TRAJECTORY_SERVER_URL__,${TRAJECTORY_SERVER_URL},g" /usr/share/nginx/html/dashboard/index.html
sed -i "s,__KEYCLOAK_URL__,${KEYCLOAK_URL},g" /usr/share/nginx/html/dashboard/index.html
