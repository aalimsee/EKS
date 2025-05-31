# 🛡️ Creating IAM Roles and Policies: Terraform vs GitOps (Argo CD)

This guide explains how to manage IAM roles and policies for Kubernetes applications in EKS using **Terraform** (Infrastructure-as-Code) versus **GitOps** (Helm + Argo CD).

---

## 🎯 Objective

Bind AWS IAM roles to Kubernetes ServiceAccounts via **IRSA** (IAM Roles for Service Accounts) for secure access to AWS APIs.

---

## ✅ Option 1: Terraform (Infrastructure-as-Code)

Use Terraform to provision:
- IAM Role
- IAM Policy
- Trust relationship with OIDC
- Attach role to ServiceAccount

### 🔧 Example

```hcl
resource "aws_iam_role" "externaldns" {
  name = "externaldns-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.eks_oidc_issuer}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.eks_oidc_issuer}:sub" = "system:serviceaccount:kube-system:external-dns"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "externaldns" {
  name   = "ExternalDNSPolicy"
  policy = file("policies/externaldns.json")
}

resource "aws_iam_role_policy_attachment" "externaldns_attach" {
  role       = aws_iam_role.externaldns.name
  policy_arn = aws_iam_policy.externaldns.arn
}
```

---

## 🚀 Option 2: GitOps (Argo CD + Helm)

Use GitOps to annotate the ServiceAccount with a pre-created IAM role.

> ⚠️ GitOps **does not create IAM roles**. You must provision them externally (e.g., with Terraform).

### 🧩 Example (Helm values):

```yaml
serviceAccount:
  create: true
  name: external-dns
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/externaldns-irsa-role
```

Or via Argo CD Application manifest:

```yaml
spec:
  source:
    chart: external-dns
    repoURL: https://charts.bitnami.com/bitnami
    helm:
      values: |
        serviceAccount:
          create: true
          annotations:
            eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/externaldns-irsa-role
```

---

## 📝 Summary: Terraform vs GitOps for IAM Roles

| Feature                        | Terraform                     | GitOps / Argo CD (Helm)        |
|-------------------------------|-------------------------------|----------------------------------|
| Create IAM roles & policies   | ✅ Yes                        | ❌ No                            |
| Manage trust relationship     | ✅ Yes                        | ❌ No                            |
| Annotate ServiceAccount       | ✅ Yes                        | ✅ Yes (via Helm values)         |
| Recommended for IAM setup     | ✅ Strongly Recommended        | 🔄 Annotation only               |

---

## 🧠 Best Practice

Use **Terraform for role and policy provisioning**, then **annotate ServiceAccounts via GitOps** for seamless automation and secure access control.

---

> _Combine the strengths of Terraform and GitOps for a secure, scalable, and manageable cloud-native setup._
