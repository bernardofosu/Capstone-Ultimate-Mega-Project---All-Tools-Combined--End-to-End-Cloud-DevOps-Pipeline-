# 🔐 Jenkins + GitHub Token Integration Guide

This guide explains how to **create a GitHub Personal Access Token (PAT)**, **add it to Jenkins**, and **use it in your Pipeline** with `withCredentials()` — all step by step with emojis 🚀

---

## 🧭 Step 1: Create a GitHub Personal Access Token (PAT)

1️⃣ Go to **GitHub** → click your avatar → **Settings** ⚙️
2️⃣ Scroll down → **Developer settings** → **Personal access tokens** → **Tokens (classic)** 🔑
3️⃣ Click **Generate new token (classic)**
4️⃣ Add a name like `jenkins-git-token` and set an **expiration** 🗓️
5️⃣ Under **Scopes**, check ✅:

- `repo` → Full control of repositories (required for cloning/pushing)
- `admin:repo_hook` → (optional) if Jenkins triggers GitHub webhooks
- `workflow` → (optional) if you trigger GitHub Actions
  6️⃣ Click **Generate token** and **copy** it immediately! ⚠️ You won’t see it again!

💡 **Tip:** Store the token safely — treat it like a password.

---

## 🔧 Step 2: Add the Token to Jenkins Credentials

1️⃣ In Jenkins → **Manage Jenkins** → **Manage Credentials**
2️⃣ Select **Global credentials (unrestricted)** → click **Add Credentials** ➕
3️⃣ Fill in the fields:

| Field           | Value                                          |
| --------------- | ---------------------------------------------- |
| **Kind**        | Username with password                         |
| **Username**    | Your GitHub username (e.g. `bernardofosu`)     |
| **Password**    | Your GitHub PAT (the token you just created)   |
| **ID**          | `git` (you’ll reference this in your pipeline) |
| **Description** | GitHub PAT for Jenkins CI/CD                   |

4️⃣ Click **Save ✅**

🔒 Jenkins will now store this token securely and mask it in logs.

---

## 🧩 Step 3: Generate Pipeline Syntax in Jenkins UI

1️⃣ Open your Jenkins project → click **Pipeline Syntax** (on the left).
2️⃣ In **Sample Step**, choose **withCredentials: Bind credentials to variables** 🧠
3️⃣ Select **Username and password (separated)**
4️⃣ Fill in the fields:

- **Username Variable:** `GIT_USERNAME`
- **Password Variable:** `GIT_PASSWORD`
- **Credentials:** Select the credential you added (e.g. `bernardofosu/*** (git)`)
  5️⃣ Click **Generate Pipeline Script**

💡 You’ll get a script like this:

```groovy
withCredentials([usernamePassword(credentialsId: 'git', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
    // your commands here
}
```

---

## 🧱 Step 4: Use in a Jenkinsfile (Example Stage)

Here’s how to clone a GitHub repo securely and update a file 👇

```groovy
stage('Update Manifest File in Mega-Project-CD') {
    steps {
        script {
            cleanWs()  // clean workspace before cloning

            withCredentials([usernamePassword(credentialsId: 'git', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                sh '''
                    git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/bernardofosu/Mega-Project-CD-main.git
                    cd Mega-Project-CD-main
                    sed -i "s|bofosu1/bankapp:.*|bofosu1/bankapp:${IMAGE_TAG}|" Manifest/manifest.yaml
                    git config user.name "Jenkins"
                    git config user.email "jenkins@example.com"
                    git add Manifest/manifest.yaml
                    git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
                    git push origin main
                '''
            }
        }
    }
}
```

✅ This securely authenticates with GitHub and updates the manifest automatically.

---

## 🧪 Step 5: Quick Test Stage

You can verify Jenkins can access your repo:

```groovy
stage('Test Git Auth') {
    steps {
        withCredentials([usernamePassword(credentialsId: 'git', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
            sh 'git ls-remote https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/bernardofosu/Mega-Project-CD-main.git'
        }
    }
}
```

If you see remote branches printed, authentication is working ✅

---

## 🔒 Step 6: Security & Best Practices

- 🧹 Use **short-lived** tokens — rotate them regularly.
- 🔐 Keep credentials in Jenkins, **never in your code**.
- 🧾 Masked values (\*\*\*\*) in console logs mean Jenkins is protecting secrets.
- 🆔 Always reference credentials by their **ID** (e.g. `'git'`).
- 💬 Use descriptive IDs for easy maintenance (e.g. `github-bernardofosu`).

---

## 🧠 Key Takeaways

| Concept                                   | Meaning                                        |
| ----------------------------------------- | ---------------------------------------------- |
| `credentialsId`                           | Links your pipeline to the stored credential   |
| `usernameVariable:` / `passwordVariable:` | Built-in Jenkins keywords                      |
| `GIT_USERNAME`, `GIT_PASSWORD`            | Custom variable names you define               |
| `withCredentials()`                       | Jenkins step that securely injects credentials |

---

✨ **Result:** You can now clone, commit, and push to GitHub securely through Jenkins — all automated, all safe 🚀
