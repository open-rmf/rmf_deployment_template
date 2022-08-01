ARG BUILDER_NS

FROM $BUILDER_NS/builder-rmf-simulation

SHELL ["bash", "-c"]

ENV RMF_SIMULATION_MAP_PACKAGE=rmf_demos_maps
ENV RMF_SIMULATION_MAP_NAME=office
ENV GAZEBO_VERSION=11

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
