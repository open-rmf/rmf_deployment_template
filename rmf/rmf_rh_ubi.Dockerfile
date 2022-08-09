ARG ROS_DISTRO="galactic"

FROM ghcr.io/open-rmf/rmf/rmf_demos as builder
# We use tar instead of directly copying the files because the files becuase of some problems with the symlinks (we want to keep as similar as possible)
RUN cd /usr/lib/x86_64-linux-gnu/ && tar -cvf /tmp/libs.tar .
RUN cd /usr/lib/ && tar --append --file=/tmp/libs.tar libgdal* libarmadillo* libmfhdfalt* libdfalt* libogdi*


#FROM ubi8/python-38 as rhel_ros
FROM redhat/ubi8 as rhel_ros
ARG ROS_DISTRO
SHELL ["bash", "-c"]

RUN mkdir -p \
    /opt/rmf \
    /opt/ros \
    /rmf_demos_ws \
    /usr/lib/python3.8 \
    /usr/lib/python3/dist-packages \
    /usr/lib/x86_64-linux-gnu/ \
    /usr/local/lib/python3.8/dist-packages/ \
    /usr/share/proj/

# Copy the needed libraries from the builder
COPY --from=builder /tmp/libs.tar /tmp/libs.tar
RUN ls -lah /tmp/libs.tar && cd /usr/lib/ && tar -xvf  /tmp/libs.tar
# In ubuntu libraries blas, lapack, mpi in /usr/lib/x86_64-linux-gnu/ link to /etc so the symlinks fail to be reproduced in redhat machine
RUN cp -arsf /usr/lib/lapack/* /usr/lib/blas/* /usr/lib/openmpi/lib/* /usr/lib/pulseaudio/* /usr/lib || true
# Easiest way to ensure that the lib64 libraries are copied over is to copy the entire current /usr/lib directory
RUN cp -arsf /usr/lib/* /lib64/ || true

# Copy ROS and RMF needed directories from the builder
COPY --from=builder /opt/ros /opt/ros/
COPY --from=builder /rmf_demos_ws /rmf_demos_ws/
COPY --from=builder /ros_entrypoint.sh /

# Copy gazebo and ros related binaries. Also the same python3.8 version as the builder
COPY --from=builder /usr/bin/gz* /usr/bin/ros* /usr/bin/python* /usr/bin/

# Avoid to install pip
COPY --from=builder /usr/local/lib/python3.8/dist-packages /usr/local/lib/python3.8/dist-packages/
COPY --from=builder /usr/lib/python3.8 /usr/lib/python3.8/
COPY --from=builder /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages/

# Other minor dependences
COPY --from=builder /usr/local/bin/uvicorn /usr/local/bin/
COPY --from=builder /usr/share/proj /usr/share/proj/

# Set enviroment variables to the output of the builder export -p (avoid to set some ubuntu reelated variables)
ENV LD_LIBRARY_PATH="/lib64:/rmf_demos_ws/install/ros_ign_bridge/lib:/rmf_demos_ws/install/ros_ign_interfaces/lib:/rmf_demos_ws/install/rmf_workcell_msgs/lib:/rmf_demos_ws/install/rmf_fleet_adapter/lib:/rmf_demos_ws/install/rmf_task_ros2/lib:/rmf_demos_ws/inst\
all/rmf_websocket/lib:/rmf_demos_ws/install/rmf_visualization_schedule/lib:/rmf_demos_ws/install/rmf_visualization_rviz2_plugins/lib:/rmf_demos_ws/install/rmf_visualization_msgs/lib:/rmf_demos_ws/install/rmf_traffic_ros2/lib:/rmf_demos_ws/install/rmf_task_sequ\
ence/lib:/rmf_demos_ws/install/rmf_task/lib:/rmf_demos_ws/install/rmf_battery/lib:/rmf_demos_ws/install/rmf_traffic/lib:/rmf_demos_ws/install/rmf_utils/lib:/rmf_demos_ws/install/rmf_traffic_msgs/lib:/rmf_demos_ws/install/rmf_task_msgs/lib:/rmf_demos_ws/install\
/rmf_site_map_msgs/lib:/rmf_demos_ws/install/rmf_scheduler_msgs/lib:/rmf_demos_ws/install/rmf_robot_sim_common/lib:/rmf_demos_ws/install/rmf_obstacle_msgs/lib:/rmf_demos_ws/install/rmf_building_sim_common/lib:/rmf_demos_ws/install/rmf_lift_msgs/lib:/rmf_demos_\
ws/install/rmf_ingestor_msgs/lib:/rmf_demos_ws/install/rmf_fleet_msgs/lib:/rmf_demos_ws/install/rmf_door_msgs/lib:/rmf_demos_ws/install/rmf_dispenser_msgs/lib:/rmf_demos_ws/install/rmf_charger_msgs/lib:/rmf_demos_ws/install/rmf_building_map_msgs/lib:/rmf_demos\
_ws/install/nlohmann_json_schema_validator_vendor/lib:/rmf_demos_ws/install/menge_vendor/lib:/usr/lib/x86_64-linux-gnu/gazebo-11/plugins:/opt/ros/galactic/opt/yaml_cpp_vendor/lib:/opt/ros/galactic/opt/rviz_ogre_vendor/lib:/opt/ros/galactic/lib/x86_64-linux-gnu\
:/opt/ros/galactic/lib"
ENV AMENT_PREFIX_PATH="/rmf_demos_ws/install/ros_ign:/rmf_demos_ws/install/ros_ign_gazebo_demos:/rmf_demos_ws/install/ros_ign_image:/rmf_demos_ws/install/rmf_demos_ign:/rmf_demos_ws/install/ros_ign_bridge:/rmf_demos_ws/install/ros_ign_interfaces:/rmf_de\
mos_ws/install/ros_ign_gazebo:/rmf_demos_ws/install/rmf_workcell_msgs:/rmf_demos_ws/install/rmf_demos_gz:/rmf_demos_ws/install/rmf_demos:/rmf_demos_ws/install/rmf_demos_fleet_adapter:/rmf_demos_ws/install/rmf_fleet_adapter_python:/rmf_demos_ws/install/rmf_flee\
t_adapter:/rmf_demos_ws/install/rmf_task_ros2:/rmf_demos_ws/install/rmf_websocket:/rmf_demos_ws/install/rmf_visualization:/rmf_demos_ws/install/rmf_visualization_schedule:/rmf_demos_ws/install/rmf_visualization_rviz2_plugins:/rmf_demos_ws/install/rmf_visualiza\
tion_fleet_states:/rmf_demos_ws/install/rmf_visualization_building_systems:/rmf_demos_ws/install/rmf_visualization_msgs:/rmf_demos_ws/install/rmf_traffic_ros2:/rmf_demos_ws/install/rmf_traffic_examples:/rmf_demos_ws/install/rmf_task_sequence:/rmf_demos_ws/inst\
all/rmf_task:/rmf_demos_ws/install/rmf_traffic:/rmf_demos_ws/install/rmf_utils:/rmf_demos_ws/install/rmf_demos_bridges:/rmf_demos_ws/install/rmf_traffic_msgs:/rmf_demos_ws/install/rmf_traffic_editor_test_maps:/rmf_demos_ws/install/rmf_traffic_editor_assets:/rm\
f_demos_ws/install/rmf_traffic_editor:/rmf_demos_ws/install/rmf_demos_tasks:/rmf_demos_ws/install/rmf_demos_panel:/rmf_demos_ws/install/rmf_task_msgs:/rmf_demos_ws/install/rmf_building_map_tools:/rmf_demos_ws/install/rmf_site_map_msgs:/rmf_demos_ws/install/rmf\
_scheduler_msgs:/rmf_demos_ws/install/rmf_robot_sim_ignition_plugins:/rmf_demos_ws/install/rmf_robot_sim_gazebo_plugins:/rmf_demos_ws/install/rmf_robot_sim_common:/rmf_demos_ws/install/rmf_obstacle_msgs:/rmf_demos_ws/install/rmf_building_sim_ignition_plugins:/\
rmf_demos_ws/install/rmf_building_sim_gazebo_plugins:/rmf_demos_ws/install/rmf_building_sim_common:/rmf_demos_ws/install/rmf_lift_msgs:/rmf_demos_ws/install/rmf_ingestor_msgs:/rmf_demos_ws/install/rmf_fleet_msgs:/rmf_demos_ws/install/rmf_door_msgs:/rmf_demos_w\
s/install/rmf_dispenser_msgs:/rmf_demos_ws/install/rmf_demos_maps:/rmf_demos_ws/install/rmf_demos_dashboard_resources:/rmf_demos_ws/install/rmf_demos_assets:/rmf_demos_ws/install/rmf_charger_msgs:/rmf_demos_ws/install/rmf_building_map_msgs:/rmf_demos_ws/instal\
l/rmf_api_msgs:/rmf_demos_ws/install/pybind11_json_vendor:/rmf_demos_ws/install/nlohmann_json_schema_validator_vendor:/rmf_demos_ws/install/ament_cmake_catch2:/opt/ros/galactic"
ENV CMAKE_PREFIX_PATH="/rmf_demos_ws/install/ros_ign:/rmf_demos_ws/install/ros_ign_gazebo_demos:/rmf_demos_ws/install/ros_ign_image:/rmf_demos_ws/install/rmf_demos_ign:/rmf_demos_ws/install/ros_ign_bridge:/rmf_demos_ws/install/ros_ign_interfaces:/rmf_de\
mos_ws/install/ros_ign_gazebo:/rmf_demos_ws/install/rmf_workcell_msgs:/rmf_demos_ws/install/rmf_demos_gz:/rmf_demos_ws/install/rmf_demos:/rmf_demos_ws/install/rmf_fleet_adapter_python:/rmf_demos_ws/install/rmf_fleet_adapter:/rmf_demos_ws/install/rmf_task_ros2:\
/rmf_demos_ws/install/rmf_websocket:/rmf_demos_ws/install/rmf_visualization:/rmf_demos_ws/install/rmf_visualization_schedule:/rmf_demos_ws/install/rmf_visualization_rviz2_plugins:/rmf_demos_ws/install/rmf_visualization_msgs:/rmf_demos_ws/install/rmf_traffic_ro\
s2:/rmf_demos_ws/install/rmf_task_sequence:/rmf_demos_ws/install/rmf_task:/rmf_demos_ws/install/rmf_battery:/rmf_demos_ws/install/rmf_traffic:/rmf_demos_ws/install/rmf_utils:/rmf_demos_ws/install/rmf_traffic_msgs:/rmf_demos_ws/install/rmf_traffic_editor_test_m\
aps:/rmf_demos_ws/install/rmf_traffic_editor:/rmf_demos_ws/install/rmf_task_msgs:/rmf_demos_ws/install/rmf_site_map_msgs:/rmf_demos_ws/install/rmf_scheduler_msgs:/rmf_demos_ws/install/rmf_robot_sim_ignition_plugins:/rmf_demos_ws/install/rmf_robot_sim_gazebo_pl\
ugins:/rmf_demos_ws/install/rmf_robot_sim_common:/rmf_demos_ws/install/rmf_obstacle_msgs:/rmf_demos_ws/install/rmf_building_sim_ignition_plugins:/rmf_demos_ws/install/rmf_building_sim_gazebo_plugins:/rmf_demos_ws/install/rmf_building_sim_common:/rmf_demos_ws/i\
nstall/rmf_lift_msgs:/rmf_demos_ws/install/rmf_ingestor_msgs:/rmf_demos_ws/install/rmf_fleet_msgs:/rmf_demos_ws/install/rmf_door_msgs:/rmf_demos_ws/install/rmf_dispenser_msgs:/rmf_demos_ws/install/rmf_demos_maps:/rmf_demos_ws/install/rmf_demos_dashboard_resour\
ces:/rmf_demos_ws/install/rmf_demos_assets:/rmf_demos_ws/install/rmf_charger_msgs:/rmf_demos_ws/install/rmf_building_map_msgs:/rmf_demos_ws/install/rmf_api_msgs:/rmf_demos_ws/install/pybind11_json_vendor:/rmf_demos_ws/install/nlohmann_json_schema_validator_ven\
dor:/rmf_demos_ws/install/menge_vendor:/rmf_demos_ws/install/ament_cmake_catch2"
ENV COLCON_PREFIX_PATH="/rmf_demos_ws/install"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV PATH="/lib64:/rmf_demos_ws/install/rmf_traffic_editor/bin:/rmf_demos_ws/install/nlohmann_json_schema_validator_vendor/bin:/opt/ros/galactic/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV PKG_CONFIG_PATH="/rmf_demos_ws/install/rmf_traffic_examples/lib/x86_64-linux-gnu/pkgconfig:/rmf_demos_ws/install/rmf_traffic_examples/lib/pkgconfig:/rmf_demos_ws/install/rmf_task_sequence/lib/x86_64-linux-gnu/pkgconfig:/rmf_demos_ws/install/rmf_task\
_sequence/lib/pkgconfig:/rmf_demos_ws/install/rmf_task/lib/x86_64-linux-gnu/pkgconfig:/rmf_demos_ws/install/rmf_task/lib/pkgconfig:/rmf_demos_ws/install/rmf_battery/lib/x86_64-linux-gnu/pkgconfig:/rmf_demos_ws/install/rmf_battery/lib/pkgconfig:/rmf_demos_ws/in\
stall/rmf_traffic/lib/x86_64-linux-gnu/pkgconfig:/rmf_demos_ws/install/rmf_traffic/lib/pkgconfig:/rmf_demos_ws/install/rmf_utils/lib/x86_64-linux-gnu/pkgconfig:/rmf_demos_ws/install/rmf_utils/lib/pkgconfig:/rmf_demos_ws/install/menge_vendor/lib/x86_64-linux-gn\
u/pkgconfig:/rmf_demos_ws/install/menge_vendor/lib/pkgconfig"
ENV PYTHONPATH="/lib64:/rmf_demos_ws/install/ros_ign_interfaces/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_workcell_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_demos_fleet_adapter/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_fleet_adapter_python/lib/python/site-packages:/rmf_demos_ws/install/rmf_visualization_fleet_states/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_visualization_building_systems/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_visualization_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_demos_bridges/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_traffic_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_traffic_editor_assets/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_demos_tasks/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_demos_panel/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_task_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_building_map_tools/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_site_map_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_scheduler_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_obstacle_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_lift_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_ingestor_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_fleet_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_door_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_dispenser_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_charger_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_building_map_msgs/lib/python3.8/site-packages:/rmf_demos_ws/install/rmf_api_msgs/lib/python3.8/site-packages:/opt/ros/galactic/lib/python3.8/site-packages"
ENV ROS_DISTRO="galactic"
ENV ROS_LOCALHOST_ONLY="0"
ENV ROS_PACKAGE_PATH="/rmf_demos_ws/install/menge_vendor/share"
ENV ROS_PYTHON_VERSION="3"
ENV ROS_VERSION="2"

# update the location of the shared libraries
RUN ldconfig

# RMF related environment variables
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
CMD ["bash -x"]
