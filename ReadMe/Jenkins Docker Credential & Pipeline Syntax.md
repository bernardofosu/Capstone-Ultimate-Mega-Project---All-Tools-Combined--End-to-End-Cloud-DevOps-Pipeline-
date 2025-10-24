# 🐳 Jenkins Docker Credential & Pipeline Syntax Guide

---

## 🔐 Step 1️⃣ — Add Docker Credentials in Jenkins

1. Go to **Jenkins Dashboard → Manage Jenkins → Credentials → System → Global credentials (unrestricted)**
2. Click **“Add Credentials”**
3. Choose:

   - **Kind:** `Username with password`
   - **Username:** your Docker Hub username (e.g. `bofosu1`)
   - **Password:** your Docker Hub password or **access token**
   - **ID:** `docker-cred` _(you’ll reference this in the pipeline)_

4. Click **Save**

---

## 🧱 Step 2️⃣ — Use in Jenkins Pipeline

### 🧩 Example Stage — Build & Push Docker Image

```groovy
stage('Docker Build & Push') {
    steps {
        script {
            withDockerRegistry([credentialsId: 'docker-cred']) {
                sh '''
                    IMAGE="bofosu1/bankapp:${BUILD_NUMBER}"
                    docker build -t "$IMAGE" .
                    docker push "$IMAGE"
                '''
            }
        }
    }
}
```

---

## ⚙️ How It Works

| Step                 | What It Does                                                |
| -------------------- | ----------------------------------------------------------- |
| `withDockerRegistry` | Logs in to Docker Hub using the stored Jenkins credential   |
| `docker build`       | Builds the Docker image from your Dockerfile                |
| `docker push`        | Pushes the image to your Docker Hub repo                    |
| `${BUILD_NUMBER}`    | Automatically tags each build with its Jenkins build number |

---

## 💡 Tips

- No need to add any Docker Hub **URL** — Jenkins uses it by default.
- Make sure your Jenkins agent has Docker installed and access to `/var/run/docker.sock`.
- Verify your repo exists on Docker Hub (e.g. `bofosu1/bankapp`).
- Use a **Docker Access Token** instead of password (more secure).

---

## ✅ Result

Each Jenkins run will automatically:

- 🔨 Build your Docker image
- 📦 Tag it (e.g. `bofosu1/bankapp:v15`)
- 🚀 Push it to your Docker Hub account

---

💡 **Pro Tip:** Combine this with your Trivy scan and Nexus deploy stages to create a full CI/CD workflow! 🚀
