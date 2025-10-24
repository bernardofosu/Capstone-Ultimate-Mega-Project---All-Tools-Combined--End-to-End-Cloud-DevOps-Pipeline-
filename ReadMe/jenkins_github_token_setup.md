# ⚙️ Jenkins GitHub Token Setup Guide

## ⚙️ Step-by-Step Breakdown

### ✅ Step 1: Create GitHub PAT

In **GitHub → Settings → Developer Settings → Personal access tokens → Tokens (classic):**

**Token name:**  
`jenkins-k8-token`

**Expiration:**  
✅ 90 days (Jan 21, 2026)

**Scopes (permissions):**

| Scope | Purpose |
|--------|----------|
| `repo` | Full repo access (needed for private repo cloning, commits, and status updates) |
| `workflow` | Allows Jenkins to trigger GitHub Actions if needed |
| `read:org` *(optional)* | Needed if using GitHub orgs |
| `admin:repo_hook` *(optional)* | Needed if Jenkins should create webhooks automatically |

🟢 **Minimum required:** `repo` + `workflow`  

⚠️ **Tip:** Do **not** select unnecessary scopes like `delete_repo` or `admin:org`. Keep least privilege.

---

### ✅ Step 2: Add the Token to Jenkins

In **Jenkins:**

Go to **Manage Jenkins → Credentials → System → Global credentials (unrestricted) → Add Credentials**

**Type:** `Username with password`  
**Username:** your GitHub username (e.g., `bernardofosu`)  
**Password:** your GitHub PAT  
**ID:** `git-token` (important — this is what you reference in Jenkinsfile)

---

### ✅ Step 3: Configure Repository in Jenkins Pipeline Job

In your pipeline configuration (or Jenkinsfile):

```groovy
git branch: 'main',
    credentialsId: 'git-token',
    url: 'https://github.com/bernardofosu/Mega-Project-CI-main.git'
```

🔍 **Explanation:**

- `branch` → tells Jenkins which branch to pull (`main`)  
- `credentialsId` → references the saved GitHub token (`git-token`)  
- `url` → your repository’s HTTPS URL  

✅ This allows Jenkins to **clone the repo securely** using your PAT credentials.

---

### ✅ Step 4: Verify Access (manual test)

You can verify connectivity manually on your Jenkins node:

```bash
git ls-remote https://<github-username>:<your-PAT>@github.com/bernardofosu/Mega-Project-CI-main.git
```

If you see refs (e.g., `refs/heads/main`), Jenkins can access your repo fine.

---

## 💡 Best Practices and Notes

### 🔐 Security

- Never hardcode your PAT in a Jenkinsfile or script.  
- Always store it in **Jenkins Credentials** and reference via `credentialsId`.  
- Limit **scope** & **expiration** of PATs (you did this ✅).  
- Rotate or renew the token before expiry (builds will fail if expired).

---

### 🧩 Credential Types

| Type | Use case |
|------|-----------|
| **Username with Password** | Classic Git clone via HTTPS (your setup) |
| **SSH Private Key** | For advanced setups (no expiration) |
| **Secret Text** | For APIs or GitHub Apps integrations |

💡 **Tip:** For shared or team Jenkins setups, SSH keys or fine-grained tokens are more secure long term.
