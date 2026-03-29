#!/bin/bash

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
       echo "Finished Installation: $(minikube version)"
    fi

else 
    {
        echo "DEBUGMODE=False"
    } > .env
fi

# docker build -t <your-pyspark-image> .
# kubectl apply -f k8s-config.yaml
# kubectl apply -f k8s-config.yaml
# 
# # Submit the PySpark application
# pyspark --master k8s://https://<api-server>:6443 \
#   --deploy-mode cluster \
#   --name pyspark-app \
#   --conf spark.kubernetes.namespace=pyspark \
#   --conf spark.executor.instances=2 \
#   --conf spark.executor.memory=1g \
#   --py-files main.py \
#   --conf spark.driver.bindAddress="0.0.0.0" \
#   --jars /path/to/jars/*.jar \
#   --files config.yaml \
#   main.py
# 
# fi
