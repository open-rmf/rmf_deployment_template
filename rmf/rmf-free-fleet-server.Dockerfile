FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

ENV RMF_FREE_FLEET_SERVER_FLEET_NAME=magni
ENV RMF_FREE_FLEET_SERVER_DDS_DOMAIN=42
ENV RMF_FREE_FLEET_SERVER_TRANSLATION_X=37.6
ENV RMF_FREE_FLEET_SERVER_TRANSLATION_Y=4.63
ENV RMF_FREE_FLEET_SERVER_ROTATION=-3.10
ENV RMF_FREE_FLEET_SERVER_SCALE=0.982

RUN sed -i '$iros2 run free_fleet_server_ros2 free_fleet_server_ros2 --ros-args \
    -p fleet_name:=$RMF_FREE_FLEET_SERVER_FLEET_NAME \
    -p fleet_state_topic:=fleet_states \
    -p mode_request_topic:=robot_mode_requests \
    -p path_request_topic:=robot_path_requests \
    -p destination_request_topic:=robot_destination_requests \
    -p dds_domain:=$RMF_FREE_FLEET_SERVER_DDS_DOMAIN \
    -p dds_robot_state_topic:=robot_state \
    -p dds_mode_request_topic:=mode_request \
    -p dds_path_request_topic:=path_request \
    -p dds_destination_request_topic:=destination_request \
    -p update_state_frequency:=20.0 \
    -p publish_state_frequency:=2.0 \
    -p translation_x:=$RMF_FREE_FLEET_SERVER_TRANSLATION_X \
    -p translation_y:=$RMF_FREE_FLEET_SERVER_TRANSLATION_Y \
    -p rotation:=$RMF_FREE_FLEET_SERVER_ROTATION \
    -p scale:=$RMF_FREE_FLEET_SERVER_SCALE' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
