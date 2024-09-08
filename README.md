**Usage Guidelines**

The script supports four main operations: init, install, deploy, and status.
1. Initialize Kubernetes Cluster
Use the init command to set up a new Kubernetes cluster. This will initialize the control plane and set the network CIDR for Flannel (or another CNI) to 10.244.0.0/16.

Command:
./k8s_deployment.sh init

This will:
	•	Run kubeadm init to initialize the cluster.
	•	Output the necessary join command for worker nodes (save this for future use).

2. Install Helm and Metrics Server
Use the install command to install the Helm package manager and Kubernetes Metrics Server. Helm is required for deploying charts, and the Metrics Server is necessary for gathering resource metrics.
Command:
./k8s_deployment.sh install

This will:
	•	Install Helm by running a script from Helm’s official repository.
	•	Add the Bitnami Helm chart repository.
	•	Install the Kubernetes Metrics Server using the official YAML.

3. Deploy an Application
Use the deploy command to deploy an application to your Kubernetes cluster. The command requires several options for app name, container image, number of replicas, and resource limits (CPU and memory).

./k8s_deployment.sh deploy --app <app_name> --image <image> --replicas <num_replicas> --cpu <cpu_limit> --memory <memory_limit>

Example:
./k8s_deployment.sh deploy --app my-app --image nginx --replicas 2 --cpu 250m --memory 256Mi

This will:
	•	Create a deployment YAML file and apply it via kubectl.
	•	The application will be deployed with the specified configuration.

4. Check the Status of a Deployment
Use the status command to check the status of a specific deployment in the cluster.

./k8s_deployment.sh status --deployment <deployment_name>

Example
./k8s_deployment.sh status --deployment my-app
This will:
	•	Retrieve and display the status of the specified deployment using kubectl get deployment.




