# 🛠️ Terraform + GitOps (Helm) Integration: IAM Role for ExternalDNS

This repository demonstrates how to provision an IAM Role for ExternalDNS using **Terraform**, and how to **consume that role** by annotating the Kubernetes **ServiceAccount** using **Helm (GitOps style)**.

---

## 📁 Folder Structure

```
.
├── terraform/
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── policies/
│   │       └── externaldns.json
├── helm/
│   └── external-dns-values.yaml
└── README.md
```

---

## ✅ 1. Terraform: Provision IAM Role and Policy

**Path**: `terraform/iam/main.tf`

```hcl
resource "aws_iam_role" "externaldns" {
  name = "externaldns-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.oidc_provider}:sub" = "system:serviceaccount:kube-system:external-dns"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "externaldns" {
  name   = "ExternalDNSPolicy"
  policy = file("${path.module}/policies/externaldns.json")
}

resource "aws_iam_role_policy_attachment" "externaldns_attach" {
  role       = aws_iam_role.externaldns.name
  policy_arn = aws_iam_policy.externaldns.arn
}

output "externaldns_role_arn" {
  value = aws_iam_role.externaldns.arn
}
```

---

## 🚀 2. Helm: Annotate ServiceAccount with IAM Role (GitOps)

**Path**: `helm/external-dns-values.yaml`

```yaml
provider: aws
aws:
  zoneType: public

txtOwnerId: external-dns
policy: upsert-only

serviceAccount:
  create: true
  name: external-dns
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/externaldns-irsa-role
```

Use with Helm or Argo CD:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install external-dns bitnami/external-dns -f helm/external-dns-values.yaml -n kube-system
```

Or with Argo CD Application manifest:

```yaml
spec:
  source:
    chart: external-dns
    repoURL: https://charts.bitnami.com/bitnami
    targetRevision: latest
    helm:
      valueFiles:
        - helm/external-dns-values.yaml
```

---

## 🧠 Best Practice

Use **Terraform to provision IAM**, and **GitOps (Argo CD + Helm)** to deploy and configure the app, including IAM role annotation via ServiceAccount.

This ensures separation of responsibilities:
- IAM roles are centrally managed
- Applications remain environment-specific and declarative

---

> _Secure, modular, and automated — the best of both Terraform and GitOps worlds._
