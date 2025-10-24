🖥️ **Set up Infra Server**

---

### ☁️ **Create AWS Security Group (SG)**

| Port Range  | Source    | Description (Common Use)                                |
| ----------- | --------- | ------------------------------------------------------- |
| 3000–11000  | 0.0.0.0/0 | Custom TCP range (used by apps, Node.js, Jenkins, etc.) |
| 80          | 0.0.0.0/0 | HTTP (web traffic)                                      |
| 443         | 0.0.0.0/0 | HTTPS (secure web traffic)                              |
| 22          | 0.0.0.0/0 | SSH (remote login for Linux servers)                    |
| 30000–38000 | 0.0.0.0/0 | NodePort range for Kubernetes                           |

---

### 💻 **Create AWS EC2 for Infra-Server**

- Launch EC2 instance
- Create Access keys

```bash
sudo apt update
```

---

🚀 **AWS EKS Setup & Terraform Deployment Guide**

### 🧩 **Install AWS CLI on the Infra-Server**

```bash
sudo apt install unzip -y
```

📘 [AWS CLI Installation Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

✅ Verify installation:

```bash
/usr/local/bin/aws --version
```

🧠 Configure AWS credentials:

```bash
aws configure
```

---

### ⚙️ **Install Terraform (Official Method) on the Infra-Server**

📘 [Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

💡 Simple Snap installation:

```bash
sudo snap install terraform --classic
```

✅ Verify:

```bash
terraform -version
```

---

### 🧰 **Set up Git Repository**

```bash
git --version
git clone <repo-url>
cd <repo-with-tf-files>
```

---

## 🏗️ **Create EKS Cluster**

🗝️ **Create SSH Key Pair**

```bash
aws ec2 create-key-pair \
  --key-name nakodtech \
  --region us-east-2 \
  --query "KeyMaterial" \
  --output text > nakodtech.pem
chmod 400 nakodtech.pem
```

⚙️ **Run Terraform**

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply --auto-approve
```

- [Check the Resources Created](./ReadMe/EKS%20Add-on%20Quick%20Checks.md)
- [Terraform Plan & Apply — Comprehensive Notes with CI/CD Best Practices](./ReadMe/Terraform%20Plan%20&%20Apply.md)

### Check The Cluster

```sh
kubectl config current-context
kubectl cluster-info
```

```sh
aws eks list-nodegroups --cluster-name nakodtech-cluster --region us-east-1

aws iam list-attached-role-policies --role-name nakodtech-node-group-role
```

## 🧱 **Create 3 EC2 Instances for:**

As we waiting for eks cluster to create lets setup the following

- SonarQube 🧩
- Jenkins ⚙️
- Nexus 📦
- [Setup Jenkins Sonarqube Nexus](./ReadMe/setup-jenkins-nexus-sonarqube.md)

---

## ☸️ **Install kubectl on the Infra-Server**

```bash
curl -fL -o kubectl https://dl.k8s.io/release/v1.30.0/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

📘 [Install kubectl Docs](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html#linux_amd64_kubectl)

---

## ⚙️ **Install eksctl on the Infra-Server**

```bash
curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz"
sudo tar -xzf eksctl_$(uname -s)_amd64.tar.gz -C /usr/local/bin
eksctl version
```

📘 [eksctl Docs](https://docs.aws.amazon.com/eks/latest/eksctl/installation.html)

---

## 🧠 **Configure kubectl**

```bash
aws eks --region us-east-1 update-kubeconfig --name nakodtech-cluster
kubectl get nodes
```

## If you using Mega-Project-Terraform-old then you have to [manually add](./ReadMe/create_cluster_service_account.md)

## 📦 **Install HELM**

```bash
sudo apt update && sudo apt upgrade -y
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

📌 Control the version:

```bash
wget https://get.helm.sh/helm-v3.14.0-linux-amd64.tar.gz
tar -zxvf helm-v3.14.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
helm version
```

📘 [Helm Install Docs](https://helm.sh/docs/intro/install/)

## Configure RBAC in webapps namespace

create webapps namespace

```sh
kubectl create ns webapps
kubectl get ns
```

[After creating namespace, then add the RBAC](./Mega-Project-Terraform-main/RBAC/rbac.md)

## Connect Sonarqube to Jenkins

[Connect Sonarqube to Jenkins](./ReadMe/Connect-SonarQube-to-Jenkins-Guide.md)

## Create the Pipeline and Connect with SonarQube, Nexus and Dockerhub

- [Create the Pipeline](./ReadMe/Create-Jenkins-Pipeline-Guide.md)
- [Jenkins-Github-token-setup](./ReadMe/jenkins_github_token_setup.md)
- [SonarQube-Webhook-Configuration-Guide](./ReadMe/sonarqube-webhook-setup.md)
- [Connect Jenkins To Nexus](./Publish_To_Nexus_Repository/Connect_Jenkins_Nexus/maven-nexus-deploy-notes.md)
- [Setup SonnarQube Scannar](./ReadMe/sonarqube-scanner-setup-guide.md)
- [Sonarqube Quality Gateway Webhook]()
- [Setup Docker Credentials, Build, Scan and Push](./ReadMe/Jenkins%20Docker%20Credential%20&%20Pipeline%20Syntax.md)
- [Jenkins Stage — Updating and Committing Manifest File](./Mega-Project-CD-main/Update%20Manifest%20File%20in%20Another%20GitHub%20Repo/Jenkins%20Stage%20—%20Updating%20and%20Committing%20Manifest%20File.md)
- [Jenkins + GitHub Token](./Mega-Project-CD-main/Update%20Manifest%20File%20in%20Another%20GitHub%20Repo/Jenkins%20+%20GitHub%20Token.md)
- [Secure Git Clone in Jenkins](./Mega-Project-CD-main/Update%20Manifest%20File%20in%20Another%20GitHub%20Repo/Secure%20Git%20Clone%20in%20Jenkins.md)
- [Configure & Test Basic E-mail Notification in Jenkins](./Mega-Project-CD-main/Sending%20Email%20as%20Post%20in%20the%20Pipeline/Configure%20&%20Test%20Basic%20E-mail%20Notification%20in%20Jenkins.md)
- [How to Configure Gmail App Password for Jenkins SMTP (with Extended Email Plugin)](<./Mega-Project-CD-main/Sending%20Email%20as%20Post%20in%20the%20Pipeline/How%20to%20Configure%20Gmail%20App%20Password%20for%20Jenkins%20SMTP%20(with%20Extended%20Email%20Plugin).md>)
- [Test Email](./Mega-Project-CD-main/Sending%20Email%20as%20Post%20in%20the%20Pipeline/test-email.md)
