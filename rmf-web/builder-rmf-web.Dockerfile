ARG BUILDER_NS="open-rmf/rmf_deployment_template"

ARG TAG="latest"
FROM $BUILDER_NS/rmf:$TAG

SHELL ["bash", "-c"]

# copy rmf-web source files
COPY rmf-web-src src

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash && \
  source $HOME/.nvm/nvm.sh && \
  nvm install 16

RUN curl -fsSL https://get.pnpm.io/install.sh | bash - && \
  export PNPM_HOME="/root/.local/share/pnpm" && \
  export PATH="$PNPM_HOME:$PATH" && \
  pnpm env use --global 16

RUN apt update && apt install python3-venv -y

RUN cd /opt/rmf/src/rmf-web &&  \
  sed -i '$ d' Pipfile && \
  pnpm config set unsafe-perm && \
  pnpm install

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
