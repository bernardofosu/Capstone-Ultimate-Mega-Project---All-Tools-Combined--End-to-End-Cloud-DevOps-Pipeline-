# 🚀 Fixing Argo CD "Unknown / Sync Error" — Private Repo Issue

## 🧩 Problem Summary

- The **Argo CD Application** (`bankapp`) was created successfully, but it showed status like:

  - ❌ _Unknown_
  - ⚠️ _Unable to fetch repository_
  - or it did not trigger deployments automatically.

- Root cause 🕵️‍♂️:
  The GitHub repository (`https://github.com/bernardofosu/Mega-Project-CD-main.git`) was **private**,
  and Argo CD did not have credentials to access it.

---

## ✅ Root Cause

Argo CD by default cannot clone private repositories.
You must **connect the repo** manually with authentication (HTTPS + Token or SSH key).

---

## 🛠️ Fix Steps — Connecting Private GitHub Repo

### 1️⃣ Go to Argo CD UI

- Open the Argo CD dashboard (LoadBalancer external IP):

  ```bash
  https://<ARGOCD-EXTERNAL-IP>
  ```

- Log in using:

  ```bash
  Username: admin
  Password: (from secret)
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  ```

---

### 2️⃣ Add Private Repo Access

- Navigate to 👉 **Settings → Repositories → Connect Repo**
- Select **Via HTTPS**
- Fill in the following fields:

| Field              | Value                                                      |
| ------------------ | ---------------------------------------------------------- |
| **Type**           | `git`                                                      |
| **Repository URL** | `https://github.com/bernardofosu/Mega-Project-CD-main.git` |
| **Username**       | `bernardofosu`                                             |
| **Password**       | _(GitHub Personal Access Token with repo access)_          |

> ⚙️ To create a Personal Access Token (PAT):
> GitHub → **Settings → Developer Settings → Personal Access Tokens → Tokens (classic)** → Generate new token → select scope `repo` and copy it.

- Click **Connect**

✅ When successful, you’ll see:

```
Connection Status: Successful
```

---

### 3️⃣ Verify Connection

Go to **Settings → Repositories** — it should list your repo:

```
Type: git
Repository: https://github.com/bernardofosu/Mega-Project-CD-main.git
Status: ✅ Successful
```

---

### 4️⃣ Refresh Application

Now that the repo is accessible, re-apply or refresh the Argo CD Application:

```bash
kubectl apply -f app-bankapp.yaml
```

- Or, click **REFRESH** on the Argo CD dashboard.
- The Application (`bankapp`) should now show:

```
Status: Synced ✅
Health: Healthy 💚
```

---

### 5️⃣ (Optional) Add GitHub Webhook for Auto-Deploy

To trigger instant deployments on every push:

1. Go to your repo → **Settings → Webhooks → Add Webhook**
2. Add:

   ```
   Payload URL: https://<ARGOCD-EXTERNAL-IP>/api/webhook
   Content type: application/json
   ```

3. Select **“Just the push event”** and save.

📦 Every time you push new changes to `main`, Argo CD will auto-sync your manifests.

---

## 🎯 Summary

| Step        | Description                         | Result                  |
| ----------- | ----------------------------------- | ----------------------- |
| 🐞 Problem  | Argo CD couldn’t sync               | Repo was private        |
| 🔑 Fix      | Added HTTPS repo with token         | Repo shows "Successful" |
| 🔁 Apply    | `kubectl apply -f app-bankapp.yaml` | App synced successfully |
| 🚀 Optional | Added webhook                       | Auto-deployment enabled |

---

**✅ Final Result:**
Argo CD can now fetch manifests from the private GitHub repo,
deploy automatically, and stay in sync with your `main` branch! 🎉
