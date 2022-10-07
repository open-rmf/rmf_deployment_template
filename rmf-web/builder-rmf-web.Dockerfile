ARG BUILDER_NS="open-rmf/rmf_deployment_template"

ARG TAG="latest"
FROM $BUILDER_NS/rmf:$TAG

SHELL ["bash", "-c"]

# copy rmf-web source files
COPY rmf-web-src src

RUN  curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get update && apt-get install -y nodejs python3-venv
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -
RUN pip3 install pipenv

RUN cd /opt/rmf/src/rmf-web &&  \
  sed -i '$ d' Pipfile && \
  pnpm install

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
