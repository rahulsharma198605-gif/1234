# Apply + verify for Windows PowerShell
$ErrorActionPreference = "Stop"

Write-Host "Applying Kubernetes manifests..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

Write-Host ""
Write-Host "Waiting for rollout to complete..."
kubectl rollout status deployment/flask-app

Write-Host ""
Write-Host "Listing resources..."
kubectl get deploy,po,svc -o wide

Write-Host ""
Write-Host "Service URL (open in browser):"
minikube service flask-service --url
