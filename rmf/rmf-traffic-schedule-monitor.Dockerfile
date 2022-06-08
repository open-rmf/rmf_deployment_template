FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

RUN sed -i '$iros2 run rmf_traffic_ros2 rmf_traffic_schedule_monitor --ros-args -p use_sim_time:=$RMF_USE_SIM_TIME' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
