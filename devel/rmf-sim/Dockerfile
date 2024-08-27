# must be an image built from rmf-deployment/builder
ARG RMF_IMAGE
FROM $RMF_IMAGE

ARG ROS_DISTRO="jazzy"

RUN mkdir -p /ws/src
WORKDIR /ws

# fetch sources
COPY rmf_sim.repos rmf_sim.repos
RUN vcs import src < rmf_sim.repos

RUN apt update && apt upgrade -y && apt install -y \
    clang lld ros-$ROS_DISTRO-rmw-cyclonedds-cpp \
  && rosdep update \
  && bash -c '. /opt/rmf/setup.bash && rosdep install --from-paths /ws/src -yi -t exec --rosdistro=$ROS_DISTRO'

COPY model_cache.json /root/.pit_crew/

RUN bash -c '. /opt/rmf/setup.bash \
  && mkdir -p /opt/rmf_sim \
  && colcon build --mixin clang lld --merge-install --install-base /opt/rmf_sim --cmake-args -DCMAKE_BUILD_TYPE=Release \
  && rm -rf /ws'

# cleanup
RUN rm -rf /var/lib/apt/lists

RUN sed -i '$isource "/opt/rmf_sim/setup.bash"' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
