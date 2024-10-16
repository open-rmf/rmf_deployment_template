#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ROOT_REPO="$(realpath "${SCRIPT_DIR}/../../..")"

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
helm repo add t3n https://storage.googleapis.com/t3n-helm-charts
helm dep build charts/infrastructure
helm dep build charts/monitoring
popd 2> /dev/null || exit