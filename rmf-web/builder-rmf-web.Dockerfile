ARG BUILDER_NS="open-rmf/rmf_deployment_template"

ARG TAG="latest"
FROM $BUILDER_NS/rmf:$TAG

SHELL ["bash", "-c"]

# copy rmf-web source files
COPY rmf-web-src src

RUN apt-get update && apt-get install -y python3-venv

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash && \
  . $HOME/.nvm/nvm.sh && \
  nvm install 16

ENV NVM_DIR $HOME/.nvm

ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH "$PNPM_HOME:$PATH"

RUN curl -fsSL https://get.pnpm.io/install.sh | bash - && \
  pnpm env use --global 16

RUN cd /opt/rmf/src/rmf-web &&  \
  sed -i '$ d' Pipfile && \
  pnpm config set unsafe-perm && \
  pnpm install

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
