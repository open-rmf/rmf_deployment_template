ARG BUILDER_NS

FROM $BUILDER_NS/builder-rmf

SHELL ["bash", "-c"]

# copy rmf-web source files
COPY rmf-web-src src

RUN  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get update && apt-get install -y nodejs
RUN pip3 install pipenv

RUN cd /opt/rmf/src/rmf-web &&  \
  sed -i '$ d' Pipfile && \
  npm install -g npm@latest && \
  npm config set unsafe-perm && \
  npm ci

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
