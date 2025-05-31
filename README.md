# EKS
Understanding EKS


markdown
Copy
Edit
# 🔍 Explore & Understand Your AWS EKS Cluster

This repository provides a quick reference to inspect and understand the components and setup of your **Amazon EKS cluster** using `kubectl`, `aws`, and `eksctl`.

---

## 📌 1. Cluster Overview

```bash
kubectl cluster-info
kubectl version --short
kubectl get nodes -o wide
🔸 View API server URL, K8s version, node instance types, and availability zones.

📌 2. Namespaces and Workloads
bash
Copy
Edit
kubectl get namespaces
kubectl get all --all-namespaces
🔸 Lists workloads (pods, deployments, services, etc.) across all namespaces.

📌 3. EKS Cluster (AWS CLI)
bash
Copy
Edit
aws eks list-clusters
aws eks describe-cluster --name <your-cluster-name> --region <region> --output table
🔸 Displays control plane config, endpoint access, IAM roles, and logging options.

📌 4. IAM & Access Mapping (IRSA / aws-auth)
bash
Copy
Edit
kubectl describe configmap aws-auth -n kube-system
kubectl get serviceaccounts --all-namespaces
🔸 Check IAM to Kubernetes role bindings and service account-based access.

📌 5. Networking: Ingress & Services
bash
Copy
Edit
kubectl get ingress --all-namespaces
kubectl get svc --all-namespaces
🔸 View ingress rules and how services are exposed (LoadBalancer, NodePort, etc.).

📌 6. Persistent Storage
bash
Copy
Edit
kubectl get pvc --all-namespaces
kubectl get sc
🔸 View PersistentVolumeClaims and available StorageClasses (EBS, EFS, etc.).

📌 7. System-Level Components
bash
Copy
Edit
kubectl get pods -n kube-system
🔸 Validate components like CoreDNS, kube-proxy, aws-node, and CNI plugins.

📌 8. Custom Resources
bash
Copy
Edit
kubectl get crds
🔸 Inspect Custom Resource Definitions installed by tools like:

Argo CD

AWS Load Balancer Controller

cert-manager

📌 9. Helm Charts (Optional)
bash
Copy
Edit
helm list -A
🔸 List Helm releases across all namespaces (if Helm is used).

📌 10. Argo CD GitOps (Optional)
bash
Copy
Edit
kubectl get applications -n argocd
🔸 Shows GitOps-synced applications using Argo CD.

📌 Bonus: IAM Identity Mappings (eksctl)
bash
Copy
Edit
eksctl get iamidentitymapping --cluster <cluster-name> --region <region>
🔸 Displays all IAM users/roles mapped via aws-auth for cluster access.

🧰 Dump All Cluster Resources (Backup or Audit)
bash
Copy
Edit
kubectl get all --all-namespaces -o yaml > eks-cluster-backup.yaml
📚 References
📘 Amazon EKS Official Docs

🛠️ eksctl GitHub

🚀 Argo CD Docs

