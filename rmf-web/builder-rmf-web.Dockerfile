FROM ghcr.io/open-rmf/rmf_deployment_template/builder-rmf

COPY rmf-web/rmf-web.repos /root

SHELL ["bash", "-c"]

RUN mkdir -p /opt/rmf/src
WORKDIR /opt/rmf
RUN vcs import src < /root/rmf-web.repos

RUN  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get update && apt-get install -y nodejs
RUN pip3 install pipenv

RUN cd /opt/rmf/src/rmf-web 
RUN sed -i '$ d' Pipfile &&  \
  npm install -g npm@latest && \
  npm config set unsafe-perm && \
  npm ci

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
