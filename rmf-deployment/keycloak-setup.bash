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

: "${KEYCLOAK_ADMIN:=admin}"
: "${KEYCLOAK_ADMIN_PASSWD:=admin123}"
: "${ROOT_URL:=https://$1}"
KEYCLOAK_BASE_URL=$ROOT_URL/auth
TOKEN_WORKSPACE="deploy"
MASTER_TOKEN_URL="$KEYCLOAK_BASE_URL/realms/master/protocol/openid-connect/token"
REALM_URL="$KEYCLOAK_BASE_URL/$KEYCLOAK_ADMIN/realms"
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

__msg_info "Creating Realm rmf-web"
REALM_CREATION_RESPONSE=$(curl -k -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    -d '{"id":"rmf-web","realm":"rmf-web","enabled":"true"}' \
    "$REALM_URL")

__msg_debug "$REALM_CREATION_RESPONSE"

__msg_info "Creating Clients."
DASHBOARD_CLIENT_REQUEST_JSON=$(
    jq -n \
        --arg rootUrl "$ROOT_URL" \
        --arg redirectRootUrl "$ROOT_URL/*" \
        '{"clientId":"dashboard","rootUrl":$rootUrl,"redirectUris":[$redirectRootUrl],"webOrigins":[$rootUrl],publicClient:"true"}'
)

CLIENT_DASHBOARD_CREATION_RESPONSE=$(curl -k -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    -d "$DASHBOARD_CLIENT_REQUEST_JSON" \
    "$REALM_CLIENT_URL")

__msg_debug "$CLIENT_DASHBOARD_CREATION_RESPONSE"

REPORTING_CLIENT_REQUEST_JSON=$(
    jq -n \
        --arg rootUrl "$ROOT_URL" \
        --arg redirectRootUrl "$ROOT_URL/*" \
        '{"clientId":"reporting","rootUrl":$rootUrl,"redirectUris":[$redirectRootUrl],"webOrigins":[$rootUrl],publicClient:"true"}'
)

CLIENT_REPORTING_CREATION_RESPONSE=$(curl -k -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    -d "$REPORTING_CLIENT_REQUEST_JSON" \
    "$REALM_CLIENT_URL")

__msg_debug "$CLIENT_REPORTING_CREATION_RESPONSE"

ADMIN_USER_ID=$(curl -k -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    "$REALM_USERS_URL?username=admin" | jq -r ".[0].id") 

if [ "$ADMIN_USER_ID" != "null" ]; then
    __msg_debug "admin user already created. Skipping."
else
    __msg_info "Creating Admin User."
    ADMIN_USER_CREATION_RESPONSE=$(curl -k -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
        -d '{"username":"admin","enabled":"true"}' \
        "$REALM_USERS_URL")
    __msg_debug "$ADMIN_USER_CREATION_RESPONSE"

    ADMIN_USER_ID=$(curl -k -s -X GET \
        -H "content-type: application/json" \
        -H "authorization: bearer $TOKEN_REQUEST_RESPONSE" \
        "$REALM_USERS_URL?username=admin" | jq -r '.[0].id')

    curl -k -s -X PUT \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
        -d '{"value": "admin", "temporary": "false"}' \
        "$REALM_USERS_URL/$ADMIN_USER_ID/reset-password" || __error_exit $LINENO "Something went wrong resetting admin password."
    __msg_info "Admin user created with password 'admin'"
fi

EXAMPLE_USER_ID=$(curl -k -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    "$REALM_USERS_URL?username=example" | jq -r ".[0].id") 

if [ "$EXAMPLE_USER_ID" != "null" ]; then
    __msg_debug "example user already created. Skipping."
else
    __msg_info "Creating example User."
    EXAMPLE_USER_CREATION_RESPONSE=$(curl -k -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
        -d '{"username":"example","enabled":"true"}' \
        "$REALM_USERS_URL")
    __msg_debug "$EXAMPLE_USER_CREATION_RESPONSE"

    EXAMPLE_USER_ID=$(curl -k -s -X GET \
        -H "content-type: application/json" \
        -H "authorization: bearer $TOKEN_REQUEST_RESPONSE" \
        "$REALM_USERS_URL?username=example" | jq -r '.[0].id')

    curl -k -s -X PUT \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
        -d '{"value": "example", "temporary": "false"}' \
        "$REALM_USERS_URL/$EXAMPLE_USER_ID/reset-password" || __error_exit $LINENO "Something went wrong resetting example user password."
    __msg_info "example user created with password 'example'"
