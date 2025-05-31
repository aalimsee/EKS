# 🚀 EKS + ALB + Argo CD + Terraform: Expose NGINX over HTTPS

This guide outlines the **correct order of operations** and **critical considerations** for successfully exposing an NGINX application via HTTPS on Amazon EKS using:

- AWS Load Balancer Controller (ALB Ingress)
- Argo CD for GitOps
- Terraform for IaC

---

## 🎯 Objective

Expose an NGINX application deployed in EKS over **HTTPS** using:
- ✅ Amazon Certificate Manager (ACM)
- ✅ Route 53 DNS
- ✅ ALB Ingress Controller
- ✅ IRSA for least-privilege AWS API access

---

## ✅ Setup Order Checklist

### 1. **Provision EKS & VPC using Terraform**
- Create VPC, public/private subnets, Internet Gateway
- Create EKS cluster with OIDC provider
- Create node group or enable Fargate

### 2. **Install Core Add-ons**
- `aws-load-balancer-controller` with IRSA
- `external-dns` (optional)
- `cert-manager` (optional if using automated certs)
- Confirm IRSA is working via IAM role annotation

### 3. **Provision ACM Certificate & DNS**
- Use Terraform to request ACM cert:
  - Must be in the **same region** as ALB
- Create Route 53 record to match ingress hostname

### 4. **Create Application Manifests**
- `deployment.yaml` for nginx
- `service.yaml` (ClusterIP)
- `ingress.yaml` with ALB annotations, HTTPS, hostname, and certificate ARN

### 5. **Push to Git & Deploy via Argo CD**
- Use App of Apps or single app manifest
- Make sure Argo CD has access to your Git repo
- Sync and verify deployment

### 6. **Verify**
- Check: `kubectl get ingress -o wide`
- Confirm ALB is created and accessible
- Check `curl -k https://<hostname>` returns NGINX welcome page

---

## 🛡️ IAM + IRSA Notes

- Annotate ALB controller's ServiceAccount with:

```bash
eks.amazonaws.com/role-arn=arn:aws:iam::<ACCOUNT_ID>:role/<alb-role>
```

- Role must allow:
  - `elasticloadbalancing:*`
  - `ec2:Describe*`
  - `acm:DescribeCertificate`
  - `iam:CreateServiceLinkedRole`

---

## 📁 Git Folder Structure (Recommended)

```
.
├── terraform/
│   ├── eks/
│   ├── alb/
│   ├── certs/
├── apps/
│   ├── nginx/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── ingress.yaml
├── argo/
│   ├── app-of-apps.yaml
```

---

## 🔍 Verification Commands

```bash
kubectl get all -n <nginx-namespace>
kubectl describe ingress nginx-ingress
kubectl logs -n kube-system deploy/aws-load-balancer-controller
nslookup <hostname>
```

---

## 🧪 Troubleshooting

| Symptom      | Likely Cause                       | Fix                                  |
|--------------|------------------------------------|--------------------------------------|
| ALB not created | Missing annotations or ingress class | Add `ingressClassName: alb`         |
| 404 error     | Path or service mismatch           | Confirm backend service & path       |
| 503 error     | No healthy target group            | Check pod readiness & service label  |
| DNS not resolving | Route 53 or ExternalDNS misconfigured | Update DNS or hostname            |
| Ingress stuck | Finalizer not removed              | Patch ingress to remove finalizers   |

---

## 📚 References

- [EKS IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller)
- [Argo CD](https://argo-cd.readthedocs.io)
- [Terraform AWS EKS](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest)

---

> _Use this setup to build a production-grade, GitOps-enabled EKS application with secure HTTPS access._
