FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

ENV RMF_SIMULATION_MAP_PACKAGE=rmf_demos_maps
ENV RMF_SIMULATION_MAP_NAME=office
ENV GAZEBO_VERSION=11

RUN sed -i '$iros2 launch rmf_demos_ign simulation.launch.xml use_sim_time:=$RMF_USE_SIM_TIME map_name:=$RMF_SIMULATION_MAP_NAME map_package:=$RMF_SIMULATION_MAP_PACKAGE headless:=1' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

