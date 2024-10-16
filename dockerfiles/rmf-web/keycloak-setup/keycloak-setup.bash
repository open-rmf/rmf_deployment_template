#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

export PROJECT=keycloak-setup
SCRIPTPATH="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. "$SCRIPTPATH/utils.bash"

echo "Waiting for keycloak to be up"
kubectl wait --for=condition=Available deployments/keycloak --timeout=60s

: "${KEYCLOAK_ADMIN:=admin}"
: "${KEYCLOAK_ADMIN_PASSWD=$(kubectl get secrets/keycloak-secret --template '{{.data.KEYCLOAK_ADMIN_PASSWORD}}' | base64 -dw0)}"
ROOT_URL="$1"
: "${KEYCLOAK_BASE_URL="http://keycloak:8080/auth"}"
MASTER_TOKEN_URL="$KEYCLOAK_BASE_URL/realms/master/protocol/openid-connect/token"
REALM_URL="$KEYCLOAK_BASE_URL/admin/realms"
REALM_CLIENT_URL="$REALM_URL/rmf-web/clients"
REALM_USERS_URL="$REALM_URL/rmf-web/users"
REALM_EVENTS_URL="$REALM_URL/rmf-web/events"
REALM_CLIENT_SCOPES_URL="$REALM_URL/rmf-web/client-scopes"

command -v jq >>/dev/null || { __msg_info "Install jq dependency.." && sudo apt install jq; }

__msg_info "Retrieving JWT Token"

TOKEN_REQUEST_RESPONSE=$(
    curl -k -s -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "username=$KEYCLOAK_ADMIN" \
        -d "password=$KEYCLOAK_ADMIN_PASSWD" \
        -d "grant_type=password" \
        -d "client_id=admin-cli" \
        "$MASTER_TOKEN_URL" |
        jq -r '.access_token'
) || __error_exit $LINENO "Is Keycloak up?"

[ "$TOKEN_REQUEST_RESPONSE" != "null" ] || __error_exit $LINENO "Something went wrong retrieving JWT Token. Check credentials"

kc_api() {
    local resp
    resp=$(curl -ks --fail-with-body \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
        "$@") && exit_code=0 || exit_code=$?
    if [[ $exit_code != 0 ]]; then
        __msg_error "$resp"
        return $exit_code
    else
        __msg_debug "$resp"
    fi
    echo "$resp"
}

__msg_info "Updating rmf-web realm"
REALM_DATA='{"id":"rmf-web","realm":"rmf-web","enabled":"true","ssoSessionMaxLifespan":86400}'
# try to update the realm if it already exists, else create it
REALM_CREATION_RESPONSE=$(kc_api -X PUT \
    -d "$REALM_DATA" \
    "$REALM_URL/rmf-web") && exit_code=0 || exit_code=$?
if [[ $exit_code != 0 ]]; then
    __msg_info "Creating realm rmf-web"
    REALM_CREATION_RESPONSE=$(kc_api -X POST \
        -d "$REALM_DATA" \
        "$REALM_URL") && exit_code=0 || exit_code=$?
    if [[ $exit_code != 0 ]]; then
        __error_exit $LINENO "Failed to create realm"
    fi
    __msg_info "Realm rmf-web created"
else
    __msg_info "Updated rmf-web realm"
fi

__msg_info "Creating Clients."
DASHBOARD_CLIENT_REQUEST_JSON=$(
    jq -n \
        --arg rootUrl "$ROOT_URL" \
        --arg redirectRootUrl "$ROOT_URL/*" \
        '{"clientId":"dashboard","rootUrl":$rootUrl,"redirectUris":[$redirectRootUrl],"webOrigins":[$rootUrl],"publicClient":true}'
)

DASHBOARD_CLIENT_ID=$(kc_api -X GET \
    "$REALM_CLIENT_URL?clientId=dashboard" | jq -r '.[0].id')
if [[ $DASHBOARD_CLIENT_ID == "null" ]]; then
    __msg_info "creating dashboard client"
    CLIENT_DASHBOARD_CREATION_RESPONSE=$(kc_api -X POST \
        -d "$DASHBOARD_CLIENT_REQUEST_JSON" \
        "$REALM_CLIENT_URL") || __error_exit $LINENO "Failed to create dashboard client"
    DASHBOARD_CLIENT_ID=$(kc_api -X GET \
        "$REALM_CLIENT_URL?clientId=dashboard" | jq -r '.[0].id')
    __msg_info "dashboard client created"
