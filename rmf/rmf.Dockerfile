ARG BUILDER_NS

FROM $BUILDER_NS/builder-rmf

SHELL ["bash", "-c"]

# ENV RMF_BUILDING_MAP_SERVER_CONFIG_PATH will get defined in custom rmf-site docker img
# for: rmf-building-map-server
# run with: ros2 rmf_building_map_tools building_map_server $RMF_BUILDING_MAP_SERVER_CONFIG_PATH

# for: rmf-door-supervisor
# run: ros2 run rmf_fleet_adapter door_supervisor

# for: rmf-lift-supervisor
# run: ros2 run rmf_fleet_adapter lift_supervisor

# for: rmf-traffic-blockade
# run: ros2 run rmf_traffic_ros2 rmf_traffic_blockade --ros-args -p use_sim_time:=$RMF_USE_SIM_TIME

# for: rmf-traffic-schedule
# run: ros2 run rmf_traffic_ros2 rmf_traffic_schedule --ros-args -p use_sim_time:=$RMF_USE_SIM_TIME

# for: rmf-traffic-schedule-monitor
# run: ros2 run rmf_traffic_ros2 rmf_traffic_schedule_monitor --ros-args -p use_sim_time:=$RMF_USE_SIM_TIME

ENV RMF_TRAJECTORY_VISUALIZER_LEVEL_NAME=L1
# for: rmf-trajectory-visualizer
# run: ros2 launch rmf_visualization visualization.launch.xml \
#       use_sim_time:=$RMF_USE_SIM_TIME \
#       viz_config_file:=/opt/rmf/src/demonstrations/rmf_demos/rmf_demos/launch/include/office/office.rviz 
#       headless:=1 \
#       map_name:=$RMF_TRAJECTORY_VISUALIZER_LEVEL_NAME

ENV RMF_SERVER_URI=ws://localhost:8000/_internal
# for: rmf-task-dispatcher
# run: ros2 run rmf_task_ros2 rmf_task_dispatcher --ros-args \
#    -p use_sim_time:=$RMF_USE_SIM_TIME \
#    -p bidding_time_window:=$RMF_BIDDING_TIME_WINDOW \
#    -p server_uri:=$RMF_SERVER_URI'

ENV RMF_ROBOT_STATE_AGGREGATOR_ROBOT_PREFIX=tinyRobot
ENV RMF_ROBOT_STATE_AGGREGATOR_FLEET_NAME=tinyRobot
# for: rmf-robot-state-aggregator
# run: ros2 launch rmf_fleet_adapter robot_state_aggregator.launch.xml \ 
#      fleet_name:=$RMF_ROBOT_STATE_AGGREGATOR_FLEET_NAME robot_prefix:=$RMF_ROBOT_STATE_AGGREGATOR_ROBOT_PREFIX \
#      use_sim_time:=$RMF_USE_SIM_TIME failover_mode:=$RMF_FAILOVER_MODE

ENV RMF_FREE_FLEET_SERVER_FLEET_NAME=magni
ENV RMF_FREE_FLEET_SERVER_DDS_DOMAIN=42
ENV RMF_FREE_FLEET_SERVER_TRANSLATION_X=37.6
ENV RMF_FREE_FLEET_SERVER_TRANSLATION_Y=4.63
ENV RMF_FREE_FLEET_SERVER_ROTATION=-3.10
ENV RMF_FREE_FLEET_SERVER_SCALE=0.982
# for: rmf-free-fleet-server
# run: ros2 run free_fleet_server_ros2 free_fleet_server_ros2 --ros-args \
#    -p fleet_name:=$RMF_FREE_FLEET_SERVER_FLEET_NAME \
#    -p fleet_state_topic:=fleet_states \
#    -p mode_request_topic:=robot_mode_requests \
#    -p path_request_topic:=robot_path_requests \
#    -p destination_request_topic:=robot_destination_requests \
#    -p dds_domain:=$RMF_FREE_FLEET_SERVER_DDS_DOMAIN \
#    -p dds_robot_state_topic:=robot_state \
#    -p dds_mode_request_topic:=mode_request \
#    -p dds_path_request_topic:=path_request \
#    -p dds_destination_request_topic:=destination_request \
#    -p update_state_frequency:=20.0 \
#    -p publish_state_frequency:=2.0 \
#    -p translation_x:=$RMF_FREE_FLEET_SERVER_TRANSLATION_X \
#    -p translation_y:=$RMF_FREE_FLEET_SERVER_TRANSLATION_Y \
#    -p rotation:=$RMF_FREE_FLEET_SERVER_ROTATION \
#    -p scale:=$RMF_FREE_FLEET_SERVER_SCALE

