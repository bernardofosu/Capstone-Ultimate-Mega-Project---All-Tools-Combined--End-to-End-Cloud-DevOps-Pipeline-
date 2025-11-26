# 🧱 SonarQube Setup on EC2 (Using Docker)

## 🪜 1️⃣ Install Docker

```bash
sudo apt update
sudo apt install -y docker.io
```

```sh
sudo chmod 666 /var/run/docker.sock
```

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

---

## 🐳 4️⃣ Run SonarQube Container

Create and start SonarQube with persistent volumes:

```bash
docker run -d \
  --name sonarqube \
  --restart unless-stopped \
  -p 9000:9000 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_logs:/opt/sonarqube/logs \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  sonarqube:community
```

--network sonarnet \

---

## 🧩 Explanation

---

Option Meaning

---

`--name sonarqube` Names the container

`--network sonarnet` Connects to a Docker network (create
with `docker network create sonarnet`)

`--restart unless-stopped` Auto-start on reboot

`-p 9000:9000` Maps container port 9000 to EC2 port
9000

`-v ...` Persists data, logs, and plugins

`sonarqube:community` Uses the open-source SonarQube image

---

---

## 🌐 5️⃣ Access SonarQube Web UI

Once it's running, open in your browser:

👉 **http://`<EC2-public-IP>`{=html}:9000**

**Default credentials:**

Username Password

---

`admin` `admin`

⚠️ You'll be prompted to change the password on first login.

new one
admin and @Nakodtech1234

## ✅ 6️⃣ Verify

Check container status:

```bash
docker ps
```

View logs if SonarQube isn't ready yet:

```bash
docker logs -f sonarqube
```

---

## 🧠 Optional Tip

If you want to see your volume data on the host:

```bash
docker volume inspect sonarqube_data
```

Or use bind mounts instead of Docker volumes:

```bash
-v /opt/sonarqube/data:/opt/sonarqube/data \
-v /opt/sonarqube/logs:/opt/sonarqube/logs \
-v /opt/sonarqube/extensions:/opt/sonarqube/extensions
```

---

## 🔗 Helpful Links

- 🐋 Docker Hub: <https://hub.docker.com/_/sonarqube>
- 📘 Official Docs:
  <https://docs.sonarsource.com/sonarqube-server/10.8/setup-and-upgrade/install-the-server/installing-sonarqube-from-docker>
