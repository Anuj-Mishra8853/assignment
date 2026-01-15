# Cleanup Instructions

## Complete Cleanup Process

Follow these steps to completely remove all resources created by this project.

### 1. Remove Kubernetes Resources

```bash
# Delete all Kubernetes resources
kubectl delete -f k8s/

# Verify deletion
kubectl get all -n test-namespace
```

### 2. Destroy Terraform Infrastructure

```bash
cd terraform

# Destroy all infrastructure
terraform destroy

# Confirm when prompted by typing 'yes'
```

**Note**: This will destroy:
- EKS cluster and node groups
- VPC and all networking components
- IAM roles and policies
- NAT gateways and Elastic IPs

### 3. Manual Cleanup Steps

#### Check for remaining resources:

```bash
# Verify EKS cluster deletion
aws eks list-clusters

# Check for remaining node groups
aws eks list-nodegroups --cluster-name <cluster-name>

# Verify VPC deletion
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*<cluster-name>*"
```

#### Clean up kubectl context:

```bash
# Remove cluster from kubectl config
kubectl config delete-context arn:aws:eks:<region>:<account>:cluster/<cluster-name>

# Remove cluster from kubectl config
kubectl config delete-cluster arn:aws:eks:<region>:<account>:cluster/<cluster-name>
```

### 4. Docker Image Cleanup (Optional)

If you pushed the custom Docker image to Docker Hub:

```bash
# Remove local image
docker rmi anujmishra/k8s-test-pod:latest

# Note: To remove from Docker Hub, use the Docker Hub web interface
```

### 5. Terraform State Cleanup

```bash
cd terraform

# Remove Terraform state files (if not using remote state)
rm -f terraform.tfstate*
rm -rf .terraform/
```

### 6. Verification

Verify all resources are cleaned up:

```bash
# Check AWS resources
aws eks list-clusters
aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Name` && contains(Value, `<cluster-name>`)]]'

# Check kubectl config
kubectl config get-contexts
```

## Troubleshooting Cleanup Issues

### EKS Cluster Won't Delete

```bash
# Force delete node groups first
aws eks delete-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name>

# Wait for completion, then delete cluster
aws eks delete-cluster --name <cluster-name>
```

### VPC Won't Delete

```bash
# Check for remaining ENIs
aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=<vpc-id>"

# Check for remaining security groups
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<vpc-id>"
```

### Terraform Destroy Fails

```bash
# Try targeted destroy for specific resources
terraform destroy -target=module.eks
terraform destroy -target=module.vpc

# If state is corrupted, remove problematic resources from state
terraform state rm <resource-name>
```

## Cost Considerations

After cleanup, verify no charges are incurred:
- NAT Gateway hours
- EKS cluster hours
- EC2 instance hours
- Elastic IP addresses

Check your AWS billing dashboard to confirm all resources are terminated.
