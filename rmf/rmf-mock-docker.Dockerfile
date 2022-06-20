FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

ENV RMF_DOCKING_CONFIG_FILE=/opt/rmf/install/rmf_demos_tasks/share/rmf_demos_tasks/airport_docker_config.yaml

RUN sed -i '$iros2 run rmf_demos_tasks mock_docker -c $RMF_DOCKING_CONFIG_FILE --ros-args -p use_sim_time:=$RMF_USE_SIM_TIME' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

