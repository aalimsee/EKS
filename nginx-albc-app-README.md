# 🌐 NGINX App with AWS Load Balancer Controller (ALBC)

This folder contains a simple example of deploying a web application (NGINX) in an EKS cluster with **ALB Ingress Controller** support using `Ingress`, `Service`, and `Deployment`.

---

## 📁 Files Overview

| File           | Purpose                                |
|----------------|----------------------------------------|
| `deployment.yaml` | Deploys 2 replicas of the NGINX app    |
| `service.yaml`    | Exposes the pods internally to the cluster |
| `ingress.yaml`    | Routes traffic from ALB to the service  |

---

## 🔄 Application Flow

```text
Internet (HTTPS)
   ↓
AWS ALB (provisioned via ALBC)
   ↓
Ingress Resource (host-based routing)
   ↓
Kubernetes Service (ClusterIP)
   ↓
Pods (NGINX containers)
```

---

## ✅ Key Sync Points Across YAMLs

| Field                        | Must Match In                |
|-----------------------------|------------------------------|
| `metadata.name` in Service  | `backend.service.name` in Ingress |
| `containerPort` in Deployment | `targetPort` in Service      |
| `labels.app` in Deployment  | `selector.app` in Service     |
| ACM Certificate ARN         | Ingress annotation            |
| Hostname in Ingress         | Route 53 DNS + ExternalDNS    |

---

## 🧪 Deployment Instructions

### 1. Apply Resources

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

### 2. Confirm ALB is Created

Check ALB controller logs:

```bash
kubectl logs -n kube-system deploy/aws-load-balancer-controller
```

### 3. Verify DNS + HTTPS

Ensure your `nginx.yourdomain.com` is correctly set up in Route 53 and ACM.

---

## 🔐 ALB Ingress Required IAM Permissions (via IRSA)

Make sure your ALB Controller has IAM permissions:

```json
{
  "Action": [
    "elasticloadbalancing:*",
    "ec2:Describe*",
    "acm:DescribeCertificate",
    "iam:CreateServiceLinkedRole"
  ],
  "Effect": "Allow",
  "Resource": "*"
}
```

---

## 📚 References

- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)
- [ACM Certificates](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)
- [Route 53 DNS](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)

---
> _This setup ensures your app is production-ready with HTTPS, DNS, and ALB integration._
