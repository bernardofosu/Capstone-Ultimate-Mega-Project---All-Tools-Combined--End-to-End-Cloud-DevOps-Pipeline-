# 🚀 **CD Pipeline — Deployed Kubernetes Resources and Verification Commands**

Your **Jenkins → EKS Continuous Deployment (CD) pipeline** successfully created and deployed the following resources into your cluster.  
Below is a detailed breakdown of each resource, followed by all the commands you can use to verify them.  

---

## 🧩 **Resources Created by the CD Pipeline**

### 🌐 **Ingress & Certificate Management**
1. **ClusterIssuer** → `letsencrypt-prod`  
   - Issues SSL/TLS certificates using Let’s Encrypt (ACME HTTP-01).  
2. **Ingress** → `bankapp-ingress`  
   - Routes external HTTPS traffic for  
     `nakodtech.xyz` and `www.nakodtech.xyz` → `bankapp-service`  
   - TLS secret: `nakodtech-xyz-tls`  

---

### 🐬 **Database Layer (MySQL)**
3. **Secret** → `mysql-secret`  
   - Stores Base64-encoded MySQL root password (`nakodtech1234`).  
4. **ConfigMap** → `mysql-config`  
   - Holds database name (`bankappdb`).  
5. **StorageClass** → `ebs-sc`  
   - AWS EBS CSI driver (`gp3`, `ext4`, Retain policy).  
6. **PersistentVolumeClaim** → `mysql-pvc`  
   - Requests 5Gi persistent volume for MySQL data.  
7. **Deployment** → `mysql`  
   - Runs `mysql:8` container with probes and volume mount.  
8. **Service** → `mysql-service`  
   - Exposes MySQL internally on port `3306`.  

---

### 💻 **Application Layer (BankApp)**
9. **Deployment** → `bankapp`  
   - Runs image `bofosu1/bankapp:v30` connected to MySQL.  
   - Includes liveness & readiness probes on `/login`.  
10. **Service** → `bankapp-service`  
    - Exposes app internally on port `80` (maps to container `8080`).  
11. **HorizontalPodAutoscaler (HPA)** → `bankapp-hpa`  
    - Auto-scales the `bankapp` deployment:  
      - Min replicas: 2  
      - Max replicas: 5  
      - Target: 50% CPU, 70% Memory utilization  

---

## ⚙️ **Namespaces Used**
- **Namespace:** `webapps` → all app-related resources.  
- **Cluster-wide:** `cert-manager` (ClusterIssuer), `ebs-sc` (StorageClass).  

---

# 🧾 **Verification Commands**

Use these commands to confirm, inspect, and debug all deployed resources.  

---

## 🧱 **1️⃣ Namespace**
```bash
kubectl get ns
```
🟢 Confirms the `webapps` namespace exists.

---

## 🔐 **2️⃣ Secrets**
```bash
kubectl get secrets -n webapps
kubectl describe secret mysql-secret -n webapps
```
🔍 Shows the MySQL credentials secret metadata.

---

## ⚙️ **3️⃣ ConfigMaps**
```bash
kubectl get configmap -n webapps
kubectl describe configmap mysql-config -n webapps
```
🧠 Displays the MySQL ConfigMap containing environment variables.

---

## 💾 **4️⃣ Storage**
```bash
kubectl get storageclass
kubectl describe storageclass ebs-sc
```
🧱 Verifies the EBS storage class parameters.

---

## 📦 **5️⃣ Persistent Volume Claim**
```bash
kubectl get pvc -n webapps
kubectl describe pvc mysql-pvc -n webapps
```
💾 Confirms PVC bound to an AWS EBS volume.

---

## 🐬 **6️⃣ MySQL Deployment & Service**
```bash
kubectl get deployment mysql -n webapps
kubectl describe deployment mysql -n webapps

kubectl get pods -l app=mysql -n webapps
kubectl logs deployment/mysql -n webapps

kubectl get svc mysql-service -n webapps
kubectl describe svc mysql-service -n webapps
```
🟢 Checks MySQL status, pods, logs, and service details.

---

## 🏦 **7️⃣ BankApp Deployment & Service**
```bash
kubectl get deployment bankapp -n webapps
kubectl describe deployment bankapp -n webapps

kubectl get pods -l app=bankapp -n webapps
kubectl logs deployment/bankapp -n webapps

kubectl get svc bankapp-service -n webapps
kubectl describe svc bankapp-service -n webapps
```
💻 Confirms your app is deployed, healthy, and connected to MySQL.

---

## ⚖️ **8️⃣ Horizontal Pod Autoscaler (HPA)**
```bash
kubectl get hpa -n webapps
kubectl describe hpa bankapp-hpa -n webapps
```
📊 Verifies autoscaling thresholds and current replica status.

---

## 🌐 **9️⃣ Ingress**
```bash
kubectl get ingress -A
kubectl describe ingress bankapp-ingress -n default
```
🌎 Confirms the Ingress routes `nakodtech.xyz` and `www.nakodtech.xyz` correctly.

---

## 🔐 **🔟 TLS Certificates**
```bash
kubectl get certificates -A
kubectl get certificaterequests -A
kubectl get challenges -A
kubectl describe certificate -A
```
🔏 Confirms that cert-manager successfully issued SSL certificates.

---

## 🧾 **1️⃣1️⃣ ClusterIssuer**
```bash
kubectl get clusterissuer
kubectl describe clusterissuer letsencrypt-prod
```
🧰 Shows your Let’s Encrypt configuration and status.

---

## 🧩 **1️⃣2️⃣ Everything in the Namespace**
```bash
kubectl get all -n webapps
```
🧾 Displays all pods, services, deployments, replicas, and HPA.

---

## 🧠 **1️⃣3️⃣ Events (Debugging)**
```bash
kubectl get events -n webapps --sort-by=.metadata.creationTimestamp
```
📋 Shows live events for troubleshooting (crashes, scheduling issues, etc.).

---

## 💿 **1️⃣4️⃣ Persistent Volume**
```bash
kubectl get pv
kubectl describe pv
```
🧱 Confirms AWS EBS volume bound to the PVC.

---

## 📊 **1️⃣5️⃣ Resource Usage**
```bash
kubectl top pods -n webapps
kubectl top nodes
```
📈 Monitors live CPU and memory metrics.

---

# ✅ **Final Quick Summary Commands**
Run these for a complete snapshot 👇

```bash
kubectl get all -n webapps
kubectl get pvc -n webapps
kubectl get hpa -n webapps
kubectl get ingress -A
kubectl get clusterissuer
kubectl get certificates -A
```

---

🎯 **Conclusion:**  
Your **CD pipeline** deployed a complete **3-tier architecture** (Database + Application + Ingress with TLS) and configured full **autoscaling and persistent storage** — all verified through these commands.
