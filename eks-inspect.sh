#!/bin/bash

# Ensure you have kubectl, awscli, and eksctl installed and configured.

echo "=== 1. Cluster Info ==="
kubectl cluster-info
kubectl version --short
kubectl get nodes -o wide

echo -e "\n=== 2. Namespaces & Workloads ==="
kubectl get namespaces
kubectl get all --all-namespaces

echo -e "\n=== 3. IAM & Access Control ==="
kubectl describe configmap aws-auth -n kube-system
kubectl get serviceaccounts --all-namespaces

echo -e "\n=== 4. Networking: Ingress & Services ==="
kubectl get ingress --all-namespaces
kubectl get svc --all-namespaces

echo -e "\n=== 5. Persistent Volumes ==="
kubectl get pvc --all-namespaces
kubectl get sc

echo -e "\n=== 6. System Components (kube-system) ==="
kubectl get pods -n kube-system

echo -e "\n=== 7. Custom Resource Definitions (CRDs) ==="
kubectl get crds

echo -e "\n=== 8. Helm Releases (if used) ==="
helm list -A

echo -e "\n=== 9. Argo CD Apps (if Argo is installed) ==="
kubectl get applications -n argocd

echo -e "\n=== 10. IAM Identity Mappings (via eksctl) ==="
echo "eksctl get iamidentitymapping --cluster <your-cluster-name> --region <your-region>"

echo -e "\n=== Backup All Resources ==="
echo "kubectl get all --all-namespaces -o yaml > eks-cluster-backup.yaml"
