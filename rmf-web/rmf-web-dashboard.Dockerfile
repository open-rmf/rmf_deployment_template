ARG BUILDER_NS="open-rmf/rmf_deployment_template"
ARG BASE_REGISTRY="docker.io"

###################################################################
FROM $BUILDER_NS/builder-rmf-web
ARG DOMAIN_URL="rmf-deployment-template.open-rmf.org"

SHELL ["bash", "-c"]

RUN mkdir /opt/rmf/src/rmf-web/packages/dashboard/src/assets/resources
COPY rmf-web/dashboard_resources/* /opt/rmf/src/rmf-web/packages/dashboard/src/assets/resources/

RUN . /opt/rmf/install/setup.bash 

WORKDIR /opt/rmf/src/rmf-web

ENV PUBLIC_URL="/dashboard"
ENV REACT_APP_TRAJECTORY_SERVER="wss://${DOMAIN_URL}/trajectory"
ENV REACT_APP_RMF_SERVER="https://${DOMAIN_URL}/rmf/api/v1"
ENV REACT_APP_AUTH_PROVIDER="keycloak"
ENV REACT_APP_KEYCLOAK_CONFIG='{"realm": "rmf-web", "clientId": "dashboard", "url" : "https://'${DOMAIN_URL}'/auth"}'

RUN echo "DOMAIN_URL: $DOMAIN_URL"\ 
    && echo "REACT_APP_TRAJECTORY_SERVER: $REACT_APP_TRAJECTORY_SERVER"\
    && echo "REACT_APP_RMF_SERVER: $REACT_APP_RMF_SERVER"\
    && echo "REACT_APP_AUTH_PROVIDER: $REACT_APP_AUTH_PROVIDER"\
    && echo "REACT_APP_KEYCLOAK_CONFIG: $REACT_APP_KEYCLOAK_CONFIG"

RUN cd /opt/rmf/src/rmf-web/packages/dashboard && npm run build

###
FROM $BASE_REGISTRY/nginx:stable 
COPY --from=0 /opt/rmf/src/rmf-web/packages/dashboard/build /usr/share/nginx/html/dashboard

SHELL ["bash", "-c"]
RUN echo -e 'server {\n\
  listen 80;\n\
  server_name localhost;\n\
\n\
  location / {\n\
    root /usr/share/nginx/html;\n\
    index index.html index.htm;\n\
    try_files $uri /dashboard/index.html;\n\
  }\n\
\n\
  error_page 500 502 503 504 /50x.html;\n\
  location = /50x.html {\n\
    root /usr/share/nginx/html;\n\
  }\n\
}\n' > /etc/nginx/conf.d/default.conf
