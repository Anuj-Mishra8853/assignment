FROM ubuntu:22.04

# Install required tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws/

# Create test scripts
WORKDIR /scripts
COPY test-rbac.sh .
COPY test-s3.sh .
RUN chmod +x *.sh

# Set working directory
WORKDIR /

# Keep container running
CMD ["/bin/bash", "-c", "while true; do sleep 3600; done"]
