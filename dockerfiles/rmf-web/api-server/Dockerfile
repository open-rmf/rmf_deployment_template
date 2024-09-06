ARG ROS_DISTRO="jazzy"
# must be an image built from rmf-deployment/builder
ARG BUILDER
FROM $BUILDER as rmf

ARG RMF_INTERNAL_MSGS_COMMIT="main"
ARG RMF_BUILDING_MAP_MSGS_COMMIT="main"

# fetch sources
RUN mkdir -p /ws && cd /ws \
  && curl -sL https://github.com/open-rmf/rmf_internal_msgs/archive/$RMF_INTERNAL_MSGS_COMMIT.tar.gz -o rmf_internal_msgs.tar.gz \
  && curl -sL https://github.com/open-rmf/rmf_building_map_msgs/archive/$RMF_BUILDING_MAP_MSGS_COMMIT.tar.gz -o rmf_building_map_msgs.tar.gz \
  && mkdir -p /ws/src/rmf/rmf_internal_msgs && tar zxf rmf_internal_msgs.tar.gz -C /ws/src/rmf/rmf_internal_msgs --strip-components=1 && rm rmf_internal_msgs.tar.gz \
  && mkdir -p /ws/src/rmf/rmf_building_map_msgs && tar zxf rmf_building_map_msgs.tar.gz -C /ws/src/rmf/rmf_building_map_msgs --strip-components=1 && rm rmf_building_map_msgs.tar.gz

# install dependencies
RUN cd /ws \
  && apt update && apt upgrade -y \
  && rosdep update --rosdistro $ROS_DISTRO \
  && rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO

# build rmf
RUN cd /ws \
  && . /opt/ros/$ROS_DISTRO/setup.sh \
  && colcon build --merge-install --cmake-args -DCMAKE_BUILD_TYPE=Release
# jazzy does not have `local` unlike humble, docker will fail when we try to copy a directory
# that doesn't exist so we make an empty `local`.
RUN mkdir -p /ws/install/local

FROM rmf as api_server

ARG RMF_WEB_COMMIT="main"

# install pnpm
RUN curl -fsSL https://get.pnpm.io/install.sh | bash -
ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH "$PNPM_HOME:$PATH"

# setup pnpm and install node
# this needs to be a separate step so that pnpm can be found
RUN pnpm config set unsafe-perm \
  && pnpm env use --global 20

RUN apt update && apt install -y python3-pip python3-venv

# fetch sources
RUN mkdir -p /ws \
  && curl -sL https://github.com/open-rmf/rmf-web/archive/$RMF_WEB_COMMIT.tar.gz -o rmf_web.tar.gz \
  && tar zxf rmf_web.tar.gz -C /ws --strip-components=1

# install deps
# RUN <<EOF
#   if [ $ROS_DISTRO = humble ]; then
#     pip3 install -U packaging
#   fi
# EOF
RUN cd /ws \
  && pnpm install -w --filter api-server...

# # build api-server
# RUN cd /ws/packages/api-server \
#   && pnpm run prepack

# FROM docker.io/library/ros:$ROS_DISTRO-ros-core

# RUN apt update && apt install -y python3-pip ros-$ROS_DISTRO-rmw-cyclonedds-cpp

# COPY --from=api_server /ws/packages/api-server/dist/* dist/
# RUN <<EOF
#   if [ $ROS_DISTRO != humble ]; then
#     PIP_ARGS='--break-system-packages'
#   fi
#   pip3 install $PIP_ARGS $(find dist -name "api_server-*.whl")[postgres]
# EOF

# # according to rosdep, the messages have no deps so we can just copy the files directly in!
# # this reduces the image size by ~50%.
# COPY --from=rmf /ws/install/include /opt/ros/$ROS_DISTRO/include
# COPY --from=rmf /ws/install/lib /opt/ros/$ROS_DISTRO/lib
# COPY --from=rmf /ws/install/local /opt/ros/$ROS_DISTRO/local
# COPY --from=rmf /ws/install/share /opt/ros/$ROS_DISTRO/share

# # Copy over ws alongside the python virtual environment
# RUN mkdir /ws
# COPY --from=base /ws /ws

# # cleanup
# RUN rm -rf \
#     /var/lib/apt/lists \
#     /dist

# ENTRYPOINT ["bash", "-c", ". /opt/ros/$ROS_DISTRO/setup.bash && rmf_api_server"]

ENV RMF_API_SERVER_CONFIG /ws/packages/api-server/sqlite_local_config.py
WORKDIR /ws/packages/api-server
ENTRYPOINT ["bash", "-c", ". /ws/install/setup.bash && mkdir -p run/cache && ../../.venv/bin/pipenv run python -m api_server"]
