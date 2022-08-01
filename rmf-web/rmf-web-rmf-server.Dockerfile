ARG BUILDER_NS="open-rmf/rmf_deployment_template"

FROM $BUILDER_NS/builder-rmf-web

SHELL ["bash", "-c"]

ENV RMF_SERVER_USE_SIM_TIME=true

RUN . /opt/rmf/install/setup.bash && \
  cd /opt/rmf/src/rmf-web/packages/api-server && npm run prepack

FROM $BUILDER_NS/builder-rmf-web

COPY --from=0 /opt/rmf/src/rmf-web/packages/api-server/dist/ .

SHELL ["bash", "-c"]
RUN pip3 install $(ls -1 | grep '.*.whl')[postgres]
RUN pip3 install paho-mqtt

# cleanup
RUN rm -rf /opt/rmf/src
RUN rm -rf /var/lib/apt/lists && \
  npm cache clean --force

RUN echo -e '#!/bin/bash\n\
  . /opt/rmf/install/setup.bash\n\
  exec rmf_api_server "$@"\n\
  ' > /docker-entry-point.sh && chmod +x /docker-entry-point.sh

ENTRYPOINT ["/docker-entry-point.sh"]
