ARG BUILDER
FROM $BUILDER

SHELL ["bash", "-c"]

RUN apt-get update && apt-get install -y python3-pip curl
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get update && apt-get install -y nodejs
RUN pip3 install pipenv

COPY ./src /opt/rmf/src/rmf-web
COPY ./dashboard_resources /opt/rmf/src/rmf-web/packages/dashboard/src/assets/resources
WORKDIR /opt/rmf/src/rmf-web

RUN npm install -g npm@latest && \
  npm config set unsafe-perm && \
  npm ci

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
