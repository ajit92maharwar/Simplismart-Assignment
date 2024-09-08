#!/bin/bash

# Helper function to run commands and handle any errors
execute_command() {
    cmd="$1"
    echo "Executing: $cmd"
    eval "$cmd"
    if [ $? -ne 0 ]; then
        echo "Failed to execute: $cmd"
        exit 1
    fi
}

# Initialize Kubernetes cluster with a specific pod network
setup_k8s_cluster() {
    echo "Setting up Kubernetes cluster..."
    execute_command "kubeadm init --pod-network-cidr=10.244.0.0/16"
    echo "Kubernetes cluster setup complete."
}

# Install Helm and Kubernetes Metrics Server
install_tools() {
    echo "Installing Helm..."
    execute_command "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    execute_command "helm repo add bitnami https://charts.bitnami.com/bitnami"
    execute_command "helm repo update"

    echo "Installing Metrics Server..."
    execute_command "kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml"
    echo "Tools installed successfully."
}

# Deploy a specified application to the Kubernetes cluster
deploy_application() {
    app="$1"
    container_image="$2"
    num_replicas="$3"
    cpu_limit="$4"
    memory_limit="$5"

    echo "Deploying app: $app with $num_replicas replicas..."

    # Generate deployment file
    cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $app
spec:
  replicas: $num_replicas
  selector:
    matchLabels:
      app: $app
  template:
    metadata:
      labels:
        app: $app
    spec:
      containers:
      - name: $app
        image: $container_image
        resources:
          limits:
            cpu: $cpu_limit
            memory: $memory_limit
EOF

    execute_command "kubectl apply -f deployment.yaml"
    echo "Application $app deployed successfully."
}

# Check the status of a specific deployment
check_deployment_status() {
    deployment_name="$1"
    echo "Checking status for deployment: $deployment_name"
    execute_command "kubectl get deployment $deployment_name"
}

# Display usage information
show_help() {
    echo "Usage: $0 {init|install|deploy|status}"
    echo "Available commands:"
    echo "  init                Initialize Kubernetes cluster"
    echo "  install             Install Helm and Metrics Server"
    echo "  deploy              Deploy an app (requires options)"
    echo "      Options: --app <name> --image <image> --replicas <num> --cpu <cpu> --memory <mem>"
    echo "  status              Get the status of a deployment (requires --deployment)"
    exit 1
}

# Handle script arguments
case "$1" in
    init)
        setup_k8s_cluster
        ;;
    install)
        install_tools
        ;;
    deploy)
        shift
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --app)
                    app_name="$2"
                    shift 2
                    ;;
                --image)
                    container_image="$2"
                    shift 2
                    ;;
                --replicas)
                    replicas="$2"
                    shift 2
                    ;;
                --cpu)
                    cpu="$2"
                    shift 2
                    ;;
                --memory)
                    memory="$2"
                    shift 2
                    ;;
                *)
                    show_help
                    ;;
            esac
        done
        if [ -z "$app_name" ] || [ -z "$container_image" ] || [ -z "$replicas" ] || [ -z "$cpu" ] || [ -z "$memory" ]; then
            echo "Required options missing for deploy."
            show_help
        fi
        deploy_application "$app_name" "$container_image" "$replicas" "$cpu" "$memory"
        ;;
    status)
        shift
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --deployment)
                    deployment_name="$2"
                    shift 2
                    ;;
                *)
                    show_help
                    ;;
            esac
        done
        if [ -z "$deployment_name" ]; then
            echo "Missing deployment name."
            show_help
        fi
        check_deployment_status "$deployment_name"
        ;;
    *)
        show_help
        ;;
esac

