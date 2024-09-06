FROM docker.io/ubuntu:24.04

ARG RMF_WEB_COMMIT="main"

# If we are building for deployment use with auth
ARG APP_CONFIG="app-config.json"
###################################################################

ENV CI=1

# install system deps and pnpm
RUN apt update && apt install -y \
    curl python3-pip python3-venv \
  && curl -fsSL https://get.pnpm.io/install.sh | bash -
ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH "$PNPM_HOME:$PATH"

# setup pnpm and install node
# this needs to be a separate step so that pnpm can be found
RUN pnpm config set unsafe-perm \
  && pnpm env use --global lts

# fetch sources
RUN mkdir -p /ws \
  && curl -L https://github.com/open-rmf/rmf-web/archive/$RMF_WEB_COMMIT.tar.gz -o rmf_web.tar.gz \
  && tar zxf rmf_web.tar.gz -C /ws --strip-components=1

# install deps
RUN cd /ws \
  && pnpm install --filter rmf-dashboard...

# copy in app config
COPY $APP_CONFIG /ws/packages/dashboard/app-config.json

# copy in dashoard resources
COPY dashboard_resources/* /ws/packages/dashboard/public/resources/

# build
RUN cd /ws/packages/dashboard \
  && pnpm run build

###

FROM docker.io/nginx:stable
COPY --from=0 --chown=root:nginx /ws/packages/dashboard/dist /usr/share/nginx/html/dashboard

COPY nginx.default.conf /etc/nginx/conf.d/default.conf
COPY 99-inject-env.sh /docker-entrypoint.d
