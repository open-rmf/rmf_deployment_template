#!/bin/bash
set -e

DOCKER_REPO=ghcr.io/open-rmf/rmf_deployment_template
COMMIT_SHA=53e1c128d666933f65677a9fe14cf6c881856af2
DOMAIN_URL='rmf-deployment-template.open-rmf.org'

cd "$(dirname $0)"

mkdir -p src
pushd src
git init
if ! $(git remote | grep -q origin); then
  git remote add origin https://github.com/open-rmf/rmf-web.git
else
  git remote set-url origin https://github.com/open-rmf/rmf-web.git
fi
git fetch origin --depth=1 $COMMIT_SHA
git checkout $COMMIT_SHA
popd

mkdir -p dashboard_resources
./fetch-resources.sh

docker build -t $DOCKER_REPO/builder-rmf-web:$COMMIT_SHA -f builder-rmf-web.Dockerfile  --build-arg BUILDER=$DOCKER_REPO/builder-rmf .
docker build -t $DOCKER_REPO/rmf-dashboard:$COMMIT_SHA --build-arg BUILDER=$DOCKER_REPO/builder-rmf-web:$COMMIT_SHA --build-arg DOMAIN_URL=$DOMAIN_URL - < rmf-web-dashboard.Dockerfile
docker build -t $DOCKER_REPO/rmf-api-server:$COMMIT_SHA --build-arg BUILDER=$DOCKER_REPO/builder-rmf-web:$COMMIT_SHA - < rmf-web-rmf-server.Dockerfile
