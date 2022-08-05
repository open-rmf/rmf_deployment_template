# Infrastructure

This directory contains the bringup instructions and configurations to setup a Kubernetes cluster infrastructure.

The app to deploy is located in `cloud_infra` as `rmf_deployment`. The `rmf_deployment` template is fully configurable and minimally will need following edits prior to bringup. Be sure to edit these prior to running thru the next steps..
- RMF configuration in `rmf-deployment/`
    - `rmf_server_config.py` - replace DNS name `rmf-deployment-template.open-rmf.org` with your own.
    - `values.yaml` - replace registryUrl `ghcr.io/open-rmf` and DNS name `rmf-deployment-template.open-rmf.org` with your own.
    - `cyclonedds.xml` - if you are using cyclonedds to communicate across multiple nodes on different machines, update the `Peers` in the `.xml`.
    - `rmf-site-modules.yaml` - Add site specific nodes (e.g. fleet and door adapters) to the template.

## Provisioning
We will need the following resources:
* 1 Cloud VM ( For RMF k8s cluster )
* Operator Machine ( For provisioning ) with SSH access to this VM.

### Cloud resource provisioning

#### Provision Cloud VM
VM specifications:
- 4 vCPU, 8GB memory _[recommended size for 2 robots, 1 door, 1 lift (elevator), your mileage may vary based on your scale]_
- 80GB SSD storage
- 1 public IP
- Ports 443, 22 open

#### Add DNS record
Add VM public IP to domain url in DNS records (eg. Route 53 in AWS)

### Bootstrap Kubernetes Cluster on Cloud Machine
K8s will only run on the single deployment node
```bash
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh

curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
k3sup install --local --user ubuntu --cluster --k3s-extra-args '--flannel-iface=ens5 --no-deploy traefik --write-kubeconfig-mode --docker'

git clone git@github.com:open-rmf/rmf_deployment_template.git
cd rmf_deployment_template

kubectl apply -f infrastructure/nginx/ingress-nginx.yaml
kubectl wait --for=condition=available deployment/ingress-nginx-controller -n ingress-nginx --timeout=2m

# Get ingress IP
kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
# Get the Node-Pod mapping
kubectl get pod -o=custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName --all-namespaces
```

### Set up SSL Certificates
```bash
kubectl create namespace cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/latest/download/cert-manager.yaml
kubectl wait --for=condition=available deployment/cert-manager -n cert-manager --timeout=2m

# NOTE: Specify your `ACME_EMAIL` and `DOMAIN_NAME` for letsencrypt-issuer-production
export DOMAIN_NAME=rmf-deployment-template.open-rmf.org
export ACME_EMAIL=YOUREMAIL@DOMAIN.com
envsubst < infrastructure/cert-manager/letsencrypt-issuer-production.yaml | kubectl apply -f -
kubectl get certificates # should be true, might need to wait a minute
```

### Continuous Deployment: ArgoCD
We will use ArgoCD to handle infra changes to the `cloud_infra` branch of this repository. The `rmf_deployment` directory consists of all nessarry helm charts needed for rmf deployment

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create namespace deploy
kubectl port-forward svc/argocd-server -n argocd 9090:443
# Start a new ssh session with port forward 9090 to the VM, you should now be able to view the admin panel on port localhost:9090

# Get the initial password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Connect the repository
## View the docs to learn how to configure ArgoCD
## When adding a "new app" on argocd, we will specify the repo, `cloud_infra` branch and `rmf_deployment` dir 

# Now if you sync the app, we should see the full deployment "come alive"

# Add domain url and initial credentials (after keycloak pod is running)
./keycloak-setup.bash rmf-deployment-template.open-rmf.org 
```

RMF web dashboard will now be accessible on your_url/dashboard (eg. rmf.open-rmf.org/dashboard); users can be manage via your_url/auth (eg. rmf.open-rmf.org/auth)
