# 🔍 ExternalDNS Verification & Troubleshooting Guide (EKS + Route 53)

This guide provides steps to verify a working ExternalDNS setup and troubleshoot common issues when managing DNS records in AWS Route 53 from your EKS cluster.

---

## ✅ Verification Checklist

### 1. Check ExternalDNS Deployment

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=external-dns
kubectl logs -n kube-system deploy/external-dns
```

Look for log lines such as:
```
INFO: Creating record: nginx.yourdomain.com -> abc123.elb.amazonaws.com
```

---

### 2. Check Ingress Resource

```bash
kubectl describe ingress nginx-ingress -n <namespace>
```

Ensure annotation exists:

```yaml
annotations:
  external-dns.alpha.kubernetes.io/hostname: nginx.yourdomain.com
```

### 3. Validate ALB & Ingress DNS

```bash
kubectl get ingress nginx-ingress -o wide
```

Make sure the ALB DNS name is attached and accessible.

---

### 4. Validate DNS Resolution

```bash
nslookup nginx.yourdomain.com
dig nginx.yourdomain.com
```

Result should point to your ALB DNS.

---

## 🛠️ Troubleshooting Common Issues

| Issue                           | Cause                                                | Resolution                                                                 |
|----------------------------------|-------------------------------------------------------|----------------------------------------------------------------------------|
| 🔴 No DNS record created         | Missing annotation, wrong IAM role                   | Add hostname annotation, check IRSA role and permissions                  |
| 🔴 ExternalDNS pod crashloop     | Misconfigured Helm values or missing role annotation | Check Helm chart values and IRSA role binding                             |
| 🔴 Record not pointing to ALB    | ALB not ready or DNS not synced                      | Confirm ALB is provisioned and check ExternalDNS logs                     |
| ⚠️ Record deleted unexpectedly   | Ingress/Service removed or annotation changed        | Use `--policy=upsert-only` to prevent accidental deletions                |
| ⚠️ Logs show “AccessDenied”      | IAM role does not have Route 53 permissions          | Attach correct `route53:*` actions to the IAM role                        |
| ⚠️ No HostedZone found           | Incorrect domain or zone filter mismatch             | Add `domainFilters` to limit ExternalDNS to your Route 53 hosted zone     |

---

## 📌 Helm Values to Double-Check

```yaml
provider: aws
aws:
  zoneType: public

domainFilters:
  - yourdomain.com

policy: upsert-only
txtOwnerId: external-dns

serviceAccount:
  create: true
  name: external-dns
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/externaldns-irsa-role
```

---

## 🔐 IAM Permissions Reminder

```json
{
  "Effect": "Allow",
  "Action": [
    "route53:ChangeResourceRecordSets",
    "route53:ListHostedZones",
    "route53:ListResourceRecordSets"
  ],
  "Resource": "*"
}
```

---

> _Use this guide to ensure your Kubernetes apps are automatically reachable via Route 53 DNS records using ExternalDNS._
