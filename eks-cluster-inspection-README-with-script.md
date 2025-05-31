# 🔍 Explore & Understand Your AWS EKS Cluster

This repository provides tools to inspect and understand the components and setup of your **Amazon EKS cluster** using `kubectl`, `aws`, and `eksctl`.

---

## 🚀 Quick Start

Use the provided script to inspect your EKS cluster:

### 🔧 `eks-inspect.sh`

```bash
chmod +x eks-inspect.sh
./eks-inspect.sh
```

This script outputs:

- Cluster and node info
- All running workloads
- IAM roles and access (IRSA)
- Ingresses and Services
- Persistent volumes and StorageClasses
- System components (CoreDNS, kube-proxy, etc.)
- Custom Resource Definitions
- Helm releases (if any)
- Argo CD apps (if installed)
- IAM identity mappings
- Backup command for all resources

---

## 📚 References

- 📘 [Amazon EKS Docs](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- 🛠️ [eksctl GitHub](https://github.com/weaveworks/eksctl)
- 🚀 [Argo CD Docs](https://argo-cd.readthedocs.io/)

---

> _Use this repo to baseline your EKS setup and as a template for operational audits._  
