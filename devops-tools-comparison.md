# ⚔️ DevOps & Observability Tools Comparison: Terraform, Argo CD, Helm, GitOps, GitHub Actions, Prometheus, Grafana

This guide compares seven essential tools used in Kubernetes-centric DevOps pipelines, GitOps workflows, and monitoring setups.

---

## 📊 Feature Comparison Table

| Tool / Concept     | Type              | Primary Purpose                                          | Typical Use Case                                        | Works With          |
|--------------------|-------------------|----------------------------------------------------------|----------------------------------------------------------|---------------------|
| **Terraform**      | IaC Tool          | Provision infrastructure using code                      | Deploy EKS, VPCs, IAM, Route 53, RDS                     | AWS, Azure, GCP     |
| **Helm**           | K8s Package Mgmt  | Package, install, and manage Kubernetes apps             | Install Prometheus, Argo CD, nginx, etc.                | Kubernetes           |
| **Argo CD**        | GitOps Controller | Sync Kubernetes manifests from Git to cluster            | Auto-deploy apps from Git repos                         | Git, Helm, Kustomize |
| **GitOps**         | DevOps Method     | Managing infrastructure/apps via Git as the source of truth | CI/CD, auto-sync, version-controlled infra & apps       | Argo CD, Flux       |
| **GitHub Actions** | CI/CD Platform    | Automate workflows like build/test/deploy                | Trigger Terraform apply or Docker builds on push        | GitHub, Cloud APIs   |
| **Prometheus**     | Monitoring System | Collect time-series metrics from services/pods           | Monitor CPU, memory, pod count, etc.                    | K8s, exporters       |
| **Grafana**        | Dashboarding Tool | Visualize metrics from Prometheus and other sources      | Dashboards for ops/SRE teams                            | Prometheus, Loki     |

---

## 🎯 Where Each Fits in a Kubernetes DevOps Pipeline

```text
[Terraform] ---> Provisions Infra (EKS, VPC, IAM, etc.)
     |
     v
[Helm Charts / K8s YAML] ---> Describe apps to deploy
     |
     v
[GitHub Repo] ---> Single source of truth for apps & infra
     |
     v
[GitHub Actions] ---> CI/CD to validate + push changes
     |
     v
[Argo CD] ---> Watches Git, deploys to cluster (GitOps)
     |
     v
[Apps Running in EKS]
     |
     v
[Prometheus] ---> Scrapes metrics from apps
     |
     v
[Grafana] ---> Visualizes metrics and alerts
```

---

## 🔍 Summary Table by Category

| Category             | Tool(s)                       | Role                                                                 |
|----------------------|-------------------------------|----------------------------------------------------------------------|
| **Provisioning**     | Terraform                     | Declarative infra as code (IaC) for cloud resources                 |
| **Deployment**       | Helm, Argo CD                 | Deploy packaged or raw Kubernetes apps                              |
| **Git-Centric Ops**  | GitOps, Argo CD               | Use Git as the single source of truth                               |
| **Automation**       | GitHub Actions                | CI/CD automation for infra and app pipelines                        |
| **Monitoring**       | Prometheus, Grafana           | Collect, store, and visualize metrics and alerts                    |

---

## 🧠 Takeaways

- 🔧 **Terraform**: Best for provisioning **non-Kubernetes resources** (EKS, S3, IAM, etc.)
- 🎯 **Helm**: Ideal for managing **complex Kubernetes apps** using templates
- 🤖 **Argo CD**: Enables GitOps by automatically syncing manifests from Git
- 🛠 **GitHub Actions**: Automates validation and deployment workflows
- 📈 **Prometheus**: Gathers detailed real-time metrics
- 📊 **Grafana**: Builds visual dashboards from monitoring data

---

> Use these tools **together** to build a secure, observable, automated cloud-native platform.
