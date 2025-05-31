# 🔄 How ALBC and ExternalDNS Work in the Background

Both **AWS Load Balancer Controller (ALBC)** and **ExternalDNS** operate as controllers within your EKS cluster. They continuously monitor specific Kubernetes resources and perform AWS-side actions to automatically support application deployment and cluster setup.

---

## 🧠 Controller Overview

| Controller      | Monitors Resource(s)               | AWS Action Performed                             |
|-----------------|-------------------------------------|--------------------------------------------------|
| **ALBC**        | Ingress, Service                    | Creates & updates **Application Load Balancers** |
| **ExternalDNS** | Ingress, Service with annotations   | Creates & updates **Route 53 DNS records**       |

---

## 🚀 Workflow in Action

### 1. Deploy Kubernetes Ingress with Annotations

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    external-dns.alpha.kubernetes.io/hostname: app.yourdomain.com
spec:
  ingressClassName: alb
  rules:
    - host: app.yourdomain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app-service
                port:
                  number: 80
```

---

### 2. ALB Controller Actions

- Detects Ingress with `ingressClassName: alb`
- Creates an **ALB** in your VPC
- Sets up listeners (80/443)
- Configures target groups pointing to your app pods

✅ Keeps the ALB synced with your Ingress config

---

### 3. ExternalDNS Actions

- Detects annotation: `external-dns.alpha.kubernetes.io/hostname`
- Queries the ALB hostname provisioned by ALBC
- Uses AWS API to create a DNS `A` record:
  ```
  app.yourdomain.com → abc123.elb.amazonaws.com
  ```

✅ Keeps Route 53 DNS updated automatically

---

## 🔁 Continuous Reconciliation

Both controllers:
- Monitor changes (new/updated/deleted Ingresses or Services)
- Automatically update ALB and Route 53 to match current state
- Eliminate need for manual AWS console interaction

---

## 🧠 Why This Matters

| Benefit                       | Description                                         |
|------------------------------|-----------------------------------------------------|
| 🔧 **Automation**             | Infra is provisioned automatically on deployment   |
| 🔁 **Self-healing**           | Controllers fix drift or recreate missing resources |
| 📦 **GitOps Ready**           | Declarative manifests drive real AWS infrastructure|
| 🔒 **Least privilege access** | Via IRSA, each controller uses scoped IAM roles    |

---

## 📚 References

- [AWS Load Balancer Controller Docs](https://kubernetes-sigs.github.io/aws-load-balancer-controller)
- [ExternalDNS Docs](https://github.com/kubernetes-sigs/external-dns)
- [Kubernetes Ingress Concepts](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Route 53 Developer Guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)

---

> _ALBC and ExternalDNS are critical background agents that turn Kubernetes manifests into working, secure, and scalable AWS infrastructure._
