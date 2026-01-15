#!/bin/bash

set -e

echo "🚀 Starting EKS deployment with RBAC testing..."

# Check prerequisites
command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed."; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is required but not installed."; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed."; exit 1; }

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo "❌ Please copy terraform/terraform.tfvars.example to terraform/terraform.tfvars and configure it"
    exit 1
fi

# Deploy infrastructure
echo "📦 Deploying infrastructure with Terraform..."
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# Get outputs from terraform
CLUSTER_NAME=$(terraform output -raw cluster_name)
AWS_REGION=$(grep aws_region terraform.tfvars | cut -d'"' -f2)
S3_BUCKET_NAME=$(terraform output -raw s3_bucket_name)
IRSA_ROLE_ARN=$(terraform output -raw irsa_role_arn)

echo "⚙️  Configuring kubectl..."
aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME

echo "🔍 Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "🎯 Updating Kubernetes manifests with dynamic values..."
cd ../k8s

# Update service account with IRSA role ARN
sed -i "s|REPLACE_WITH_IRSA_ROLE_ARN|$IRSA_ROLE_ARN|g" serviceaccount.yaml

# Update test pod with S3 bucket name
sed -i "s|REPLACE_WITH_BUCKET_NAME|$S3_BUCKET_NAME|g" test-pod.yaml

echo "🎯 Deploying Kubernetes resources..."
kubectl apply -f .

echo "⏳ Waiting for pod to be ready..."
kubectl wait --for=condition=Ready pod rbac-test-pod -n default --timeout=300s

echo "✅ Deployment complete!"
echo ""
echo "🔍 Verification commands:"
echo "kubectl get all -n default"
echo "kubectl get all -n rbac-a"
echo "kubectl get all -n rbac-b"
echo ""
echo "🧪 Run RBAC tests:"
echo "kubectl exec -it rbac-test-pod -n default -- /scripts/test-rbac.sh"
echo ""
echo "🧪 Run S3 tests:"
echo "kubectl exec -it rbac-test-pod -n default -- /scripts/test-s3.sh"
echo ""
echo "🧹 To cleanup: cd terraform && terraform destroy"
