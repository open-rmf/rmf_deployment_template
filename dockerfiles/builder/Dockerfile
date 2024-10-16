ARG ROS_DISTRO="jazzy"

FROM docker.io/ros:$ROS_DISTRO

ENV CI=1
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

RUN apt update && apt install -y \
  cmake \
  curl \
  python3-pip \
  git \
  wget \
  python3-colcon-common-extensions \
  clang \
  lldb \
  lld \
  ros-$ROS_DISTRO-rmw-cyclonedds-cpp
