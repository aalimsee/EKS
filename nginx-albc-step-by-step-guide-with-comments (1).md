# 🚀 Step-by-Step Guide: Deploy NGINX App with ALB Ingress in EKS

This guide walks you through deploying an NGINX application in your EKS cluster with HTTPS access via AWS Load Balancer Controller (ALBC), including value sync notes and troubleshooting.

---

## 🔧 Prerequisites

- ✅ EKS cluster with IAM OIDC provider enabled
- ✅ AWS Load Balancer Controller installed
- ✅ IAM Role for Service Account (IRSA) with ALB permissions
- ✅ ACM Certificate for your domain (e.g., `nginx.yourdomain.com`)
- ✅ Route 53 public hosted zone setup

---

## 🧱 Step 1: Create the NGINX Deployment

**`deployment.yaml`**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app  # 🔄 Must match label selectors in service.yaml
  labels:
    app: nginx      # 🔄 Used by service.selector and should match
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx    # 🔄 This must match pod template labels
  template:
    metadata:
      labels:
        app: nginx  # 🔄 Must match service.selector
    spec:
      containers:
      - name: nginx
        image: nginx:1.27  # 📌 Use your custom image if needed
        ports:
        - containerPort: 80  # 🔄 Must match service.targetPort
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
  name: nginx-service  # 🔄 Must match backend.service.name in ingress.yaml
  labels:
    app: nginx
spec:
  type: ClusterIP  # ✅ Required for ALB target-type = ip
  ports:
  - port: 80
    targetPort: 80  # 🔄 Must match containerPort in deployment.yaml
  selector:
    app: nginx  # 🔄 Must match pod labels from deployment.yaml
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
    alb.ingress.kubernetes.io/target-type: ip  # ✅ Pod targeting (preferred for Fargate)
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:<ACCOUNT_ID>:certificate/<CERT_ID>  # 🔐 Replace with your ACM cert
    alb.ingress.kubernetes.io/ssl-redirect: '443'
    external-dns.alpha.kubernetes.io/hostname: nginx.yourdomain.com  # 🔄 Must match DNS zone in Route 53
spec:
  ingressClassName: alb  # ✅ Must be set for ALB Controller to pick up
  rules:
  - host: nginx.yourdomain.com  # 🔄 Must match ACM cert and Route 53 record
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service  # 🔄 Must match metadata.name in service.yaml
            port:
              number: 80  # 🔄 Must match service.spec.ports.port
```

Apply it:

```bash
kubectl apply -f ingress.yaml
```

---

## 🔍 Step 4: Verify Setup

### ✅ Check K8s Resources

```bash
kubectl get deployment nginx-app
kubectl get svc nginx-service
kubectl get ingress nginx-ingress -o wide
```

### 🌐 Verify ALB & DNS

```bash
nslookup nginx.yourdomain.com
```

- Should resolve to an AWS-managed ALB DNS name
- Confirm Route 53 + ACM setup in AWS Console

### 🌐 Test HTTPS

```bash
curl -k https://nginx.yourdomain.com
```

---

## 🛠️ Step 5: Troubleshooting

| Symptom              | Possible Cause                                | Fix                                               |
|----------------------|------------------------------------------------|----------------------------------------------------|
| ALB not created      | Missing `ingressClassName`, bad annotations   | Add class + valid ALB annotations                 |
| 404 error            | Path/service mismatch                         | Confirm service name and `pathType: Prefix`       |
| 503 error            | No healthy backend pods                       | Check pod readiness and label selectors           |
| Ingress stuck        | Finalizer prevents deletion                   | See cleanup command below                         |
| DNS doesn’t resolve  | Missing Route 53 entry                        | Ensure ExternalDNS or manual setup is correct     |

---

### 🧼 Force Delete a Stuck Ingress

```bash
kubectl patch ingress nginx-ingress -p '{"metadata":{"finalizers":[]}}' --type=merge
```

---

## 📚 References

- [AWS Load Balancer Controller Docs](https://kubernetes-sigs.github.io/aws-load-balancer-controller)
- [ACM Certificates](https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html)
- [Route 53 Hosted Zones](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)

---

> _Follow this guide to deploy a public HTTPS application on EKS using ALB Ingress and validate each layer for reliability._

---

## 🧱 Optional: Provision ACM, DNS, and Ingress Resources with Terraform

If you'd like to manage your infrastructure with Terraform, here's an example snippet to create:

### ✅ ACM Certificate

```hcl
resource "aws_acm_certificate" "nginx_cert" {
  domain_name       = "nginx.yourdomain.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }
}
```

### ✅ Route 53 DNS Record for ExternalDNS

```hcl
resource "aws_route53_record" "nginx" {
  zone_id = var.hosted_zone_id
  name    = "nginx.yourdomain.com"
  type    = "A"

  alias {
    name                   = aws_lb.nginx_alb.dns_name
    zone_id                = aws_lb.nginx_alb.zone_id
    evaluate_target_health = true
  }
}
```

### ✅ IAM Role for ALB Controller (IRSA)

```hcl
resource "aws_iam_role" "alb_controller" {
  name = "alb-controller-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "alb_policy" {
  name   = "ALBControllerPolicy"
  policy = file("alb-policy.json") # standard ALB controller permissions
}

resource "aws_iam_role_policy_attachment" "attach_alb_policy" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_policy.arn
}
```

> 🛡️ Ensure this IAM role is annotated to the ALB controller's Kubernetes ServiceAccount.

---

> _Terraform helps automate provisioning of DNS records, TLS certificates, and IRSA roles for consistent and repeatable deployments._
