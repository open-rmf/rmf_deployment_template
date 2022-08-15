![](https://github.com/open-rmf/rmf_deployment_template/workflows/docker-img-galactic/badge.svg)
![](https://github.com/open-rmf/rmf_deployment_template/workflows/docker-img-latest/badge.svg)
![](https://github.com/open-rmf/rmf_deployment_template/workflows/rmf-site-ci/badge.svg)

# RMF Deployment Template
This repo provides a sample template to build, deploy and manage an RMF installation (i.e. GitOps for RMF)

This repo is structured as -
- `main` - Contains Dockerfiles and CI pipeline to build images for this example deployment
- [build/rmf-site](https://github.com/open-rmf/rmf_deployment_template/tree/build/rmf-site) - Contains example rmf-site related resources, dockerfiles and CI process
- [cloud_infra](https://github.com/open-rmf/rmf_deployment_template/tree/cloud_infra) - Cloud cluster bringup scripts, resources and runtime configs

_(These branches may be setup as independant repos for a production environment, the intent in having them as branches here is to provide a concise one-stop location for easy reference.)_

We will use the following tools for this example -
- CI : [Github actions](https://github.com/features/actions)
- Container registry: [Github packages](https://github.com/features/packages)
- VM hosting: [AWS EC2](https://aws.amazon.com/ec2/)
- DNS: [AWS Route 53](https://aws.amazon.com/route53/)
- Kubernetes distribution: [k3s](https://k3s.io) 
- CD: [ArgoCD](https://argoproj.github.io/cd)

Running thru the steps we should have an RMF deployment accessible on public url.

# Example: rmf_demos with docker

Run rmf_demos office world in simulation (use ros `galactic` in this example)

```bash
docker run --network=host \
-it ghcr.io/open-rmf/rmf_deployment_template/rmf-simulation:galactic \
bash -c "ros2 launch rmf_demos_gz office.launch.xml \
headless:=1 \
server_uri:=ws://localhost:8000/_internal"
```

Run `rmf-api-server`
```bash
docker run --network=host \
-it ghcr.io/open-rmf/rmf_deployment_template/rmf-web-rmf-server:galactic
```

Run `rmf-web-dashboard`
```bash
docker run -p 3000:80 \
-it ghcr.io/open-rmf/rmf_deployment_template/rmf-web-dashboard-local:galactic
```

Now access the dashboard with: http://localhost:3000/dashboard
