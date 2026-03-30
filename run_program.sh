#!/bin/bash

# this will be set after starting kubernetes
declare -g APISERVER="tbd"

# check if docker is installed for building the image
if command -v docker &> /dev/null; then
    echo "docker installed: $(docker --version)"
else
    echo "Docker NOT installed. Installing now..."
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl start docker 2>/dev/null || true
    sudo systemctl enable docker 2>/dev/null || true
    # Verify installation
    sudo docker run hello-world
    echo "docker installed: $(docker --version)"
fi

#build the image to use in our kubernetes deployment
sudo docker build -t vulkan-benchmarks-spark-image -f ./config/Dockerfile ./config

# Install kubectl if not already
if command -v minikube &> /dev/null; then
   echo "kubectl installed: $(kubectl version --client)"
else 
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm ./kubectl ./kubectl.sha256
    kubectl version --client
fi

# Debug mode = using minicube for testing
if [[ "$1" = "debug" ]]; then
    # set to debug mode for local testing
    echo "Debug mode enabled"
    { 
        echo "DEBUGMODE=True"
    } > .env

    #ensure that minicube is installed, if not then install

    if command -v minikube &> /dev/null; then
       echo "Minikube installed: $(minikube version)"
    else 
       echo "Minikube NOT installed, therefore installing now..."
       curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
       sudo rpm -Uvh minikube-latest.x86_64.rpm
       rm minikube-latest.x86_64.rpm 
       sudo usermod -aG docker $USER && newgrp docker
       echo "Finished Installation: $(minikube version)"
    fi

    minikube start --driver=docker
    kubectl apply -f ./config/k8s-config.yaml
    kubectl get crd --all-namespaces
    kubectl api-versions | grep rbac
    kubectl get pods -n kube-system | grep 'kube-'
    kubectl cluster-info
    APISERVER=$(kubectl cluster-info | grep 'control plane' | sed -E 's/.*https:\/\/(.*)/\1/')
else 
    {
        echo "DEBUGMODE=False"
    } > .env
fi

# run binaries on the master machine first
pwd
mkdir -p ./config/binaries/logs/
cd ./config/binaries/
for f in ./*; do 
    chmod +x $f && ./$f & 
done
cd ../..

python3 ./python/main.py $APISERVER

if ! minikube status | grep -q "Running"; then
    echo "Minikube is not running"
    #place the production command here
else
    minikube stop
fi
