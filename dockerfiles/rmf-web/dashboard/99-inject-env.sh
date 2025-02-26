#!/usr/bin/bash
set -e

TARGET_FILES="/usr/share/nginx/html/dashboard/assets/*"

sed -i "s,__RMF_SERVER_URL__,${RMF_SERVER_URL},g" ${TARGET_FILES}
sed -i "s,__TRAJECTORY_SERVER_URL__,${TRAJECTORY_SERVER_URL},g" ${TARGET_FILES}
sed -i "s,__KEYCLOAK_URL__,${KEYCLOAK_URL},g" ${TARGET_FILES}
