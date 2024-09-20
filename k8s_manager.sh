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

# Deploy an application to the Kubernetes cluster using provided YAML files
deploy_application() {
    deployment_file="$1"
    service_file="$2"
    hpa_file="$3"

    # Deploy application using the deployment YAML file if provided
    if [[ -f "$deployment_file" ]]; then
        echo "Deploying application using file: $deployment_file"
        execute_command "kubectl apply -f $deployment_file"
        echo "Application deployed successfully."
    else
        echo "Deployment YAML file not found or not provided."
    fi

    # Deploy service using the service YAML file if provided
    if [[ -f "$service_file" ]]; then
        echo "Deploying service using file: $service_file"
        execute_command "kubectl apply -f $service_file"
        echo "Service deployed successfully."
    else
        echo "Service YAML file not found or not provided."
    fi

    # Deploy HPA using the HPA YAML file if provided
    if [[ -f "$hpa_file" ]]; then
        echo "Deploying HPA using file: $hpa_file"
        execute_command "kubectl apply -f $hpa_file"
        echo "HPA deployed successfully."
    else
        echo "HPA YAML file not found or not provided."
    fi
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
    echo "  deploy              Deploy resources (requires --deploy-file, optional --service-file, --hpa-file)"
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
        deployment_file=""
        service_file=""
        hpa_file=""
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --deploy-file)
                    deployment_file="$2"
                    shift 2
                    ;;
                --service-file)
                    service_file="$2"
                    shift 2
                    ;;
                --hpa-file)
                    hpa_file="$2"
                    shift 2
                    ;;
                *)
                    show_help
                    ;;
            esac
        done
        if [ -z "$deployment_file" ]; then
            echo "Required option --deploy-file missing."
            show_help
        fi
        deploy_application "$deployment_file" "$service_file" "$hpa_file"
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
