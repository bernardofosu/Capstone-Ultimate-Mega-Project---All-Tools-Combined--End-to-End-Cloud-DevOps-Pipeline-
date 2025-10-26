# 🚀 **Install Helm and Deploy Argo CD via Helm**

This guide helps you **install Helm** 🪖 and **set up Argo CD** 🧩 using Helm for clean upgrades, easy management, and better GitOps automation 💡.

---

## 📦 **Step 1: Install HELM**

🧰 Update your system and install Helm directly:

```bash
sudo apt update && sudo apt upgrade -y
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

📌 To install a specific version (recommended for consistency):

```bash
wget https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz
tar -zxvf helm-v3.14.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm version
```

📘 Official Docs → [Helm Installation Guide](https://helm.sh/docs/intro/install/)

✅ Verify:

```bash
helm version
```

---

## 🧹 **Step 2: Remove Old Argo CD Installation**

If you previously installed Argo CD using raw YAML manifests, clean it up first:

```bash
kubectl delete namespace argocd --ignore-not-found
kubectl delete crd applications.argoproj.io appprojects.argoproj.io --ignore-not-found
```

🧽 This ensures a fresh start with no leftover configurations.

---

## 🧰 **Step 3: Add the Argo Helm Repository**

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

✅ This adds the official **Argo Helm Chart** repository.

---

## 🏗️ **Step 4: Install Argo CD Using Helm**

Create a namespace and deploy Argo CD:

```bash
kubectl create namespace argocd
helm install argocd argo/argo-cd -n argocd
```

💡 Helm will automatically install:

- 🧩 Argo CD Application Controller
- 🧠 Repo Server
- ⚙️ Dex Authentication
- 🌍 API Server

---

## 🔎 **Step 5: Verify Deployment**

Check if pods and services are running correctly:

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
```

✅ Expected running pods:

- `argocd-server`
- `argocd-repo-server`
- `argocd-application-controller`
- `argocd-dex-server`

---

## 🌐 **Step 6: Expose Argo CD UI**

Expose Argo CD server using a **LoadBalancer** (for EKS, GKE, or AKS):

```bash
kubectl -n argocd patch svc argocd-server -p '{"spec":{"type":"LoadBalancer"}}'
kubectl -n argocd get svc argocd-server
```

📎 Copy the `EXTERNAL-IP` once available and open:

```
https://<EXTERNAL-IP>
```

🧭 Or if using a domain (example):

```
https://argocd.nakodtech.xyz
```

---

## 🔐 **Step 7: Get Argo CD Initial Admin Password**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

👤 Username → `admin`
🔑 Password → _(output above)_

Then login via the UI 🎉

---

## 🧩 **Step 8: Manage Argo CD with Helm**

| Action             | Command                                      |
| ------------------ | -------------------------------------------- |
| 🆕 Upgrade Argo CD | `helm upgrade argocd argo/argo-cd -n argocd` |
| 🧹 Uninstall       | `helm uninstall argocd -n argocd`            |
| 🔍 Check release   | `helm list -n argocd`                        |
| 📋 Get values      | `helm get values argocd -n argocd`           |

---

## 🧠 **Why Use Helm for Argo CD?**

✅ Easy upgrades and rollbacks
✅ Centralized configuration via values.yaml
✅ Version control for Argo CD releases
✅ Cleaner, more repeatable setup for GitOps pipelines

---

🎯 **Final Result:**

- ✅ Helm installed and configured
- ✅ Argo CD deployed via Helm
- ✅ Accessible via LoadBalancer or Ingress
- ✅ Ready for GitOps auto-sync

Your Argo CD setup is now **production-ready** and fully managed by Helm 💪🚀
