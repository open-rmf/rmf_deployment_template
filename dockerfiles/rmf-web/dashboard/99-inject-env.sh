#!/usr/bin/bash
set -e

INDEX_HTML="/usr/share/nginx/html/dashboard/index.html"

sed -i "s,__RMF_SERVER_URL__,${RMF_SERVER_URL},g" ${INDEX_HTML}
sed -i "s,__TRAJECTORY_SERVER_URL__,${TRAJECTORY_SERVER_URL},g" ${INDEX_HTML}
sed -i "s,__KEYCLOAK_URL__,${KEYCLOAK_URL},g" ${INDEX_HTML}
