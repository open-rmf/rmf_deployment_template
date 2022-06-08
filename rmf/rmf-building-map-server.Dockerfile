FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

SHELL ["bash", "-c"]

ENV RMF_BUILDING_MAP_SERVER_CONFIG_PATH=/opt/rmf/install/rmf_demos_maps/share/rmf_demos_maps/office/office.building.yaml

RUN sed -i '$iros2 run rmf_building_map_tools building_map_server $RMF_BUILDING_MAP_SERVER_CONFIG_PATH' /ros_entrypoint.sh

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
