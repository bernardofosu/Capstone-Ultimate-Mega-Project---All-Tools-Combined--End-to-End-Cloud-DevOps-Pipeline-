# 🧾 Jenkins Stage — Updating and Committing Manifest File

This stage is where Jenkins automatically updates the **Kubernetes manifest file** (`manifest.yaml`) with the **new Docker image tag**, commits the change, and pushes it to your **CD GitHub repo** (e.g., `Mega-Project-CD-main`).

---

## 🧱 Step 1 — Update the Image Tag

```bash
echo "🧾 Updating the image tag in manifest.yaml..."
cd Mega-Project-CD-main
sed -i "s|bofosu1/bankapp:.*|bofosu1/bankapp:${IMAGE_TAG}|" Manifest/manifest.yaml
```

### 🧠 What Happens Here:

| Line                      | Explanation                                         |                              |                           |                                                                                         |
| ------------------------- | --------------------------------------------------- | ---------------------------- | ------------------------- | --------------------------------------------------------------------------------------- |
| `echo "🧾 Updating..."`   | Prints a log message to show what Jenkins is doing. |                              |                           |                                                                                         |
| `cd Mega-Project-CD-main` | Moves into the cloned **CD repo** directory.        |                              |                           |                                                                                         |
| `sed -i "s                | bofosu1/bankapp:.\*                                 | bofosu1/bankapp:${IMAGE_TAG} | " Manifest/manifest.yaml` | Finds the old Docker image tag and replaces it with the new one from the current build. |

### ⚙️ Example:

**Before:**

```yaml
image: bofosu1/bankapp:v5
```

**After:**

```yaml
image: bofosu1/bankapp:v16
```

This ensures that your deployment always uses the **latest image** built by Jenkins CI 🚀.

---

## 📜 Step 2 — Confirm the Update

```bash
echo "✅ Updated manifest file contents:"
cat Manifest/manifest.yaml
```

### 🧩 What It Does:

- Displays the updated `manifest.yaml` content in the Jenkins console.
- Helps verify that the **new tag** was correctly applied before committing.

---

## 🪶 Step 3 — Configure Git for Jenkins

```bash
echo "🪶 Configuring Git for Jenkins commit..."
git config user.name "Jenkins"
git config user.email "jenkins@example.com"
```

### 🧠 Why:

- Jenkins needs a **Git identity** to make commits.
- This sets up a temporary username and email for the Jenkins automation bot 🤖.

---

## 💾 Step 4 — Commit and Push Changes

```bash
echo "💾 Committing and pushing changes..."
git add Manifest/manifest.yaml
git commit -m "Update image tag to ${IMAGE_TAG}"
git push origin main
```

### 🧩 Explanation:

| Command                | Function                                                                    |
| ---------------------- | --------------------------------------------------------------------------- |
| `git add`              | Stages the modified manifest file for commit.                               |
| `git commit`           | Creates a commit message that includes the new tag version.                 |
| `git push origin main` | Pushes the commit to GitHub (branch `main`) in `Mega-Project-CD-main` repo. |

🧠 This is what triggers your **CD system (like ArgoCD)** to detect the change and automatically deploy the new image to your Kubernetes cluster.

---

## 🎉 Step 5 — Confirmation

```bash
echo "🎉 Manifest file updated and pushed successfully to Mega-Project-CD-main!"
```

### 🏁 Final Output:

- Confirms that everything went smoothly ✅
- The pipeline successfully automated what used to be a manual “update → commit → push” workflow 💪

---

## 🔄 Summary

| Step                         | Purpose                                      |
| ---------------------------- | -------------------------------------------- |
| 🧾 `sed`                     | Replaces old image tag with the new one.     |
| 📜 `cat`                     | Shows updated manifest in the logs.          |
| 🪶 `git config`              | Gives Jenkins a Git identity for committing. |
| 💾 `git add + commit + push` | Saves and pushes the new version to GitHub.  |
| 🎉 `echo`                    | Confirms success in Jenkins console.         |

---

✨ **In short:**
This part of the pipeline connects **CI → CD** by automatically updating your deployment manifest, committing the change, and pushing it back to GitHub — no manual steps needed 🙌
