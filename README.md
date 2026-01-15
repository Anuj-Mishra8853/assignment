# Kubernetes RBAC Infrastructure with Terraform

This project deploys a Kubernetes cluster on AWS EKS with comprehensive RBAC testing, S3 integration, and workload identity (IRSA) configuration.

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate permissions
- kubectl >= 1.21
- Docker (for custom image build)

## Architecture

- **EKS Cluster**: Public endpoint, private worker nodes
- **VPC**: Private subnets for nodes, public subnets for NAT gateways
- **S3 Bucket**: For storage access testing
- **IRSA**: IAM Roles for Service Accounts integration
- **RBAC**: Granular permissions testing across namespaces

## Quick Start

1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars` and configure
3. Run deployment: `./scripts/deploy-rbac.sh`
4. Execute tests: `kubectl exec -it rbac-test-pod -n default -- /scripts/test-rbac.sh`

## Directory Structure

```
├── terraform/           # Infrastructure as Code
│   ├── modules/        # Reusable modules (VPC, EKS, S3, IRSA)
│   ├── main.tf         # Main configuration
│   └── terraform.tfvars.example
├── k8s/                # Kubernetes manifests
│   ├── namespace.yaml  # rbac-a and rbac-b namespaces
│   ├── serviceaccount.yaml # rbac-test-sa with IRSA
│   ├── rbac.yaml       # ClusterRole and Role bindings
│   └── test-pod.yaml   # Ubuntu test pod
├── docker/             # Custom Docker image
│   ├── Dockerfile      # Ubuntu with kubectl and AWS CLI
│   ├── test-rbac.sh    # RBAC permission tests
│   └── test-s3.sh      # S3 access tests
└── docs/               # Documentation
```

## RBAC Configuration

- **Cluster-wide**: List namespaces only
- **rbac-a namespace**: Read-only access to all resources
- **rbac-b namespace**: Full access to all resources
- **Other namespaces**: No access

## Cleanup

```bash
kubectl delete -f k8s/
cd terraform && terraform destroy
```
