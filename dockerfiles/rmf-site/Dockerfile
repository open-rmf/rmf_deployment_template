ARG RMF_IMAGE
FROM $RMF_IMAGE as build

RUN mkdir -p /ws/src
WORKDIR /ws

# fetch sources
COPY rmf_site.repos rmf_site.repos
RUN vcs import src < rmf_site.repos

RUN apt-get update && apt-get install -y \
  python3-dev python3-pip libffi-dev libssl-dev cargo clang clang-tools lldb lld libstdc++-12-dev \
  python3-websocket python3-websockets \
  python3-icecream \
  gdb
RUN <<EOF
  if [ $ROS_DISTRO = "humble" ]; then
    pip3 install nudged urllib3 requests 
  else
    pip3 install --break-system-packages nudged urllib3 requests 
  fi
EOF

RUN apt-get update \
    && apt-get upgrade -y \
    && rosdep update \
    && rosdep install --from-paths src --ignore-src --rosdistro $ROS_DISTRO -y

RUN --mount=type=bind,target=/ws/src/mysite <<EOF bash
  . /opt/rmf/setup.bash
  colcon build --merge-install --install-base /opt/rmf-site --cmake-args -DCMAKE_BUILD_TYPE=Release \
    --packages-skip mysite
EOF

WORKDIR /
RUN rm -rf /ws

RUN sed -i '$isource "/opt/rmf-site/setup.bash"' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
