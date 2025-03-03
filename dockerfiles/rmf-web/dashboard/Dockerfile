FROM docker.io/ubuntu:24.04

ARG RMF_WEB_COMMIT="main"

# If we are building for deployment use with auth, otherwise "local"
ARG DASHBOARD_DIRECTORY="with_auth"
###################################################################

ENV CI=1

# install system deps and pnpm
RUN apt update && apt install -y \
    curl python3-pip python3-venv \
  && curl -fsSL https://get.pnpm.io/install.sh | bash -
ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH "$PNPM_HOME:$PATH"
RUN pnpm env use --global lts

# fetch sources
RUN mkdir -p /ws \
  && curl -L https://github.com/open-rmf/rmf-web/archive/$RMF_WEB_COMMIT.tar.gz -o rmf_web.tar.gz \
  && tar zxf rmf_web.tar.gz -C /ws --strip-components=1

# install deps
RUN cd /ws \
  && pnpm install --filter rmf-dashboard-framework...

# copy in the dashboard main files
RUN mkdir -p /ws/packages/rmf-dashboard-framework/examples/target
COPY $DASHBOARD_DIRECTORY/* /ws/packages/rmf-dashboard-framework/examples/target/

# copy in dashoard resources
COPY dashboard_resources/* /ws/packages/rmf-dashboard-framework/examples/shared/public/resources/

# replace vite.config.ts to include base
COPY vite.config.ts /ws/packages/rmf-dashboard-framework/examples/shared/vite.config.ts

# build
RUN cd /ws/packages/rmf-dashboard-framework \
  && pnpm run build:example examples/target

###

FROM docker.io/nginx:stable
COPY --from=0 --chown=root:nginx /ws/packages/rmf-dashboard-framework/examples/target/dist /usr/share/nginx/html/dashboard

COPY nginx.default.conf /etc/nginx/conf.d/default.conf
COPY 99-inject-env.sh /docker-entrypoint.d
