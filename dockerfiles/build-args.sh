#!/bin/bash

ROS_DISTRO=jazzy
: ${BUILDER_IMAGE:=localhost/rmf/builder:latest}
RMF_INTERNAL_MSGS_COMMIT="main"
RMF_WEB_COMMIT="debug/cluster"
RMF_BUILDING_MAP_MSGS_COMMIT="main"

ARGS=$(getopt --options= --longoptions=ros-distro: --name="$0" -- "$@")
eval set -- "$ARGS"
while true; do
  case "$1" in
    --ros-distro)
      # override ros distro
      ROS_DISTRO="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
  esac
done

API_SERVER_BUILD_ARGS="--build-arg=BUILDER=$BUILDER_IMAGE --build-arg=ROS_DISTRO=$ROS_DISTRO --build-arg=RMF_WEB_COMMIT=$RMF_WEB_COMMIT --build-arg=RMF_INTERNAL_MSGS_COMMIT=$RMF_INTERNAL_MSGS_COMMIT --build-arg=RMF_BUILDING_MAP_MSGS_COMMIT=$RMF_BUILDING_MAP_MSGS_COMMIT"
DASHBOARD_BUILD_ARGS="--build-arg=RMF_WEB_COMMIT=$RMF_WEB_COMMIT"
DASHBOARD_LOCAL_BUILD_ARGS="--build-arg=RMF_WEB_COMMIT=$RMF_WEB_COMMIT --build-arg=APP_CONFIG=app-config-local.json"
RMF_BUILD_ARGS="--build-arg=BUILDER=$BUILDER_IMAGE --build-arg=ROS_DISTRO=$ROS_DISTRO"
RMF_SITE_BUILD_ARGS="--build-arg=RMF_IMAGE=$BUILDER_IMAGE --build-arg=ROS_DISTRO=$ROS_DISTRO"
RMF_SIM_BUILD_ARGS="--build-arg=RMF_IMAGE=$BUILDER_IMAGE --build-arg=ROS_DISTRO=$ROS_DISTRO"
