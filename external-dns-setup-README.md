# 🌐 Setup Guide: ExternalDNS with AWS Route 53 in EKS

This guide provides step-by-step instructions for installing and configuring **ExternalDNS** in an Amazon EKS cluster, along with key points to ensure proper DNS automation using **Route 53**.

---

## ✅ Objective

Automatically create and manage DNS records in **Route 53** based on Kubernetes `Ingress` or `Service` resources using ExternalDNS.

---

## 🧱 Step 1: Prerequisites

- ✅ EKS cluster with IAM OIDC provider enabled
- ✅ A Route 53 **public hosted zone** (e.g., `yourdomain.com`)
- ✅ Helm installed locally
- ✅ Kubernetes context set to your EKS cluster
- ✅ `aws` CLI and IAM permissions to create roles and policies

---

## 🛡️ Step 2: Create IAM Role for ExternalDNS (IRSA)

IAM policy for Route 53:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "*"
    }
  ]
}
```

✅ Create an IAM role with the OIDC trust relationship to allow IRSA, and attach this policy.

---

## 📦 Step 3: Install ExternalDNS via Helm

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

```bash
helm install external-dns bitnami/external-dns \
  --namespace kube-system \
  --set provider=aws \
  --set aws.zoneType=public \
  --set txtOwnerId=external-dns \
  --set policy=upsert-only \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::<ACCOUNT_ID>:role/<ExternalDNS-IRSA-Role>"
```

---

## 🧭 Step 4: Annotate Ingress or Service

Add the following annotation to your Ingress:

```yaml
external-dns.alpha.kubernetes.io/hostname: nginx.yourdomain.com
```

✅ This tells ExternalDNS to create a DNS A record pointing to the ALB DNS name.

---

## 🔍 Step 5: Verify Setup

### Check ExternalDNS logs:

```bash
kubectl logs -n kube-system deploy/external-dns
```

### Check DNS resolution:

```bash
nslookup nginx.yourdomain.com
```

Should resolve to your ALB DNS name from the Ingress.

---

## 🚧 Key Notes & Gotchas

- `txtOwnerId` must be **unique per cluster** to avoid record conflicts
- If using **multiple domains**, configure zone filtering with `--set domainFilters={yourdomain.com}`
- Only records annotated with `external-dns.alpha.kubernetes.io/hostname` will be managed
- Ensure **Ingress has a hostname and ALB is created** before ExternalDNS syncs
- Use `upsert-only` to prevent accidental deletions

---

## 🧪 Troubleshooting

| Symptom                   | Cause                                      | Fix                                  |
|---------------------------|--------------------------------------------|--------------------------------------|
| DNS not created           | Missing annotation or wrong IAM role       | Check `external-dns` logs            |
| nslookup fails            | Route 53 record missing or still propagating | Check hosted zone and logs          |
| Record deleted unexpectedly | No longer matched by any Ingress          | Use `policy=upsert-only` for safety  |

---

## 📚 References

- [ExternalDNS GitHub](https://github.com/kubernetes-sigs/external-dns)
- [Helm Chart Docs](https://artifacthub.io/packages/helm/bitnami/external-dns)
- [Route 53 Docs](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/Welcome.html)

---

> _This setup ensures your Kubernetes services and applications are automatically reachable by domain name, powered by ExternalDNS and Route 53._
