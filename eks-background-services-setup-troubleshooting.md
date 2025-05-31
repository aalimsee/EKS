# ⚙️ EKS Background Services: Setup & Troubleshooting Guide

This guide covers setup steps and common troubleshooting tips for the essential background services (controllers) running in an Amazon EKS cluster.

---

## 🔄 1. AWS Load Balancer Controller (ALBC)

### ✅ Setup
- Install via Helm
- IRSA role must allow ELB, ACM, EC2, IAM actions
- Annotate Ingress resources with ALB-specific annotations

```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller   -n kube-system   --set clusterName=<cluster-name>   --set serviceAccount.create=false   --set serviceAccount.name=aws-load-balancer-controller   --set region=<region>
```

### 🧪 Troubleshooting
| Issue               | Fix                                                           |
|---------------------|----------------------------------------------------------------|
| ALB not created     | Check `ingressClassName`, required annotations, and logs       |
| 503 errors          | Verify service/pod readiness and target group health           |
| AccessDenied errors | Check IRSA role permissions via CloudTrail or ALBC logs        |

---

## 🌐 2. ExternalDNS

### ✅ Setup
- Install via Helm
- IRSA role must allow Route 53 actions
- Annotate Ingress with `external-dns.alpha.kubernetes.io/hostname`

```bash
helm install external-dns bitnami/external-dns   --namespace kube-system   --set provider=aws   --set aws.zoneType=public   --set txtOwnerId=external-dns   --set policy=upsert-only
```

### 🧪 Troubleshooting
| Issue                     | Fix                                                         |
|---------------------------|--------------------------------------------------------------|
| No DNS record created     | Check hostname annotation and IRSA IAM role                 |
| Record deleted unexpectedly | Use `policy=upsert-only` to prevent accidental deletions |
| Logs show AccessDenied    | Check role permissions in AWS and annotation in SA          |

---

## 📜 3. cert-manager

### ✅ Setup
- Install CRDs and Helm chart
- Use for TLS management with ACM or Let's Encrypt

```bash
kubectl apply --validate=false -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

### 🧪 Troubleshooting
| Issue                    | Fix                                                          |
|--------------------------|---------------------------------------------------------------|
| Certificate not issued   | Check Issuer/ClusterIssuer configuration                     |
| Challenge failed         | Verify DNS-01 or HTTP-01 challenge and Ingress configuration |

---

## 🚀 4. Argo CD

### ✅ Setup
- Deploy via Helm or YAML
- Connect to Git repo with apps declared as `Application` manifests

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 🧪 Troubleshooting
| Issue                    | Fix                                                          |
|--------------------------|---------------------------------------------------------------|
| App out-of-sync          | Check Git branch or path, re-sync manually                   |
| Repo access denied       | Confirm SSH/HTTPS credentials and Git repo URL               |
| Sync errors              | Inspect pod logs, Argo UI, and resource health status        |

---

## 📊 5. Prometheus & Metrics Server

### ✅ Setup
- Metrics Server is a must for HPA
- Prometheus + Grafana for observability (via kube-prometheus-stack)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 🧪 Troubleshooting
| Issue                          | Fix                                                       |
|--------------------------------|------------------------------------------------------------|
| HPA not working                | Check if Metrics Server is installed and reporting         |
| Prometheus scrape failed       | Verify pod annotations and service discovery labels        |

---

## 🔐 6. IRSA (IAM Roles for Service Accounts)

### ✅ Setup
- Enable OIDC on the cluster
- Create IAM roles with federated trust and annotate ServiceAccounts

```bash
eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>
```

### 🧪 Troubleshooting
| Issue               | Fix                                                           |
|---------------------|----------------------------------------------------------------|
| AccessDenied        | Check IAM trust policy, OIDC provider ID, and annotations     |
| Role not assumed    | Validate the ServiceAccount is being used in pod spec         |

---

## 📚 References

- [EKS Add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller)
- [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)
- [cert-manager](https://cert-manager.io/docs/)
- [Argo CD Docs](https://argo-cd.readthedocs.io/)
- [Kubernetes Metrics Server](https://github.com/kubernetes-sigs/metrics-server)

---

> _These services power automation, visibility, scalability, and security for your EKS applications. Keep them healthy and correctly configured._
