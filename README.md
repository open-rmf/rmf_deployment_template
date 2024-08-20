# RMF Deployment Template
This branch instructions and configurations to bringup & run a Open-RMF Kubernetes cluster.

This deployment is fully configurable and minimally will need following edits prior to bringup. Be sure to edit these prior to running thru the next steps..
- RMF configuration in `rmf-deployment/`
    - `rmf_server_config.py` - replace DNS name `rmf-deployment-template.open-rmf.org` with your own.
    - `values.yaml` - replace registryUrl `ghcr.io/open-rmf` and DNS name `rmf-deployment-template.open-rmf.org` with your own.
    - `rmf-site-modules.yaml` - Add site specific nodes (e.g. fleet and door adapters) to the template (built in `build/rmf-site`).
    - `cyclonedds.xml` - if you are using cyclonedds to communicate across multiple nodes on different machines, update the `Peers` in the `.xml`.
    - If you are using ros `galactic`, please switch the corresponding cyclonedds config path to `cyclonedds_galactic.xml`.

## Provisioning
We will need the following resources:
* 1 Cloud VM ( For Open-RMF Kubernetes cluster )
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
We will run Kubernetes on a single node only here, and will be using [k3s](https://k3s.io) to setup the cluster. 
```bash
curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh

curl -sLS https://get.k3sup.dev | sh
sudo install k3sup /usr/local/bin/
k3sup install --local --user ubuntu --cluster --k3s-extra-args '--flannel-iface=ens5 --no-deploy traefik --write-kubeconfig-mode --docker'

git clone git@github.com:open-rmf/rmf_deployment_template.git
cd rmf_deployment_template

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
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

# IMPORTANT: Before you proceed to the next steps, make sure your DNS is indeed setup and resolving; this is to avoid hitting letsencrypt's rate limits on DNS failure.
# NOTE: Specify your `ACME_EMAIL` and `DOMAIN_NAME` for letsencrypt-issuer-production
export DOMAIN_NAME=rmf-deployment-template.open-rmf.org
export ACME_EMAIL=YOUREMAIL@DOMAIN.com
envsubst < infrastructure/cert-manager/letsencrypt-issuer-production.yaml | kubectl apply -f -

# Verify if certificate was issued successfully.
kubectl get certificates # should be true, if not, might need to wait a couple minutes.
```

### Continuous Deployment: ArgoCD
We will use [ArgoCD](https://argoproj.github.io/cd) to handle infra changes on the `cloud_infra` branch of this repository and apply to the cluster. The `rmf-deployment` directory consists of [helm charts](https://helm.sh/docs/topics/charts/) which describes the provisioning of the deployment.

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl create namespace deploy
kubectl port-forward svc/argocd-server -n argocd 9090:443

# Start a new ssh session with port forward 9090 to the VM, you should now be able to view the admin panel on port localhost:9090 (eg. ssh -L 9090:localhost:9090 my-awesome-server.tld and then open ArgoCD web UI by going to localhost:9090 on your workstation)

# Get the initial password for ArgoCD
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
For more on ArgoCD, vist their [readthedocs](https://argo-cd.readthedocs.io/en/stable/) page.
```bash
# Connect the repository

## When adding a "new app" on argocd, we will specify the repo, `cloud_infra` branch and `rmf_deployment` dir 

## Now if you sync the app, we should see the full deployment "come alive"
```
```bash
# Setup auth
## Add domain url and initial credentials (after keycloak pod is running)
cd infrastructure
./keycloak-setup.bash rmf-deployment-template.open-rmf.org 
```

RMF web dashboard will now be accessible on your_url/dashboard (eg. rmf.open-rmf.org/dashboard); users can be managed via your_url/auth (eg. rmf.open-rmf.org/auth)

Any changes made to this branch will be picked up by ArgoCD and may be applied automatically/manually to your cluster.