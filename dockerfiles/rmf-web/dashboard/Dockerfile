FROM docker.io/ubuntu:24.04

ARG RMF_WEB_COMMIT="main"

# If we are building for deployment use with auth, otherwise "local"
ARG DASHBOARD_DIRECTORY="local"
###################################################################

ENV CI=1

# install system deps and pnpm
RUN apt update && apt install -y \
    curl python3-pip python3-venv \
  && curl -fsSL https://get.pnpm.io/install.sh | bash -
ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH "$PNPM_HOME:$PATH"
RUN pnpm env use --global lts

# setup dashboard
RUN mkdir -p /ws/dashboard/rmf-web
COPY $DASHBOARD_DIRECTORY/* /ws/dashboard
RUN cd /ws/dashboard \
  && curl -L https://github.com/open-rmf/rmf-web/archive/$RMF_WEB_COMMIT.tar.gz -o rmf_web.tar.gz \
  && tar zxf rmf_web.tar.gz -C /ws/dashboard/rmf-web --strip-components=1
RUN cd /ws/dashboard/rmf-web \
  && pnpm install --filter=rmf-dashboard-framework... \
  && pnpm --filter=rmf-dashboard-framework^... build
RUN cd /ws/dashboard \
  && pnpm install

# # install deps
# RUN cd /ws \
#   && pnpm install --filter rmf-dashboard-framework...

# # copy in the dashboard main files
# RUN mkdir -p /ws/packages/rmf-dashboard-framework/examples/target
# COPY $DASHBOARD_DIRECTORY/* /ws/packages/rmf-dashboard-framework/examples/target/

# # copy in dashoard resources
# COPY dashboard_resources/* /ws/packages/rmf-dashboard-framework/public/resources/

# build
RUN cd /ws/dashboard \
  && pnpm run build

###

FROM docker.io/nginx:stable
COPY --from=0 --chown=root:nginx /ws/dashboard/dist /usr/share/nginx/html/dashboard

COPY nginx.default.conf /etc/nginx/conf.d/default.conf
COPY 99-inject-env.sh /docker-entrypoint.d
