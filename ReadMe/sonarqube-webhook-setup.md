# 🧩 SonarQube Webhook Configuration Guide

## 1️⃣ Purpose of Webhook
A webhook allows **SonarQube** to notify **Jenkins** when a code analysis is complete.  

It’s used for **synchronous communication** — Jenkins waits for SonarQube’s **Quality Gate** result after a scan.  

---

## 2️⃣ When to Configure
You must configure the webhook **after integrating SonarQube with Jenkins** (using the SonarQube plugin).  

The webhook sends results back to Jenkins — specifically to the endpoint:  
```
http://<jenkins-server>:8080/sonarqube-webhook/
```

---

## 3️⃣ Steps to Create Webhook in SonarQube

### 🔹 Step 1: Log In as Admin
Go to your SonarQube URL →  
`http://<sonar-ip>:9000`  

Log in with an **Administrator** account.

---

### 🔹 Step 2: Open Webhooks Configuration
Navigate to:  
**Administration → Configuration → Webhooks**

---

### 🔹 Step 3: Create a New Webhook
Click **“Create”** and fill in the fields:

- **Name:** `SonarQube-Webhook`  
- **URL:**  
  ```
  http://<jenkins-server-ip>:8080/sonarqube-webhook/
  ```
  (Replace `<jenkins-server-ip>` with your Jenkins server’s **public IP** or **domain name**.)
- **Secret:** *(Optional — leave blank for basic setups)*  

Click **Create ✅**

---

### 🔹 Step 4: Verify the Webhook
After running a Jenkins job that includes SonarQube analysis:  

Go to → **Administration → Webhooks → SonarQube-Webhook → Recent Deliveries**  

Check:  
- **Status Code = 200** → ✅ Successfully reached Jenkins  
- If it fails → Ensure Jenkins is accessible from SonarQube’s network  

---

## 4️⃣ Jenkins Side (Receiving Webhook)
The **SonarQube Jenkins plugin** automatically exposes the endpoint `/sonarqube-webhook/`.  

You **don’t need to create it manually**.  

Just ensure Jenkins is reachable at the URL you used (port **8080** or **80** if using a reverse proxy).  

---

## 5️⃣ Common Issues & Fixes

| ⚠️ Problem | 🧩 Cause | 🛠️ Fix |
|-------------|-----------|--------|
| ❌ Webhook fails (timeout) | Jenkins not reachable | Check firewall / security group / correct port |
| ❌ 404 error | Incorrect URL path | Ensure `/sonarqube-webhook/` suffix is correct |
| ❌ No Quality Gate result in Jenkins | Webhook not configured or blocked | Verify URL and SonarQube network access |
| ⚠️ Status not updated | Jenkins job finished before SonarQube result | Add `waitForQualityGate` step in Jenkinsfile |

---

## 🧾 Summary

| 🪜 Step | 🧠 Action | 📝 Description |
|----------|-----------|----------------|
| 1️⃣ | Log in as Admin | Access SonarQube dashboard |
| 2️⃣ | Go to Webhooks | Administration → Configuration → Webhooks |
| 3️⃣ | Create Webhook | Add Jenkins server URL |
| 4️⃣ | Verify | Check Recent Deliveries for 200 status |
| 5️⃣ | Jenkins Receives | `/sonarqube-webhook/` handled by plugin automatically |

---

## ✅ Result
🎯 Jenkins will now **automatically wait for SonarQube’s Quality Gate** response and **proceed or abort the pipeline** based on the result. 🚀
