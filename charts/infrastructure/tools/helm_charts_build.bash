#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_REPO="$(realpath "${SCRIPT_DIR}/../..")"

# safety check
if [[ ! -d $ROOT_REPO/.git ]]; then
  echo "Can not find .git in $ROOT_REPO. This probably means that the script needs to be udpated" 
  exit 1
fi

pushd "${ROOT_REPO}" 2> /dev/null  || exit
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add jetstack https://charts.jetstack.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add harbor https://helm.goharbor.io
helm repo add minio https://operator.min.io
helm repo add mender https://charts.mender.io
helm repo add t3n https://storage.googleapis.com/t3n-helm-charts
helm dep build infrastructure
helm dep build monitoring
helm dep build harbor
helm dep build minio
helm dep build mender
helm dep build mosquitto
popd 2> /dev/null || exit