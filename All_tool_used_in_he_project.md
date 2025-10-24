# Capstone Ultimate Mega Project – All Tools Combined (End-to-End Cloud DevOps Pipeline)

🏗️ **1. INFRA SETUP (Top Section - Purple Box)**

**Tools:**

- Jenkins 🧩
- Nexus 📦
- SonarQube 🧠
- Trivy 🐋
- Kubectl ☸️
- AWS CLI ☁️
- Helm ⛵
- ArgoCD 🔁
- Infra Server (Central orchestrator) 🖥️

**Cluster Setup:**

- EKS Cluster (AWS Elastic Kubernetes Service) ☁️

  - Service Account 🔑
  - Cluster Role ⚙️
  - Role Binding 🔗
  - Cluster Role Binding 🧩

**Monitoring / Secrets:**

- Grafana 📊
- Prometheus 📈
  _(Connected to EKS Cluster via Secrets)_

---

⚙️ **2. CI/CD PIPELINE (Bottom Left - Blue Box)**

**Steps & Tools:**
1️⃣ Jenkins (Pipeline Orchestrator) 🧩
2️⃣ Source Code Management 🗂️

- GitHub / GitLab (Code Repository) 🧑‍💻
  3️⃣ Build Stage 🔧
- Test 🧪
- Compile ⚙️
  4️⃣ Code Quality Check 🧠
- SonarQube 🧩
  5️⃣ Security Scan 🛡️
- Trivy 🐋
  6️⃣ Container Build 🐳
- Docker 🧱
- DockerHub (Image Repository) 🗄️
  7️⃣ Post-build Notifications ✉️
- Gmail / Email Notifications 📧

---

🚀 **3. DEPLOYMENT SETUP (Bottom Right - Blue Box)**

**Kubernetes Deployment Components:**

- Jenkins → Kubernetes Integration ☸️

**MySQL Deployment:**

- MySQL Deployment 🧩
- MySQL ReplicaSet 🔁
- MySQL Pod 🧱
- PVC (Persistent Volume Claim) 💾
- StorageClass 📦
- MySQL Service 🔗

**Backend Deployment:**

- Backend Deployment 💻
- Backend ReplicaSet 🔁
- Backend Pod 🧱
- Backend Service 🔗

**Frontend Deployment:**

- NGINX 🌐
- SSL Certificate Issuer 🔐
- Ingress 🚪

**Monitoring:**

- Connected with Prometheus 📈 and Grafana 📊

---

🔐 **4. MONITORING & SECRET MANAGEMENT (Top Right - Yellow Box)**

**Tools:**

- Grafana 📊
- Prometheus 📈
  _(Accessed securely using Kubernetes Secrets)_

---

🔁 **Summary Flow Order**

1️⃣ **Infra Setup** → Jenkins, Nexus, SonarQube, Trivy, Kubectl, Helm, ArgoCD, EKS Cluster
2️⃣ **CI/CD Pipeline** → Jenkins builds → Tests → Quality Check (SonarQube) → Security Scan (Trivy) → Docker Build → Push to DockerHub → Notify
3️⃣ **Deployment** → Jenkins deploys to EKS → Backend + MySQL + Frontend (Ingress, SSL)
4️⃣ **Monitoring** → Prometheus + Grafana with Secrets from EKS
