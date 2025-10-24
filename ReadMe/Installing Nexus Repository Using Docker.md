# 📦 Installing Nexus Repository Using Docker

## 🪜 1️⃣ Install Docker

[official](https://docs.docker.com/engine/install/ubuntu/)

```bash
sudo apt update
sudo apt install -y docker.io
```

---

## 👤 2️⃣ Add Your User to the Docker Group

```bash
sudo usermod -aG docker $USER
```

This allows you to run Docker commands without `sudo`.

---

## 🔁 3️⃣ Refresh Group Membership

Activate the new group without logging out:

```bash
newgrp docker
```

## 1️⃣ Pull the Nexus Docker Image

```bash
docker pull sonatype/nexus3:latest
```

---

## 2️⃣ Run Nexus in a Docker Container

### Option A: Using Docker Volume (recommended)

```bash
docker run -d \
  -p 8081:8081 \
  --name nexus \
  -v nexus-data:/nexus-data \
  --restart always \
  sonatype/nexus3:latest
```

**Explanation:**

- `-d` → Run container in detached mode
- `-p 8081:8081` → Map container port 8081 to host port 8081
- `--name nexus` → Name the container "nexus"
- `-v nexus-data:/nexus-data` → Docker volume `nexus-data` persists Nexus data
- `sonatype/nexus3:latest` → Nexus Docker image

✅ Using a Docker volume ensures data persists even if the container is removed.

### Option B: Using Host Volume (optional)

```bash
docker run -d \
  -p 8081:8081 \
  --name nexus \
  -v /opt/data:/nexus-data \
  sonatype/nexus3:latest
```

**Explanation:**

- `-v /opt/data:/nexus-data` → Host directory volume (optional, useful for manual backup/inspection)

---

## 3️⃣ Access Nexus Web UI

Open browser:

```
http://localhost:8081
```

- **Admin username:** `admin`
- **Initial password:** stored in volume:

```bash
docker exec nexus cat /nexus-data/admin.password
```

> 🔑 Change admin password immediately.

---

## 4️⃣ Configure Container Resources (Optional)

```bash
docker run -d \
  -p 8081:8081 \
  --name nexus \
  -v nexus-data:/nexus-data \
  --memory="2g" \
  --cpus="2" \
  sonatype/nexus3:latest
```

- `--memory="2g"` → Limit memory to 2GB
- `--cpus="2"` → Limit CPU to 2 vCPU

---

## 5️⃣ Start / Stop / Restart Nexus Container

```bash
docker stop nexus
docker start nexus
docker restart nexus
```

---

## 6️⃣ Post-Installation Checklist

- ✅ Change admin password
- ✅ Configure anonymous access
- ✅ Update admin email
- ✅ Configure SMTP settings
- ✅ Configure HTTP/HTTPS proxy if needed
- ✅ Set up backup procedures
- ✅ Set up maintenance tasks (delete unused snapshots, incomplete Docker uploads, compact blob stores)
- ✅ Configure repository cleanup policies

---

## 7️⃣ Notes

- Runs best on **Linux-based containers**
- Recommended container: **t2.medium** or equivalent with **4 vCPU**, **15–20GB storage**
- Supports **CI/CD integration**, **Kubernetes**, **OpenShift**
- Use **Docker volume** or **host volume** to ensure persistent storage