else
    __msg_info "dashboard client already exists. Updating instead."
    CLIENT_DASHBOARD_CREATION_RESPONSE=$(kc_api -X PUT \
        -d "$DASHBOARD_CLIENT_REQUEST_JSON" \
        "$REALM_CLIENT_URL/$DASHBOARD_CLIENT_ID") || __error_exit $LINENO "Failed to update dashboard client"
    __msg_info "dashboard client updated"
fi

SMART_CART_CLIENT_REQUEST_JSON='{
  "clientId":"smart_cart",
  "name":"Smart Cart",
  "description":"Private client for smart carts",
  "publicClient":false,
  "serviceAccountsEnabled":true,
  "attributes": {
    "access.token.lifespan": 86400
  }
}'

SMART_CART_CLIENT_ID=$(kc_api -X GET \
    "$REALM_CLIENT_URL?clientId=smart_cart" | jq -r '.[0].id')
if [[ $SMART_CART_CLIENT_ID == "null" ]]; then
    __msg_info "creating smart_cart client"
    CLIENT_SMART_CART_CREATION_RESPONSE=$(kc_api -X POST \
        -d "$SMART_CART_CLIENT_REQUEST_JSON" \
        "$REALM_CLIENT_URL") || __error_exit $LINENO "Failed to create smart_cart client"
    SMART_CART_CLIENT_ID=$(kc_api -X GET \
        "$REALM_CLIENT_URL?clientId=smart_cart" | jq -r '.[0].id')
    __msg_info "smart_cart client created"
else
    __msg_info "smart_cart client already exists. Updating instead."
    CLIENT_SMART_CART_CREATION_RESPONSE=$(kc_api -X PUT \
        -d "$SMART_CART_CLIENT_REQUEST_JSON" \
        "$REALM_CLIENT_URL/$SMART_CART_CLIENT_ID") || __error_exit $LINENO "Failed to update smart_cart client"
    __msg_info "smart_cart client updated"
fi

__msg_info "Updating smart_cart service account"
SMART_CART_SA_ID=$(kc_api -X GET "$REALM_USERS_URL?username=service-account-smart_cart" | jq -r '.[0].id')
REALM_MANAGEMENT_CLIENT_ID=$(kc_api -X GET "$REALM_CLIENT_URL?clientId=realm-management" | jq -r '.[0].id')
ROLE_ID=$(kc_api -X GET "$REALM_CLIENT_URL/$REALM_MANAGEMENT_CLIENT_ID/roles?search=view-users" | jq -r '.[0].id') || __error_exit $LINENO "Failed to get role id"
kc_api -X POST \
    -d '[{"id":"'$ROLE_ID'","name":"view-users","description":"${role_view-users}","composite":true,"clientRole":true,"containerId":"'$REALM_MANAGEMENT_CLIENT_ID'"}]' \
    "$REALM_USERS_URL/$SMART_CART_SA_ID/role-mappings/clients/$REALM_MANAGEMENT_CLIENT_ID" || __error_exit $LINENO "Failed to assign role to service account"

ADMIN_USER_ID=$(kc_api -X GET \
    "$REALM_USERS_URL?username=admin" | jq -r ".[0].id") 

if [ "$ADMIN_USER_ID" == "null" ]; then
    __msg_info "Creating Admin User."
    ADMIN_USER_CREATION_RESPONSE=$(kc_api -X POST \
        -d '{"username":"admin","enabled":"true"}' \
        "$REALM_USERS_URL") || __error_exit $LINENO "Failed to create admin user"
    ADMIN_USER_ID=$(kc_api -X GET \
        "$REALM_USERS_URL?username=admin" | jq -r ".[0].id") 
    __msg_info "Admin user created"
else
    __msg_debug "Admin user already created. Skipping."
fi

__msg_info "Resetting admin user password"
ADMIN_USER_PASSWORD=$(kubectl get secrets/rmf-web-rmf-server-secret --template '{{.data.ADMIN_PASSWD}}' | base64 -dw0)
RESET_PASSWORD_RESPONSE=$(kc_api -X PUT \
    -d '{"value": "'$ADMIN_USER_PASSWORD'", "temporary": "false"}' \
    "$REALM_USERS_URL/$ADMIN_USER_ID/reset-password") || __error_exit $LINENO "Something went wrong resetting admin password."
