Kubernetes Deploy Pack (Deployment + Service + Apply & Verify)
===================================================================

FILES
-----
1) deployment.yaml  -> Runs 2 replicas of your Flask app container (rahul5553/1234:latest)
2) service.yaml     -> Exposes the app via NodePort 30080 inside minikube
3) k8s-apply-verify.sh  -> Bash helper (Git Bash)
4) k8s-apply-verify.ps1 -> PowerShell helper (Windows)

PREREQS
-------
- Docker image pushed: rahul5553/1234:latest
- minikube is running
- kubectl is configured to minikube context

QUICK START
-----------
Git Bash:
  ./k8s-apply-verify.sh

PowerShell:
  ./k8s-apply-verify.ps1

WHAT THE DOCKER COMMANDS DO
---------------------------
1) docker build -t rahul5553/1234:v1 -t rahul5553/1234:latest .
   - 'docker build' creates an image from Dockerfile in the current folder ('.')
   - '-t' means 'tag'; you can apply one or more tags in name:tag form
     * 'rahul5553/1234:v1'  -> versioned tag
     * 'rahul5553/1234:latest' -> moving tag for the newest stable build
   - Multiple '-t' flags tag the same built image with multiple names.

2) docker run -d -p 5000:5000 --name flaskdemo rahul5553/1234:latest
   - Runs a container from the image in the background (-d)
   - Maps host port 5000 to container port 5000 (-p HOST:CONTAINER)
   - Gives the container a friendly name (--name)
   - After this, open http://localhost:5000 to test locally.

3) docker login -u rahul5553
   - Authenticates your Docker CLI to Docker Hub so pushes are allowed.

4) docker push rahul5553/1234:v1  (and :latest)
   - Uploads the tagged image to Docker Hub.

5) docker ps / docker images
   - 'docker ps' lists running containers.
   - 'docker images' lists images present locally.

WHAT THE KUBERNETES COMMANDS DO
-------------------------------
- kubectl apply -f deployment.yaml / service.yaml
  Creates or updates K8s resources from the YAML files.

- kubectl rollout status deployment/flask-app
  Waits until the deployment is fully rolled out (pods ready).

- kubectl get deploy,po,svc -o wide
  Lists deployments (deploy), pods (po), and services (svc) with extra details.

- minikube service flask-service --url
  Prints a local URL that forwards to the NodePort service inside minikube.
  Open this URL in your browser to reach the Flask app.
