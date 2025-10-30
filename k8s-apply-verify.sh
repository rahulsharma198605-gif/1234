#!/usr/bin/env bash
set -euo pipefail

echo "Applying Kubernetes manifests..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo ""
echo "Waiting for rollout to complete..."
kubectl rollout status deployment/flask-app

echo ""
echo "Listing resources..."
kubectl get deploy,po,svc -o wide

echo ""
echo "Service URL (open in browser):"
minikube service flask-service --url
