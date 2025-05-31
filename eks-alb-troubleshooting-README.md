# 🛠️ EKS ALB Controller & Ingress Troubleshooting Guide

Use this guide to troubleshoot and confirm your ALB Ingress setup with AWS Load Balancer Controller (ALBC).

---

## ✅ 1. Confirm ALB Controller Deployment

```bash
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

---

## 🔍 2. Inspect Ingress Resource

```bash
kubectl describe ingress <ingress-name> -n <namespace>
```

- Check ALB annotations
- Confirm correct host and certificate ARN
- Ensure backend service and port are correct

---

## 📜 3. Check ALB Controller Logs

```bash
kubectl logs -n kube-system deploy/aws-load-balancer-controller
```

---

## 🌐 4. Validate DNS Resolution

```bash
nslookup <hostname>
kubectl get ingress -n <namespace> -o wide
```

---

## 🛡️ 5. Validate IAM Permissions (IRSA)

```bash
kubectl get sa aws-load-balancer-controller -n kube-system -o yaml
```

---

## 🧪 6. Test Application Access

```bash
curl -k https://<hostname>
```

---

## 🚨 7. Deleting Stuck Resources (Ingress, Service, etc.)

### Check deletion status

```bash
kubectl get ingress -n <namespace> -o yaml
```

Look for `deletionTimestamp` without completion.

---

### Force delete finalizers (⚠️ use with caution)

```bash
kubectl patch ingress <name> -n <namespace> -p '{"metadata":{"finalizers":[]}}' --type=merge
```

You can also edit manually:

```bash
kubectl edit ingress <name> -n <namespace>
# Remove the finalizers section, then save and exit
```

---

## 🧹 8. Check for Orphaned ALBs in AWS

Use the AWS CLI to list ALBs:

```bash
aws elbv2 describe-load-balancers
```

Or delete directly:

```bash
aws elbv2 delete-load-balancer --load-balancer-arn <arn>
```

---

## 🧼 9. Clean Up Target Groups

Orphaned Target Groups can prevent ALB deletion:

```bash
aws elbv2 describe-target-groups
aws elbv2 delete-target-group --target-group-arn <arn>
```

---

## 📌 Summary: Common Issues

| Symptom            | Cause                                   | Fix                                       |
|--------------------|------------------------------------------|-------------------------------------------|
| ALB not created    | Missing annotations or ingress class     | Add `ingressClassName: alb`               |
| 503 error          | No healthy targets                       | Check pod readiness and service selectors |
| 404 error          | Path mismatch                            | Check `pathType` and route configuration  |
| Ingress stuck      | Finalizer not removed                    | Patch or edit to remove finalizers        |
| DNS not resolving  | Route 53 record missing                  | Verify external-dns or manual entry       |

---

> _Use this guide to debug, validate, and clean up ALB-related resources in your EKS cluster._
