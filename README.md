# RMF Deployment Template
This repo provides a sample template to build, deploy and manage an RMF installation (i.e. GitOps for RMF)

This repo is structured as -
- `main` - Intro
- `build/rmf` - Build Dockerfiles and CI pipeline
- `cloud_infra` - Cloud cluster bringup scripts and docs and runtime configs

_(These branches may be setup as independant repos for a production environment, the intent in having them as branches here is to provide a concise one-stop location for easy reference.)_

We will use the following tools for this example -
- CI : [Github actions](https://github.com/features/actions)
- Container registry: [Github packages](https://github.com/features/packages)
- VM hosting: [AWS EC2](https://aws.amazon.com/ec2/)
- DNS: [AWS Route 53](https://aws.amazon.com/route53/)
- Kubernetes distribution: [k3s](https://k3s.io) 
- CD: [ArgoCD](https://argoproj.github.io/cd)

Running thru the steps we should have an RMF deployment accessible on public url.
