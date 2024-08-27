ARG ROS_DISTRO="jazzy"
# must be an image built from romih-production-ttsh/builder
ARG BUILDER
FROM $BUILDER as build

RUN mkdir -p /ws/src
WORKDIR /ws

# fetch sources
COPY rmf.repos rmf-$ROS_DISTRO.repos /ws/
RUN vcs import src < rmf.repos && vcs import src < rmf-$ROS_DISTRO.repos

# ros packages are often not properly versioned, installing new packages without also updating existing
# packages can break existing installation.
RUN apt update && apt upgrade -y && \
  rosdep update --rosdistro $ROS_DISTRO && \
  rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -y

RUN . /opt/ros/$ROS_DISTRO/setup.sh \
  && colcon build --mixin clang lld --merge-install --install-base /opt/rmf --cmake-args -DCMAKE_BUILD_TYPE=Release --packages-skip rmf_traffic_editor_test_maps

###

FROM ros:$ROS_DISTRO-ros-base

RUN --mount=from=build,target=/src,source=/ws/src <<EOF
apt update && apt install -y ros-$ROS_DISTRO-rmw-cyclonedds-cpp && rosdep update
rosdep install --from-paths /src -yi -t exec --rosdistro=$ROS_DISTRO
EOF

RUN mkdir -p /opt/rmf
COPY --from=build /opt/rmf /opt/rmf

# cleanup
RUN rm -rf /var/lib/apt/lists

RUN sed -i '$isource "/opt/rmf/setup.bash"' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
