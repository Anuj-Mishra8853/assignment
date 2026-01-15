#!/bin/bash

set -e

echo " Starting EKS deployment..."

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo " Terraform is required but not installed."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo " AWS CLI is required but not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo " kubectl is required but not installed."; exit 1; }

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo " Please copy terraform/terraform.tfvars.example to terraform/terraform.tfvars and configure it"
    exit 1
fi

# Deploy infrastructure
echo "Deploying infrastructure with Terraform..."
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# Get cluster name from terraform output
CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(grep aws_region terraform.tfvars | cut -d'"' -f2)

echo "Configuring kubectl..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "Deploying Kubernetes resources..."
cd ../k8s
kubectl apply -f .

echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pods -l app=test-pod -n test-namespace --timeout=300s

echo "Deployment complete!"
echo ""
echo "Verification commands:"
echo "kubectl get all -n test-namespace"
echo "kubectl port-forward -n test-namespace svc/test-pod-service 8080:80"
echo ""
echo "To cleanup: cd terraform && terraform destroy"
