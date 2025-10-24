# 🐳 Jenkins Docker Build Output — Where to Find Artifacts

## 📦 1️⃣ JAR File Location

**Path on Jenkins Server:**
```bash
/var/lib/jenkins/workspace/docker-pipeline/target/bankapp-0.0.1-SNAPSHOT.jar
```

**🧭 To view it:**
```bash
ls -lh /var/lib/jenkins/workspace/docker-pipeline/target/bankapp-0.0.1-SNAPSHOT.jar
```

**📁 In Jenkins UI:**
➡️ Open **docker-pipeline → Last Successful Build → Artifacts**  
You’ll see `bankapp-0.0.1-SNAPSHOT.jar` ready for download.  

---

## 🐋 2️⃣ Docker Image Location

**🧱 Built Image Tag:**
```
bofosu1/bankapp:v3
```

**🖥️ Stored in Docker Engine on Jenkins Host:**
```bash
sudo docker images | grep bofosu1
```
Sample output:
```
bofosu1/bankapp   v3   ff7814d4973b   1 second ago   390MB
```

**🔍 Inspect Image:**
```bash
sudo docker image inspect bofosu1/bankapp:v3
```

**▶️ Run it locally (test):**
```bash
sudo docker run --rm -p 8080:8080 bofosu1/bankapp:v3
curl http://localhost:8080/
```

---

## 💾 3️⃣ Save or Export Image (Optional)

```bash
sudo docker save bofosu1/bankapp:v3 -o /var/lib/jenkins/workspace/docker-pipeline/bofosu1-bankapp-v3.tar
ls -lh /var/lib/jenkins/workspace/docker-pipeline/bofosu1-bankapp-v3.tar
```

To load on another server:
```bash
sudo docker load -i bofosu1-bankapp-v3.tar
```

---

## ☁️ 4️⃣ Push to Docker Hub (Optional)

```bash
docker login -u bofosu1
sudo docker push bofosu1/bankapp:v3
```

Or configure Jenkins credentials (`docker-cred`) and add a `Docker Push` stage.

---

## 🧭 5️⃣ Jenkins Archive Path (Metadata)

Each build’s archived artifacts are stored at:
```bash
/var/lib/jenkins/jobs/docker-pipeline/builds/<build-number>/archive/
```

Example:
```bash
ls -la /var/lib/jenkins/jobs/docker-pipeline/builds/3/archive
```

Or download via Jenkins UI → Build → **Archived Artifacts**.

---

## 🧹 6️⃣ Cleanup Tips

Remove unused Docker images:
```bash
sudo docker rmi bofosu1/bankapp:v3
```

Clear old workspaces:
```bash
sudo rm -rf /var/lib/jenkins/workspace/docker-pipeline/target/*
```

---

✅ **Summary Table**

| 🧩 Item | 📍 Location / Command | 💡 Notes |
|----------|----------------------|----------|
| 📦 JAR File | `/var/lib/jenkins/workspace/docker-pipeline/target/bankapp-0.0.1-SNAPSHOT.jar` | Maven output, archived in Jenkins |
| 🐋 Docker Image | `bofosu1/bankapp:v3` | Stored locally in Docker Engine |
| 💾 Exported Image | `/var/lib/jenkins/workspace/docker-pipeline/bofosu1-bankapp-v3.tar` | Optional backup |
| ☁️ Push (optional) | `docker push bofosu1/bankapp:v3` | Requires Docker Hub credentials |
| 🧭 Jenkins Archive | `/var/lib/jenkins/jobs/docker-pipeline/builds/<build-number>/archive` | UI → Artifacts |

---

🚀 **Result:**  
You now know **where your JAR and Docker image live**, how to **inspect, run, save, or push them**, and where Jenkins archives them for download! 🎯
