## ⚙️ **Install Jenkins**

We install **JDK 17** because Jenkins doesn’t support JDK 21.

```sh
sudo apt install -y openjdk-17-jdk
```

📘 [Jenkins Linux Install Docs](https://www.jenkins.io/doc/book/installing/linux/)

Start Jenkins:

```bash
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins
```

🌐 Access Jenkins:

```sh
http://54.89.160.68:8080/
```

[Setup Jenkins](./ReadMe/Jenkins%20Setup.md)

## 🧱 **SonarQube Setup on EC2 (Docker)**

1️⃣ Install Docker:

```bash
sudo apt update && sudo apt install -y docker.io
```

2️⃣ Add user to Docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Add docker group to jenkins user as well

3️⃣ Run SonarQube:

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

🌐 Access: `http://<EC2-public-IP>:9000`

👤 Default credentials: `admin / admin`

✅ Verify:

```bash
docker ps
docker logs -f sonarqube
```

---

## 4 Setup Nexus

- [Setup Nexus directly on linux](./Nexus%20Linux%20Installation.md)
- [Setup Nexus using docker](./Installing%20Nexus%20Repository%20Using%20Docker.md)

---

## 🐳 **Install Docker on all servers**

📘 [Docker Installation Docs](https://docs.docker.com/engine/install/ubuntu/#installation-methods)

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## 🛡️ Install Trivy (Image Scanner) on Jenkins Sever

We install **Trivy** on the Jenkins server to scan Docker images and Kubernetes workloads for vulnerabilities.

📘 [Official Installation Guide](https://trivy.dev/v0.67/getting-started/installation/)

### 🧩 Install Trivy

```bash
sudo apt-get install wget apt-transport-https gnupg lsb-release -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo gpg --dearmor -o /usr/share/keyrings/trivy.gpg
echo deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy -y
```

✅ Verify installation:

```bash
trivy --version
```
