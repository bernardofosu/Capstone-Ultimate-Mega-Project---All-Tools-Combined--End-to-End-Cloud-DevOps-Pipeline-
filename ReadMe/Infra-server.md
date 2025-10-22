Set up infra server

Create aws sg

Port Range Source Description (Common Use)
3000–11000 0.0.0.0/0 Custom TCP range (used by apps, Node.js, Jenkins, etc.)
80 0.0.0.0/0 HTTP (web traffic)
443 0.0.0.0/0 HTTPS (secure web traffic)
22 0.0.0.0/0 SSH (remote login for Linux servers)

create aws ec2

create Access keys

🚀 **AWS EKS Setup & Terraform Deployment Guide**

---

### 🧩 **Install AWS CLI**

```bash
sudo apt install unzip -y
```

📘 Reference: [AWS CLI Installation Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

✅ Verify installation:

```bash
/usr/local/bin/aws --version
```

🧠 Configure AWS credentials:

```bash
aws configure
```

### ⚙️ **Install Terraform (Official Method)**

📘 Reference: [Install Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

💡 Simple Snap installation:

```bash
sudo snap install terraform --classic # it will take a lot of time
```

🧠 **Explanation:**

- `sudo` → run with admin rights.
- `snap install terraform` → installs Terraform.
- `--classic` → allows Terraform to access system paths.

✅ Verify installation:

```bash
terraform -version
```

Expected output:

```
Terraform v1.9.5
on linux_amd64
```
