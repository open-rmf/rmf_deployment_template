FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

RUN sed -i '$iros2 run rmf_task_ros2 rmf_task_dispatcher \
    --ros-args -p use_sim_time:=$RMF_USE_SIM_TIME -p bidding_time_window:=$RMF_BIDDING_TIME_WINDOW' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

