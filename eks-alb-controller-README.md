## 🌐 AWS Load Balancer Controller (ALB Ingress)

Use these commands to inspect and troubleshoot the AWS Load Balancer Controller (ALB Ingress Controller) in your EKS cluster.

---

### ✅ 1. Check ALB Controller Deployment

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

> Ensures that the controller is running properly in the `kube-system` namespace.

---

### 🧾 2. View ALB Controller Logs

```bash
kubectl logs -n kube-system deploy/aws-load-balancer-controller
```

> Helpful for troubleshooting ALB provisioning, target group issues, or annotation errors.

---

### 🔍 3. Inspect Ingress Resources

```bash
kubectl get ingress --all-namespaces -o wide
kubectl describe ingress <ingress-name> -n <namespace>
```

> Confirm the ingress configuration and annotations such as:

```yaml
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...
```

---

### 🧰 4. Validate with AWS CLI

```bash
aws elbv2 describe-load-balancers --region <region>
aws elbv2 describe-target-groups --region <region>
```

> Cross-check ALB and target groups created by the controller.

---

### 🛠️ 5. If Installed via Helm

```bash
helm list -n kube-system
```

> List Helm releases to confirm how the controller was deployed.

---

> _This section helps validate proper functioning of your ALB Ingress Controller and troubleshoot if issues arise._
