ARG BUILDER_NS="open-rmf/rmf_deployment_template"

ARG TAG="latest"
FROM $BUILDER_NS/rmf:$TAG

SHELL ["bash", "-c"]

# copy rmf-web source files
COPY rmf-web-src src

RUN  curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get update && apt-get install -y nodejs python3-venv
RUN curl -f https://get.pnpm.io/v6.16.js | node - add --global pnpm
RUN npm install husky --save-dev

RUN cd /opt/rmf/src/rmf-web &&  \
  sed -i '$ d' Pipfile && \
  pnpm install --no-frozen-lockfile --prod

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
