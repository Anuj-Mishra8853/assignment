# Deployment Instructions

## Prerequisites

Ensure you have the following tools installed:

- **Terraform**: >= 1.0 ([Install Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- **AWS CLI**: >= 2.0 ([Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html))
- **kubectl**: >= 1.21 ([Install Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/))
- **Docker**: Latest version ([Install Guide](https://docs.docker.com/get-docker/))

## AWS Configuration

Configure AWS CLI with appropriate credentials:

```bash
aws configure
```

Ensure your AWS user/role has the following permissions:
- EC2 full access
- EKS full access
- IAM role creation and management
- VPC management
- S3 bucket creation and management

## Step-by-Step Deployment

### 1. Clone and Configure

```bash
git clone <repository-url>
cd k8s-terraform-project
```

### 2. Configure Terraform Variables

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your desired configuration:
```hcl
aws_region   = "us-west-2"
cluster_name = "my-eks-cluster"
bucket_name  = "my-rbac-test-bucket-12345"  # Must be globally unique
```

### 3. Deploy Infrastructure and Test

```bash
# Automated deployment
./scripts/deploy-rbac.sh
```

**Expected output**: Terraform will create VPC, EKS cluster, S3 bucket, IRSA roles, and deploy Kubernetes resources. This takes approximately 15-20 minutes.

### 4. Manual Deployment (Alternative)

```bash
# Deploy infrastructure
cd terraform
terraform init
terraform plan
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-west-2 --name my-eks-cluster

# Update manifests with dynamic values
cd ../k8s
IRSA_ROLE_ARN=$(cd ../terraform && terraform output -raw irsa_role_arn)
S3_BUCKET_NAME=$(cd ../terraform && terraform output -raw s3_bucket_name)

sed -i "s|REPLACE_WITH_IRSA_ROLE_ARN|$IRSA_ROLE_ARN|g" serviceaccount.yaml
sed -i "s|REPLACE_WITH_BUCKET_NAME|$S3_BUCKET_NAME|g" test-pod.yaml

# Deploy Kubernetes resources
kubectl apply -f .
```

## Validation Tests

### Infrastructure Validation

```bash
# Verify EKS cluster
aws eks describe-cluster --name my-eks-cluster

# Verify S3 bucket
aws s3 ls s3://my-rbac-test-bucket-12345

# Verify IRSA role
aws iam get-role --role-name my-eks-cluster-rbac-test-sa-role
```

### RBAC Validation

```bash
# Check namespaces
kubectl get namespaces

# Check service account
kubectl get sa rbac-test-sa -n default -o yaml

# Check RBAC resources
kubectl get clusterroles,clusterrolebindings,roles,rolebindings --all-namespaces | grep rbac
```

### Automated Testing

```bash
# Wait for pod to be ready
kubectl wait --for=condition=Ready pod rbac-test-pod -n default --timeout=300s

# Run RBAC tests
kubectl exec -it rbac-test-pod -n default -- /scripts/test-rbac.sh

# Run S3 tests
kubectl exec -it rbac-test-pod -n default -- /scripts/test-s3.sh
```

### Expected Test Results

**RBAC Tests:**
1. ✅ List namespaces - SUCCESS
2. ❌ List pods in default - FAIL (no access)
3. ❌ List pods in kube-system - FAIL (no access)
4. ✅ List pods in rbac-a - SUCCESS (read access)
5. ❌ Create deployment in rbac-a - FAIL (read-only)
6. ✅ List pods in rbac-b - SUCCESS (full access)
7. ✅ Create deployment in rbac-b - SUCCESS (full access)
8. ✅ Delete deployment in rbac-b - SUCCESS (full access)

**S3 Tests:**
1. ✅ Upload file to S3 - SUCCESS
2. ✅ List bucket contents - SUCCESS
3. ✅ Download file from S3 - SUCCESS
4. ✅ Delete file from S3 - SUCCESS

## Manual Testing

```bash
# Access the test pod
kubectl exec -it rbac-test-pod -n default -- /bin/bash

# Test individual commands
kubectl get namespaces
kubectl get pods -n default  # Should fail
kubectl get pods -n rbac-a   # Should succeed
kubectl create deployment test --image=nginx -n rbac-a  # Should fail
kubectl create deployment test --image=nginx -n rbac-b  # Should succeed

# Test S3 access
aws s3 ls s3://your-bucket-name
echo "test" > test.txt
aws s3 cp test.txt s3://your-bucket-name/
```

## Troubleshooting

### Common Issues

1. **IRSA not working**
   - Check service account annotation
   - Verify OIDC provider configuration
   - Check IAM role trust policy

2. **RBAC permissions not working**
   - Verify role bindings: `kubectl get rolebindings,clusterrolebindings -A`
   - Check service account: `kubectl get sa rbac-test-sa -n default -o yaml`

3. **S3 access denied**
   - Check IAM role permissions
   - Verify bucket policy
   - Check AWS region configuration

### Useful Commands

```bash
# Check pod logs
kubectl logs rbac-test-pod -n default

# Describe pod for troubleshooting
kubectl describe pod rbac-test-pod -n default

# Check IRSA annotation
kubectl get sa rbac-test-sa -n default -o jsonpath='{.metadata.annotations}'

# Test specific RBAC permissions
kubectl auth can-i get pods --as=system:serviceaccount:default:rbac-test-sa -n rbac-a
```
