ARG BUILDER
FROM $BUILDER

SHELL ["bash", "-c"]

ENV RMF_SERVER_USE_SIM_TIME=false

RUN . /opt/rmf/install/setup.bash && \ 
  cd /opt/rmf/src/rmf-web && \
  cd /opt/rmf/src/rmf-web/packages/api-server && npm run prepack

FROM $BUILDER

COPY --from=0 /opt/rmf/src/rmf-web/packages/api-server/dist/ .

SHELL ["bash", "-c"]
RUN pip3 install $(ls -1 | grep '.*.whl')[postgres]

# cleanup
RUN rm -rf /opt/rmf/src
RUN rm -rf /var/lib/apt/lists && \
  npm cache clean --force

RUN echo -e '#!/bin/bash\n\
  . /opt/rmf/install/setup.bash\n\
  exec rmf_api_server "$@"\n\
  ' > /docker-entry-point.sh && chmod +x /docker-entry-point.sh

ENTRYPOINT ["/docker-entry-point.sh"]
