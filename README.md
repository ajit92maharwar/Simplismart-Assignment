**Usage Guidelines**

The script supports four main operations: init, install, deploy, and status.
Test Case 1. Initialize Kubernetes Cluster
Use the init command to set up a new Kubernetes cluster. This will initialize the control plane and set the network CIDR for Flannel (or another CNI) to 10.244.0.0/16.

Command:
./k8s_manager.sh init

This will:
•	Run kubeadm init to initialize the cluster.
•	Output the necessary join command for worker nodes (save this for future use).

-------------------------------------------------------------------------------------------------------------------------------------------
Test Case 2. Install Helm and Metrics Server
Use the install command to install the Helm package manager and Kubernetes Metrics Server. Helm is required for deploying charts, and the Metrics Server is necessary for gathering resource metrics.
Command:
./k8s_manager.sh install

This will:
•	Install Helm by running a script from Helm’s official repository.
•	Add the Bitnami Helm chart repository.
•	Install the Kubernetes Metrics Server using the official YAML.

-------------------------------------------------------------------------------------------------------------------------------------------
Test Case 3. Deploy an Application
Use the deploy command to deploy an application to your Kubernetes cluster. The command requires several options for app name, container image, number of replicas, and resource limits (CPU and memory).

./k8s_manager.sh deploy --app <app_name> --image <image> --replicas <num_replicas> --cpu <cpu_limit> --memory <memory_limit>

Example:
./k8s_manager.sh deploy --app my-app --image nginx --replicas 2 --cpu 250m --memory 256Mi

This will:
•	Create a deployment YAML file and apply it via kubectl.
•	The application will be deployed with the specified configuration.

-------------------------------------------------------------------------------------------------------------------------------------------
Test Case 4. Check the Status of a Deployment
Use the status command to check the status of a specific deployment in the cluster.

./k8s_manager.sh status --deployment <deployment_name>

Example
./k8s_manager.sh status --deployment my-app
This will:
•	Retrieve and display the status of the specified deployment using kubectl get deployment.

-------------------------------------------------------------------------------------------------------------------------------------------
Test Case 5: Checking the Status of a Deployment
Description: Verify the script correctly fetches the status of a deployed application.
Command:./k8s_manager.sh status --deployment my-app
Expected Result:

    The script should display the status of the my-app deployment.
    The output should display:

Fetching status for deployment: my-app
Running command: kubectl get deployment my-app
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
my-app    2/2     2            2           5m

-------------------------------------------------------------------------------------------------------------------------------------------
Test Case 6: Handling Invalid Deployment ID for Status
Description: Verify the script handles non-existent or invalid deployment IDs gracefully.
Command:./k8s_manager.sh status --deployment non-existent-app
Expected Result:

    The script should attempt to fetch the status and return an error message.
    The output should display:
Fetching status for deployment: non-existent-app
Running command: kubectl get deployment non-existent-app
Error running command: kubectl get deployment non-existent-app

-------------------------------------------------------------------------------------------------------------------------------------------

Test Case 7: Ensure Proper Usage Handling
Description: Verify that the script shows usage instructions when an invalid command is passed.
Command:./k8s_manager.sh invalid_command

Expected Result:

    The script should display the usage instructions.
    The output should display:
    Usage: ./k8s_manager.sh {init|install|deploy|status}
-------------------------------------------------------------------------------------------------------------------------------------------
Test Case 8: Verify Resource Limits in the Deployed Application
Description: After deploying the application, check that the specified CPU and memory limits are correctly applied.
Command: ./k8s_manager.sh deploy --app resource-app --image nginx --replicas 1 --cpu 200m --memory 128Mi
Expected Result:

    The application resource-app should be deployed with 1 replica.
    The pod should have CPU limits of 200m and memory limits of 128Mi.
-------------------------------------------------------------------------------------------------------------------------------------------