__msg_info "Admin user updated"

__msg_info "Enabling logging."
kc_api -X PUT \
    -d '{"eventsEnabled": "true", "eventsListeners": ["jsonlog_event_listener"]}' \
    "$REALM_EVENTS_URL/config" 

__msg_info "Creating Client Scopes."
DASHBOARD_CLIENT_SCOPE_DATA='{
  "name": "dashboard",
  "protocol": "openid-connect",
  "description": "dashboard scope",
  "protocolMappers": [
    {
      "name": "rmf-audience",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-audience-mapper",
      "config": {
        "access.token.claim": "true",
        "id.token.claim": "false",
        "included.client.audience": "dashboard"
      }
    }
  ]
}'
DASHBOARD_CLIENT_SCOPE_ID=$(kc_api -X GET \
    "$REALM_CLIENT_SCOPES_URL" | jq -r '.[] | select ( .name == "dashboard" ) | .id')
if [[ $DASHBOARD_CLIENT_SCOPE_ID != "" ]]; then
    # delete and recreate because PUT does not update the protocol mappers
    __msg_warn "deleting existing dashboard client scope"
    DASHBOARD_CLIENT_SCOPE_CREATION_RESPONSE=$(kc_api -X DELETE \
        --data-raw "$DASHBOARD_CLIENT_SCOPE_DATA" \
        "$REALM_CLIENT_SCOPES_URL/$DASHBOARD_CLIENT_SCOPE_ID") || __error_exit $LINENO "Failed to delete dashboard client scope"
    __msg_warn "deleted dashboard client scope"
fi
__msg_info "creating dashboard client scope"
DASHBOARD_CLIENT_SCOPE_CREATION_RESPONSE=$(kc_api -X POST \
    --data-raw "$DASHBOARD_CLIENT_SCOPE_DATA" \
    "$REALM_CLIENT_SCOPES_URL") || __error_exit $LINENO "Failed to create dashboard client scope"
DASHBOARD_CLIENT_SCOPE_ID=$(kc_api -X GET \
    "$REALM_CLIENT_SCOPES_URL" | jq -r '.[] | select ( .name == "dashboard" ) | .id')
__msg_info "dashboard client scope created"

__msg_info "Linking up Client Scopes and Clients."

kc_api -X PUT \
    -d '{"value": "admin", "temporary": "false"}' \
    "$REALM_CLIENT_URL/$DASHBOARD_CLIENT_ID/default-client-scopes/$DASHBOARD_CLIENT_SCOPE_ID" || \
        __error_exit $LINENO "Something went wrong assigning the dashboard client scope."

kc_api -X PUT \
    -d '{"value": "admin", "temporary": "false"}' \
    "$REALM_CLIENT_URL/$SMART_CART_CLIENT_ID/default-client-scopes/$DASHBOARD_CLIENT_SCOPE_ID" || \
        __error_exit $LINENO "Something went wrong assigning the smart cart client scope."

__msg_info "Fetching token public key"

JWKS_URI=$(curl -k -s -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
  "$KEYCLOAK_BASE_URL/realms/rmf-web/.well-known/openid-configuration" | jq -r '.jwks_uri')
__msg_debug "JWKS_URL=$JWKS_URI"

JWKS_X5C=$(curl -k -s -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
  "$JWKS_URI" | jq -r '[ .keys[] | select(.use == "sig") ][0].x5c[0]')
__msg_debug "JWKS_X5C=$JWKS_X5C"

[ -n "$JWKS_X5C" ] || __error_exit $LINENO "Something went wrong trying to retrieve Certificate."

PEM_FILE="-----BEGIN CERTIFICATE-----
$JWKS_X5C
-----END CERTIFICATE-----"
PUB_KEY=$(echo "$PEM_FILE" | openssl x509 -pubkey -noout)
__msg_debug "PUB_KEY=$PUB_KEY"

echo "uploading pubkey to kubernetes"
kubectl create configmap jwt-pub-key --from-literal=jwt-pub-key.pub="$PUB_KEY" -o=yaml --dry-run=client | kubectl apply -f -
