FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

ENV RMF_TRAJECTORY_VISUALIZER_LEVEL_NAME=L1

RUN sed -i '$iros2 launch rmf_visualization visualization.launch.xml use_sim_time:=$RMF_USE_SIM_TIME viz_config_file:=/opt/rmf/src/demonstrations/rmf_demos/rmf_demos/launch/include/office/office.rviz headless:=1 map_name:=$RMF_TRAJECTORY_VISUALIZER_LEVEL_NAME' /ros_entrypoint.sh
