## 🔄 AWS Load Balancer Controller Communication in EKS

This section explains how the AWS Load Balancer Controller (ALBC) interacts with other EKS resources to expose Kubernetes services to the internet via ALB.

---

### 📌 Ingress ➝ ALB Controller

- You define an `Ingress` resource with ALB annotations like:

```yaml
alb.ingress.kubernetes.io/scheme: internet-facing
alb.ingress.kubernetes.io/target-type: ip
```

- The ALB Controller watches these ingress objects and reacts by calling AWS APIs to provision ALB resources.

---

### 📌 ALB Controller ➝ AWS APIs

- The controller uses an **IAM Role for Service Account (IRSA)** or the **node IAM role** to interact with AWS.
- It creates:
  - Application Load Balancers (ALBs)
  - Target Groups
  - Listener Rules
  - Security Groups

#### Required IAM Actions (Sample)

```json
{
  "Action": [
    "elasticloadbalancing:*",
    "ec2:Describe*",
    "acm:DescribeCertificate",
    "iam:CreateServiceLinkedRole"
  ],
  "Effect": "Allow",
  "Resource": "*"
}
```

---

### 📌 ALB ➝ EKS Services & Pods

- The ALB forwards traffic to **Kubernetes services**, which in turn forward it to matching **pods**.
- ALBC uses either `instance` or `ip` target types:

| Target Type | Targets            | Notes                                 |
|-------------|--------------------|---------------------------------------|
| `instance`  | Node IP + NodePort | Useful for EC2 worker nodes           |
| `ip`        | Pod IP directly    | Common with Fargate or fine-grained   |

---

### 🧭 Full Traffic Flow

```text
Internet
   ↓
[ALB] ← provisioned by ALB Controller
   ↓
[Ingress] ← routes traffic by host/path
   ↓
[Service] ← ClusterIP or NodePort
   ↓
[Pods] ← your containerized application
```

---

### 🧪 Troubleshooting & Verification

| Step                     | Command Example                                             |
|--------------------------|-------------------------------------------------------------|
| Check Ingress            | `kubectl describe ingress <name> -n <namespace>`           |
| View ALB logs            | `kubectl logs -n kube-system deploy/aws-load-balancer-controller` |
| Confirm AWS ALB exists   | `aws elbv2 describe-load-balancers --region <region>`       |
| Check Endpoints          | `kubectl get endpoints <service-name> -n <namespace>`       |

---

> _The AWS Load Balancer Controller bridges your Kubernetes workloads with AWS-managed ALBs, giving you scalable, secure ingress with automatic certificate and DNS integration._
