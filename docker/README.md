# Docker Image Build and Push

## Build the image
```bash
cd docker
docker build -t anujmishra/rbac-test-pod:latest .
```

## Push to Docker Hub
```bash
docker login
docker push anujmishra/rbac-test-pod:latest
```

## Test locally
```bash
docker run -it anujmishra/rbac-test-pod:latest /bin/bash
```

## Testing Scripts

The image includes two testing scripts:
- `/scripts/test-rbac.sh` - Tests RBAC permissions
- `/scripts/test-s3.sh` - Tests S3 access

## Alternative: Manual Configuration

If you prefer not to use the custom Docker image, you can modify the `k8s/test-pod.yaml` to use a standard Ubuntu image and install tools manually:

```yaml
containers:
- name: test-container
  image: ubuntu:22.04
  command: ["/bin/bash"]
  args: ["-c", "apt-get update && apt-get install -y curl kubectl awscli && while true; do sleep 3600; done"]
```
