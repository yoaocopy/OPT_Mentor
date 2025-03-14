
# JupyterLite Deployment

This repository contains the necessary files to deploy JupyterLite on a Kubernetes cluster. Below is a brief description of each file and instructions on how to deploy the application.

## Files

- **jupyterlite-ingress.yaml**: Defines the Ingress resource for routing external traffic to the JupyterLite service.
- **jupyterlite-deployment.yaml**: Contains the Deployment and Service definitions for running JupyterLite.
- **jupyterlite-cert.yaml**: Configures the ClusterIssuer for obtaining TLS certificates from Let's Encrypt.
- **Dockerfile**: Provides the Dockerfile used to build the JupyterLite image. This is for reference only, as the Docker image can be pulled from DockerHub.

## Deployment Instructions

1. **Apply the ClusterIssuer**:
    ```sh
    kubectl apply -f /path/to/jupyterlite-cert.yaml
    ```

2. **Deploy the JupyterLite application**:
    ```sh
    kubectl apply -f /path/to/jupyterlite-deployment.yaml
    ```

3. **Set up the Ingress**:
    ```sh
    kubectl apply -f /path/to/jupyterlite-ingress.yaml
    ```

4. **Verify the deployment**:
    - Ensure all pods are running:
        ```sh
        kubectl get pods
        ```
    - Check the Ingress resource:
        ```sh
        kubectl get ingress
        ```
    - Check all status:
        ```sh
        kubectl get pods,svc,ingress
        ```

## Docker Image

The Docker image for JupyterLite is available on DockerHub and can be pulled using the following command:
```sh
docker pull dzifanng/jup-opm
```

This image is used in the `jupyterlite-deployment.yaml` file and does not require building the Dockerfile locally.

## Accessing JupyterLite

Once the deployment is complete, you can access JupyterLite at `https://deep.cs.cityu.edu.hk/optmentor/jupyterlite`.

