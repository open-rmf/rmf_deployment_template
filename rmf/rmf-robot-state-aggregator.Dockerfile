FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

ENV RMF_ROBOT_STATE_AGGREGATOR_ROBOT_PREFIX=tinyRobot
ENV RMF_ROBOT_STATE_AGGREGATOR_FLEET_NAME=tinyRobot

RUN sed -i '$iros2 launch rmf_fleet_adapter robot_state_aggregator.launch.xml \ 
    fleet_name:=$RMF_ROBOT_STATE_AGGREGATOR_FLEET_NAME robot_prefix:=$RMF_ROBOT_STATE_AGGREGATOR_ROBOT_PREFIX \
    use_sim_time:=$RMF_USE_SIM_TIME failover_mode:=$RMF_FAILOVER_MODE' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

