FROM docker.io/ubuntu:24.04

RUN apt update && apt install -y curl jq
RUN curl -LO "https://dl.k8s.io/release/v1.29.2/bin/linux/amd64/kubectl" \
  && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

COPY keycloak-setup.bash utils.bash /

ENTRYPOINT ["/keycloak-setup.bash"]
