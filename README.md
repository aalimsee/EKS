# EKS
Understanding EKS

# 🧠 Understanding Your AWS EKS Cluster Setup

This guide provides essential kubectl, aws, and eksctl commands to help you inspect and understand the configuration of your Amazon EKS cluster.

📌 1. Cluster Overview
bash
kubectl cluster-info
kubectl version --short
kubectl get nodes -o wide
View API server details

Confirm node health, versions, and AZ placement

📌 2. List Namespaces and All Resources
bash
Copy
Edit
kubectl get namespaces
kubectl get all --all-namespaces
Get a holistic view of all workloads running in your cluster

📌 3. EKS Cluster Details (AWS CLI)
bash
Copy
Edit
aws eks list-clusters
aws eks describe-cluster --name <your-cluster-name> --region <region> --output table
Review control plane settings, endpoint access, logging, and cluster version

📌 4. IAM & Access Control
bash
Copy
Edit
kubectl describe configmap aws-auth -n kube-system
kubectl get serviceaccounts --all-namespaces
Check which IAM roles are mapped to Kubernetes access

Inspect use of IRSA (IAM Roles for Service Accounts)

📌 5. Ingress & Services
bash
Copy
Edit
kubectl get ingress --all-namespaces
kubectl get svc --all-namespaces
See how apps are exposed: LoadBalancer, NodePort, or Ingress Controller

📌 6. Storage Setup
bash
Copy
Edit
kubectl get sc
kubectl get pvc --all-namespaces
Inspect StorageClasses (e.g., EBS, EFS) and usage by workloads

📌 7. System Components (kube-system)
bash
Copy
Edit
kubectl get pods -n kube-system
Monitor cluster-level components: CoreDNS, kube-proxy, cni, aws-node

📌 8. Custom Resources
bash
Copy
Edit
kubectl get crds
Validate CRDs installed by tools like Argo CD, cert-manager, ALB Controller, etc.

📌 9. Helm (if used)
bash
Copy
Edit
helm list -A
List all Helm-deployed resources across namespaces

📌 10. Argo CD (Optional: GitOps)
bash
Copy
Edit
kubectl get applications -n argocd
View apps synced by Argo CD (if GitOps is configured)

📌 Bonus: IAM Identity Mappings (eksctl)
bash
Copy
Edit
eksctl get iamidentitymapping --cluster <cluster-name> --region <region>
List IAM users/roles with access to your cluster via aws-auth

📂 Pro Tip: Export All Resources to YAML
bash
Copy
Edit
kubectl get all --all-namespaces -o yaml > eks-dump.yaml
Use this for backup, auditing, or documentation.

📎 Related
Amazon EKS Documentation

eksctl GitHub

Argo CD GitOps

