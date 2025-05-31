# 🛡️ Annotate ALB Controller with IAM Role (IRSA Setup)

This guide explains how to bind an IAM Role to the AWS Load Balancer Controller using Kubernetes ServiceAccount annotations, enabling secure AWS API access through IRSA.

---

## ✅ Step 1: Create IAM Role with OIDC Trust Policy

Ensure your EKS cluster has an OIDC provider enabled.

Trust policy example:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/oidc.eks.<REGION>.amazonaws.com/id/<OIDC_ID>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.<REGION>.amazonaws.com/id/<OIDC_ID>:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
        }
      }
    }
  ]
}
```

---

## ✅ Step 2: Annotate the ServiceAccount

Manually annotate:

```bash
kubectl annotate serviceaccount aws-load-balancer-controller \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::<ACCOUNT_ID>:role/<IAM_ROLE_NAME>
```

Or via YAML:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<IAM_ROLE_NAME>
```

---

## ✅ Step 3: Verify the Annotation

```bash
kubectl get serviceaccount aws-load-balancer-controller -n kube-system -o yaml
```

Ensure this appears in the output:

```yaml
annotations:
  eks.amazonaws.com/role-arn: arn:aws:iam::<ACCOUNT_ID>:role/<IAM_ROLE_NAME>
```

---

## ⚙️ Optional: Terraform Snippet

```hcl
resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}
```

---

## 📚 References

- [EKS IRSA Overview](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/)

---

> _This ensures your ALB Controller can securely interact with AWS APIs using fine-grained IAM permissions._