fi

curl -k -s -X PUT \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    -d '{"eventsEnabled": "true", "eventsListeners": ["jsonlog_event_listener"]}' \
    "$REALM_EVENTS_URL/config" 

__msg_info "Creating Client Scopes."
DASHBOARD_CLIENT_SCOPE_CREATION_RESPONSE=$(curl -k -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    --data-binary @- << EOF "$REALM_CLIENT_SCOPES_URL"
{
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
}
EOF
)

__msg_debug "$DASHBOARD_CLIENT_SCOPE_CREATION_RESPONSE"

REPORTING_CLIENT_SCOPE_CREATION_RESPONSE=$(curl -k -s -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    --data-binary @- << EOF "$REALM_CLIENT_SCOPES_URL"
{
  "name": "reporting",
  "protocol": "openid-connect",
  "description": "reporting scope",
  "protocolMappers": [
    {
      "name": "rmf-audience",
      "protocol": "openid-connect",
      "protocolMapper": "oidc-audience-mapper",
      "config": {
        "access.token.claim": "true",
        "id.token.claim": "false",
        "included.client.audience": "reporting"
      }
    }
  ]
}
EOF
)

__msg_debug "$REPORTING_CLIENT_SCOPE_CREATION_RESPONSE"

__msg_info "Linking up Client Scopes and Clients."
ALL_CLIENTS_JSON=$(curl -k -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    "$REALM_CLIENT_URL") 

DASHBOARD_CLIENT_ID=$(echo "$ALL_CLIENTS_JSON" | jq -r '.[] | select ( .clientId == "dashboard" )' | jq -r '.id')
REPORTING_CLIENT_ID=$(echo "$ALL_CLIENTS_JSON" | jq -r '.[] | select ( .clientId == "reporting" )' | jq -r '.id')

ALL_CLIENT_SCOPES_JSON=$(curl -k -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    "$REALM_CLIENT_SCOPES_URL") 

DASHBOARD_CLIENT_SCOPES_ID=$(echo "$ALL_CLIENT_SCOPES_JSON" | jq -r '.[] | select ( .name == "dashboard" )' | jq -r '.id')
REPORTING_CLIENT_SCOPES_ID=$(echo "$ALL_CLIENT_SCOPES_JSON" | jq -r '.[] | select ( .name == "reporting" )' | jq -r '.id')

[ -n "$DASHBOARD_CLIENT_SCOPES_ID" ] || __error_exit $LINENO "Something went wrong retrieving the dashboard client id."
[ -n "$REPORTING_CLIENT_SCOPES_ID" ] || __error_exit $LINENO "Something went wrong retrieving the reporting client id."

curl -k -s -X PUT \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    -d '{"value": "admin", "temporary": "false"}' \
    "$REALM_CLIENT_URL/$DASHBOARD_CLIENT_ID/default-client-scopes/$DASHBOARD_CLIENT_SCOPES_ID" || \
        __error_exit $LINENO "Something went wrong assigning the dashboard client scope."

curl -k -s -X PUT \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
    -d '{"value": "admin", "temporary": "false"}' \
    "$REALM_CLIENT_URL/$REPORTING_CLIENT_ID/default-client-scopes/$REPORTING_CLIENT_SCOPES_ID" || \
        __error_exit $LINENO "Something went wrong assigning the reporting client scope."

JWKS_URI=$(curl -k -s -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
  "$KEYCLOAK_BASE_URL/realms/rmf-web/.well-known/openid-configuration" | jq -r '.jwks_uri')

JWKS_X5C=$(curl -k -s -X GET \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_REQUEST_RESPONSE" \
  "$JWKS_URI" | jq -r '.keys[0].x5c[0]')

[ -n "$JWKS_X5C" ] || __error_exit $LINENO "Something went wrong trying to retrieve Certificate."

PEM_FILE="-----BEGIN CERTIFICATE-----
$JWKS_X5C
-----END CERTIFICATE-----"
echo "$PEM_FILE" > /tmp/cert.pem
openssl x509 -pubkey -noout -in /tmp/cert.pem  > /tmp/jwt-pub-key.pub

echo "jwt-pub-key"
echo /tmp/jwt-pub-key.pub

echo "uploading pubkey to kubernetes, may not be necessary if you are not using k8s"
kubectl create configmap jwt-pub-key --from-file=/tmp/jwt-pub-key.pub -o=yaml --dry-run=client | kubectl apply -n $TOKEN_WORKSPACE -f -