ENV RMF_FLEET_ADAPTER_CONTROL_TYPE=full_control
ENV RMF_FLEET_ADAPTER_FLEET_NAME=tinyRobotFleet
ENV RMF_FLEET_ADAPTER_NAV_GRAPH_FILE=/opt/rmf/install/rmf_demos_maps/share/rmf_demos_maps/maps/office/nav_graphs/0.yaml
ENV RMF_FLEET_ADAPTER_LINEAR_VELOCITY=0.5
ENV RMF_FLEET_ADAPTER_ANGULAR_VELOCITY=0.6
ENV RMF_FLEET_ADAPTER_LINEAR_ACCELERATION=0.75
ENV RMF_FLEET_ADAPTER_ANGULAR_ACCELERATION=2.0
ENV RMF_FLEET_ADAPTER_FOOTPRINT_RADIUS=0.3
ENV RMF_FLEET_ADAPTER_VICINITY_RADIUS=1.0
ENV RMF_FLEET_ADAPTER_DELAY_THRESHOLD=15.0
ENV RMF_FLEET_ADAPTER_RETRY_WAIT=10.0
ENV RMF_FLEET_ADAPTER_DISCOVERY_TIMEOUT=60.0
ENV RMF_FLEET_ADAPTER_PERFORM_DELIVERIES=true
ENV RMF_FLEET_ADAPTER_PERFORM_LOOP=true
ENV RMF_FLEET_ADAPTER_PERFORM_CLEANING=true
ENV RMF_FLEET_ADAPTER_BATTERY_VOLTAGE=12.0
ENV RMF_FLEET_ADAPTER_BATTERY_CAPACITY=24.0
ENV RMF_FLEET_ADAPTER_BATTERY_CHARGING_CURRENT=5.0
ENV RMF_FLEET_ADAPTER_MASS=20.0
ENV RMF_FLEET_ADAPTER_INERTIA=10.0
ENV RMF_FLEET_ADAPTER_FRICTION_COEFFICIENT=0.22
ENV RMF_FLEET_ADAPTER_AMBIENT_POWER_DRAIN=20.0
ENV RMF_FLEET_ADAPTER_TOOL_POWER_DRAIN=0.0
ENV RMF_FLEET_ADAPTER_DRAIN_BATTERY=true
ENV RMF_FLEET_ADAPTER_RECHARGE_THRESHOLD=0.1
# for: rmf-fleet-adapter
# run: ros2 run rmf_fleet_adapter $RMF_FLEET_ADAPTER_CONTROL_TYPE --ros-args \ 
#    -p fleet_name:=$RMF_FLEET_ADAPTER_FLEET_NAME \
#    -p control_type:=$RMF_FLEET_ADAPTER_CONTROL_TYPE \ 
#    -p nav_graph_file:=$RMF_FLEET_ADAPTER_NAV_GRAPH_FILE \
#    -p linear_velocity:=$RMF_FLEET_ADAPTER_LINEAR_VELOCITY \
#    -p angular_velocity:=$RMF_FLEET_ADAPTER_ANGULAR_VELOCITY \
#    -p linear_acceleration:=$RMF_FLEET_ADAPTER_LINEAR_ACCELERATION \
#    -p angular_acceleration:=$RMF_FLEET_ADAPTER_ANGULAR_ACCELERATION \
#    -p footprint_radius:=$RMF_FLEET_ADAPTER_FOOTPRINT_RADIUS \
#    -p vicinity_radius:=$RMF_FLEET_ADAPTER_VICINITY_RADIUS \
#    -p use_sim_time:=$RMF_USE_SIM_TIME \
#    -p delay_treshold:=$RMF_FLEET_ADAPTER_DELAY_THRESHOLD \
#    -p retry_wait:=$RMF_FLEET_ADAPTER_RETRY_WAIT \
#    -p discovery_timeout:=$RMF_FLEET_ADAPTER_DISCOVERY_TIMEOUT \
#    -p perform_deliveries:=$RMF_FLEET_ADAPTER_PERFORM_DELIVERIES \
#    -p perform_loop:=$RMF_FLEET_ADAPTER_PERFORM_LOOP \
#    -p perform_cleaning:=$RMF_FLEET_ADAPTER_PERFORM_CLEANING \
#    -p battery_voltage:=$RMF_FLEET_ADAPTER_BATTERY_VOLTAGE \
#    -p battery_capacity:=$RMF_FLEET_ADAPTER_BATTERY_CAPACITY \
#    -p battery_charging_current:=$RMF_FLEET_ADAPTER_BATTERY_CHARGING_CURRENT \
#    -p mass:=$RMF_FLEET_ADAPTER_MASS \
#    -p inertia:=$RMF_FLEET_ADAPTER_INERTIA \
#    -p friction_coefficient:=$RMF_FLEET_ADAPTER_FRICTION_COEFFICIENT \
#    -p ambient_power_drain:=$RMF_FLEET_ADAPTER_AMBIENT_POWER_DRAIN \
#    -p tool_power_drain:=$RMF_FLEET_ADAPTER_TOOL_POWER_DRAIN \
#    -p drain_battery:=$RMF_FLEET_ADAPTER_DRAIN_BATTERY \
#    -p recharge_threshold:=$RMF_FLEET_ADAPTER_RECHARGE_THRESHOLD \
#    -p server_uri:=$RMF_SERVER_URI \
#    -r __node:=${RMF_FLEET_ADAPTER_FLEET_NAME}_fleet_adapter

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
