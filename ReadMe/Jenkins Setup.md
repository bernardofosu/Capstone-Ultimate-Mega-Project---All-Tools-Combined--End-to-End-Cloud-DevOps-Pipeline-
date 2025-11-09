🧰 **Jenkins Setup Notes**

[Install Jenkins](https://www.jenkins.io/doc/book/installing/linux/)

## 🚀 Step 1: Unlock Jenkins

When Jenkins starts for the first time, it displays a screen asking for the **initial admin password**.

📍 Path to the password file:

```bash
/var/lib/jenkins/secrets/initialAdminPassword
```

🔹 Copy the password from this file:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

🔹 Paste it into the “Administrator password” field on the Jenkins web page to unlock Jenkins.

🌐 Example URL:

```
http://<EC2-public-IP>:8080
```

---

## ⚙️ Step 2: Customize Jenkins

Once Jenkins is unlocked, you’ll see the setup screen:

🧩 Choose **“Install suggested plugins”** (recommended).

This installs the most commonly used Jenkins plugins, including:

- Git plugin 🧑‍💻
- Pipeline plugin 🧱
- Credentials plugin 🔐
- SSH Agent plugin 🔗
- Docker plugin 🐳
- Maven Integration (v3.24)
- Config File Provider

Pipeline Maven Integration

Pipeline: Stage View (v2.34)

SonarQube Scanner (v2.17.3)

Docker Pipeline

Kubernetes CLI (v1.12.1)

- HTML Publisher
- Generic Webhook Trigger

📦 These plugins allow Jenkins to integrate with Git, Docker, and automate build pipelines easily.

---

## 🧑‍💻 Step 3: Create First Admin User

After plugins finish installing:

- Enter your **Admin Username**, **Password**, **Full Name**, and **Email Address**.
- Click **Save and Continue**.

This user will now manage Jenkins.

---

## 🌐 Step 4: Instance Configuration

Next, Jenkins will ask you to configure the **Instance URL**.

Example:

```
http://13.232.228.217:8080/
```

✅ Make sure to use your EC2 **Public IP**, **Elastic IP**, or **Domain Name**.

💡 You can update it later with:

```bash
sudo sed -i 's#<jenkinsUrl>.*</jenkinsUrl>#<jenkinsUrl>http://54.147.175.50:8080/</jenkinsUrl>#' /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
```

```sh
sudo systemctl restart jenkins
```

## 🔁 Step 5: Save and Finish

Click **Save and Finish**, then **Start using Jenkins**.

You’ll be redirected to the Jenkins dashboard 🎯

✅ Jenkins is now fully set up and ready to use.

---

## ⚙️ Step 6: Install kubectl on Jenkins Server

Install **kubectl** (Kubernetes CLI) on the Jenkins server so Jenkins pipelines can deploy to EKS.

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client
```

📘 [Kubernetes kubectl Install Docs](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

## ☸️ **Install kubectl on the Jenkins Server**

```bash
curl -fL -o kubectl https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

📘 [Install kubectl Docs](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#linux_amd64_kubectl)

## 🛡️ Install Trivy (Image Scanner)

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

🧠 Trivy helps Jenkins CI pipelines automatically scan:

- Docker images 🐳
- Filesystems 📂
- Git repositories 💻
- Kubernetes clusters ☸️

---

## 🔍 Quick Troubleshooting

| Issue                   | Cause                       | Fix                                                                             |
| ----------------------- | --------------------------- | ------------------------------------------------------------------------------- |
| Jenkins not accessible  | Port 8080 blocked           | Open port 8080 in AWS Security Group                                            |
| Forgot admin password   | File missing                | Check `/var/lib/jenkins/secrets/initialAdminPassword` or reset Jenkins password |
| Jenkins service stopped | Jenkins crashed or rebooted | Restart: `sudo systemctl restart jenkins`                                       |

---

## 🧱 Verify Jenkins Service

```bash
sudo systemctl status jenkins
```

If inactive, start it:

```bash
sudo systemctl start jenkins
```

Enable Jenkins on boot:

```bash
sudo systemctl enable jenkins
```

### Install Docker

Add jenkins user to the docker group

```sh
ls -l /var/run/docker.sock
srw-rw---- 1 root docker 0 Oct 24 09:12 /var/run/docker.sock
```

```sh
sudo usermod -aG docker jenkins
newgrp docker
```

Restart Jenkins service

```sh
sudo systemctl restart jenkins
sudo -u jenkins groups jenkins
```

⚠️ Important: The Jenkins user session must be restarted to load the new group membership.

If not u will get this error

```sh
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.50/build?dockerfile=Dockerfile&t=bofosu1%2Fbankapp%3Av12&version=1": dial unix /var/run/docker.sock: connect: permission denied
```
