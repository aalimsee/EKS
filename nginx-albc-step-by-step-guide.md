# 🚀 Step-by-Step Guide: Deploy NGINX App with ALB Ingress in EKS

This guide walks you through deploying an NGINX application in your EKS cluster with HTTPS access via AWS Load Balancer Controller (ALBC).

---

## 🔧 Prerequisites

- EKS cluster with IAM OIDC provider enabled
- AWS Load Balancer Controller installed
- IAM Role for Service Account (IRSA) with required permissions
- ACM Certificate for your domain (e.g., `nginx.yourdomain.com`)
- Route 53 hosted zone configured

---

## 🧱 Step 1: Create the NGINX Deployment

**`deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.27
        ports:
        - containerPort: 80
```

Apply it:

```bash
kubectl apply -f deployment.yaml
```

---

## 🔌 Step 2: Create the Service

**`service.yaml`**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  labels:
    app: nginx
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
```

Apply it:

```bash
kubectl apply -f service.yaml
```

---

## 🌐 Step 3: Create the Ingress Resource

**`ingress.yaml`**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:<ACCOUNT_ID>:certificate/<CERT_ID>
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    external-dns.alpha.kubernetes.io/hostname: nginx.yourdomain.com
spec:
  ingressClassName: alb
  rules:
  - host: nginx.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

Apply it:

```bash
kubectl apply -f ingress.yaml
```

---

## 🔍 Step 4: Verify Setup

### ✅ Check Deployment, Service, Ingress

```bash
kubectl get deployment nginx-app
kubectl get svc nginx-service
kubectl get ingress nginx-ingress -o wide
```

### ✅ Verify ALB Creation and DNS

```bash
nslookup nginx.yourdomain.com
```

- Should resolve to ALB DNS
- Check Route 53 and ACM in AWS Console

### ✅ Test App via HTTPS

```bash
curl -k https://nginx.yourdomain.com
```

---

## 🛠️ Step 5: Troubleshooting

| Problem              | Solution                                           |
|----------------------|----------------------------------------------------|
| ALB not created      | Ensure `ingressClassName: alb` is set              |
| 404 error            | Check `pathType`, service name, and port           |
| 503 error            | Check pod health and service selector              |
| Ingress stuck        | Patch to remove finalizers                         |
| No DNS resolution    | Check Route 53 record or ExternalDNS logs          |
| Invalid cert         | Check ACM certificate ARN                          |

### 🧼 Force delete stuck Ingress

```bash
kubectl patch ingress nginx-ingress -p '{"metadata":{"finalizers":[]}}' --type=merge
```

---

## 📚 References

- [AWS Load Balancer Controller Docs](https://kubernetes-sigs.github.io/aws-load-balancer-controller)
- [Kubernetes Ingress Docs](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [ACM Certificates](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)

---
> _This guide helps you deploy and expose your application securely using AWS-native networking in EKS._
