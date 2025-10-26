# 🚀 Jenkins → EKS Continuous Deployment (CD) Setup Notes

This document explains how Jenkins is securely connected to an Amazon EKS cluster to automatically deploy Kubernetes manifests from GitHub.

---

## ⚙️ 1. Kubernetes Service Account & Token

✅ Commands:
```bash
kubectl get secrets -n webapps
kubectl describe secret sa-secret -n webapps
```

- **Service Account:** `jenkins`  
- **Namespace:** `webapps`  
- **Secret Type:** `kubernetes.io/service-account-token`  
- **Data Fields:**
  - 🔐 `ca.crt` → Cluster CA certificate  
  - 🔑 `token` → Bearer token for authentication  
  - 🏷️ `namespace` → Namespace info  

You copied the `token` value and added it to Jenkins credentials.

🟩 **Purpose:**  
Allows Jenkins to authenticate and execute `kubectl` commands securely inside your cluster.

---

## 🔑 2. Jenkins Credentials Setup

➡️ Path:  
`Manage Jenkins → Credentials → Global → Add Credentials`

| Field | Value |
|-------|--------|
| **Kind** | Secret Text |
| **Scope** | Global |
| **Secret** | (Service Account Token) |
| **ID** | `k8-token` |
| **Description** | `k8-token` |

🟢 Used in Jenkinsfile with `withKubeConfig()` to connect to EKS.

---

## ☸️ 3. Jenkins–EKS Connection Configuration

Inside Jenkins **Pipeline Syntax → withKubeCredentials** you configured:

| Field | Value |
|--------|--------|
| **Credentials** | `k8-token` |
| **Kubernetes API endpoint** | `https://D3580F155BBA06A6DC69BE4FAD56EA06.gr7.us-east-1.eks.amazonaws.com` |
| **Cluster name** | `nakodtech-cluster` |
| **Namespace** | `webapps` |

🧩 **Purpose:**  
Allows Jenkins to authenticate with EKS and run cluster operations.

---

## 🧠 4. GitHub Integration

You added a **GitHub access token** credential:

| Field | Value |
|-------|--------|
| **Kind** | Secret Text |
| **ID** | `git-token` |
| **Description** | GitHub Personal Access Token |

Then linked it in the pipeline:

```groovy
git branch: 'main', credentialsId: 'git-token', url: 'https://github.com/bernardofosu/Mega-Project-CD-main.git'
```

🟢 **Purpose:**  
Lets Jenkins pull manifests and app code securely from GitHub.

---

## 🧾 5. Jenkins Pipeline Script

```groovy
pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-token', url: 'https://github.com/bernardofosu/Mega-Project-CD-main.git'
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                withKubeConfig(
                    caCertificate: '', 
                    clusterName: 'nakodtech-cluster', 
                    contextName: '', 
                    credentialsId: 'k8-token', 
                    namespace: 'webapps', 
                    restrictKubeConfigAccess: false, 
                    serverUrl: 'https://D3580F155BBA06A6DC69BE4FAD56EA06.gr7.us-east-1.eks.amazonaws.com'
                ) {
                    sh "kubectl apply -f Manifest/manifest.yaml -n webapps"
                    sh "kubectl apply -f Manifest/HPA.yaml"
                    sleep 30
                    sh "kubectl get pods -n webapps"
                    sh "kubectl get service -n webapps"
                }
            }
        }
    }
}
```

---

### 🧩 Stage Breakdown

#### 🧱 Stage 1 — Git Checkout
- Clones your repository branch `main`.
- Authenticates using `git-token`.

#### ☸️ Stage 2 — Kubernetes Deployment
- Connects to EKS with `k8-token`.
- Deploys manifests:
  - `Manifest/manifest.yaml` → App deployment + service  
  - `Manifest/HPA.yaml` → Autoscaling setup  
- Waits 30 seconds ⏳
- Lists pods and services for verification.

---

## 🧰 6. Verification Commands

```bash
kubectl get all -n webapps
kubectl describe deployment <app-name> -n webapps
kubectl get svc -n webapps
kubectl get hpa -n webapps
```

If Jenkins gets `forbidden` or `unauthorized`:
```bash
kubectl create clusterrolebinding jenkins-admin --clusterrole=cluster-admin --serviceaccount=webapps:jenkins
```

---

## 💡 7. Pro Tips

✅ Use a **dedicated service account** for Jenkins.  
✅ Rotate tokens periodically 🔄  
✅ Store tokens securely in Jenkins credentials.  
✅ For multiple clusters, use separate credentials for each.  
✅ Automate your pipeline triggers on GitHub commits for full CI/CD.

---

### 🏁 Result
Once configured:
- Jenkins fetches code from GitHub.  
- Connects securely to EKS.  
- Applies deployment manifests.  
- Verifies pods & services automatically.  

🎉 **Continuous Deployment complete!**
