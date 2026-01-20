# Capstone Ultimate Mega Project – End-to-End Cloud DevOps Pipeline

## 🖥️ **Set up Infra Server**

### Final Project
![final Project](./final-UI.png)

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

## ☸️ **Install kubectl on the Infra-Server and Jenkins Server**

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

## Setup and Connect Sonarqube to Jenkins

[Setup sonarqube](./ReadMe/SonarQube_Docker_Setup.md)

[Connect Sonarqube to Jenkins](./ReadMe/Connect-SonarQube-to-Jenkins-Guide.md)

## Create the Pipeline and Connect with SonarQube, Nexus and Dockerhub

- [Create the Pipeline](./ReadMe/Create-Jenkins-Pipeline-Guide.md)
- [Jenkins-Github-token-setup](./ReadMe/jenkins_github_token_setup.md)
- [SonarQube-Webhook-Configuration-Guide or Sonarqube Quality Gateway Webhook](./ReadMe/sonarqube-webhook-setup.md)
- [Connect Jenkins To Nexus](./Publish_To_Nexus_Repository/Connect_Jenkins_Nexus/maven-nexus-deploy-notes.md)
- [Setup SonnarQube Scannar](./ReadMe/sonarqube-scanner-setup-guide.md)
- [Setup Docker Credentials, Build, Scan and Push](./ReadMe/Jenkins%20Docker%20Credential%20&%20Pipeline%20Syntax.md)
- [Jenkins Stage — Updating and Committing Manifest File in Mega-Project-CD](./Mega-Project-CD-main/Update%20Manifest%20File%20in%20Another%20GitHub%20Repo/Jenkins%20Stage%20—%20Updating%20and%20Committing%20Manifest%20File.md)
- [Jenkins + GitHub Token](./Mega-Project-CD-main/Update%20Manifest%20File%20in%20Another%20GitHub%20Repo/Jenkins%20+%20GitHub%20Token.md)
- [Secure Git Clone in Jenkins](./Mega-Project-CD-main/Update%20Manifest%20File%20in%20Another%20GitHub%20Repo/Secure%20Git%20Clone%20in%20Jenkins.md)
- [Configure & Test Basic E-mail Notification in Jenkins](./Mega-Project-CD-main/Sending%20Email%20as%20Post%20in%20the%20Pipeline/Configure%20&%20Test%20Basic%20E-mail%20Notification%20in%20Jenkins.md)
- [How to Configure Gmail App Password for Jenkins SMTP (with Extended Email Plugin)](<./Mega-Project-CD-main/Sending%20Email%20as%20Post%20in%20the%20Pipeline/How%20to%20Configure%20Gmail%20App%20Password%20for%20Jenkins%20SMTP%20(with%20Extended%20Email%20Plugin).md>)
- [Test Email](./Mega-Project-CD-main/Sending%20Email%20as%20Post%20in%20the%20Pipeline/test-email.md)
- [Jenkins and Github Webhook](<./ReadMe/Jenkins%20+%20GitHub%20Webhook%20(Generic%20Webhook%20Trigger).md>)
- [Ingress + Cert-Manager DNS Setup](./ReadMe/Ingress%20+%20Cert-Manager%20DNS%20Setup.md)
- [Jenkins → EKS Continuous Deployment (CD) pipeline Setup](./ReadMe/Jenkins-EKS-CD-Pipeline-Notes.md)
- [Check CD Pipeline — Deployed Kubernetes Resources](./ReadMe/CD-Pipeline-Verification-Guide.md)
- [Check the Ingress ELB and Configure DNS in Route53](./Route53_&_Spaceship_Hosting/Route%2053%20Setup%20for%20Ingress%20ELB%20+%20Let's%20Encrypt%20SSL.md)
- [Ingress & SSL Certificate Issue Fix (nakodtech.xyz)](./Route53_&_Spaceship_Hosting/Ingress-SSL-Issue-Fix-Notes.md)
- [Install ArgoCD](./Mega-Project-CD-main/ArgoCD/Setting%20up%20Argo%20CD%20and%20Integrating%20Jenkins%20for%20GitOps%20Deployment.md)
- [Default ArgoCD Login](./Mega-Project-CD-main/ArgoCD/Default%20Argo%20CD%20Login%20Credentials.md)
- [Connect ArgoCD to Private Repo and Fix Sync Error](./Mega-Project-CD-main/ArgoCD/Fixing%20Argo%20CD%20Unknown%20Sync%20Error%20Private%20Repo%20Issue.md)
- [How to Configure GitHub Webhook for Argo CD](./Mega-Project-CD-main/ArgoCD/How%20to%20Configure%20GitHub%20Webhook%20for%20Argo%20CD.md)
- [Prometheus & Grafana Monitoring Setup via Helm](/Grafana%20and%20Prometheus%20Setup/Prometheus%20&%20Grafana%20Monitoring%20Setup%20via%20Helm.md)

Final Project CD Pipeline

````java
pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-token', url: 'https://github.com/bernardofosu/Mega-Project-CD-main.git'
            }
        }

        stage('Kubernetes Deployment') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'nakodtech-cluster', contextName: '', credentialsId: 'k8-token', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://D3580F155BBA06A6DC69BE4FAD56EA06.gr7.us-east-1.eks.amazonaws.com') {
                    sh "kubectl apply -f Manifest/manifest.yaml -n webapps"
                    sh "kubectl apply -f Manifest/HPA.yaml "
                    sleep 30
                    sh "kubectl get pods -n webapps"
                    sh "kubectl get service -n webapps"
                }
            }
        }
    }
}
```


Final Project CI Pipeline

```java
pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-token', url: 'https://github.com/bernardofosu/Mega-Project-CI-main.git'
            }
        }

        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }

        stage('Testing') {
            steps {
                sh "mvn test"
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs-report.html ."
            }
        }

        stage('Sonar Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=gcbank \
                        -Dsonar.projectName=gcbank \
                        -Dsonar.java.binaries=target
                    '''
                }
            }
        }

        stage('Quality Gate Check') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred'
                }
            }
        }

        stage('Build') {
            steps {
                sh "mvn package"
            }
        }

        stage('Publish To Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'global-maven-settings-config', maven: 'maven3', traceability: true) {
                    sh "mvn deploy"
                }
            }
        }

        stage('Docker Image Build & Tag') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker build -t bofosu1/bankapp:${IMAGE_TAG} ."
                    }
                }
            }
        }

        stage('Scan Image') {
            steps {
                sh "trivy image --format table -o image-report.html bofosu1/bankapp:${IMAGE_TAG}"
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        sh "docker push bofosu1/bankapp:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Update Manifest File in Mega-Project-CD') {
            steps {
                script {
                    // Clean workspace before cloning
                    cleanWs()

                    withCredentials([usernamePassword(credentialsId: 'git', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh '''
                            echo "🚀 Cloning the Mega-Project-CD-main repository..."
                            git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/bernardofosu/Mega-Project-CD-main.git

                            echo "🧾 Updating the image tag in manifest.yaml..."
                            cd Mega-Project-CD-main
                            sed -i "s|bofosu1/bankapp:.*|bofosu1/bankapp:${IMAGE_TAG}|" Manifest/manifest.yaml

                            echo "✅ Updated manifest file contents:"
                            cat Manifest/manifest.yaml

                            echo "🪶 Configuring Git for Jenkins commit..."
                            git config user.name "Jenkins"
                            git config user.email "jenkins@example.com"

                            echo "💾 Committing and pushing changes..."
                            git add Manifest/manifest.yaml
                            git commit -m "Update image tag to ${IMAGE_TAG}" || echo "No changes to commit"
                            git push origin main || echo "Push failed"

                            echo "🎉 Manifest file updated and pushed successfully to Mega-Project-CD-main!"
                        '''
                    }
                }
            }
        }
    } // end stages

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                // currentResult returns a string (SUCCESS/FAILURE/UNSTABLE/ABORTED)
                def pipelineStatus = currentBuild.currentResult ?: 'UNKNOWN'
                def bannerColor = (pipelineStatus.toUpperCase() == 'SUCCESS') ? 'green' : 'red'

                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                      <h2>${jobName} - Build ${buildNumber}</h2>
                      <div style="background-color: ${bannerColor}; padding: 10px;">
                        <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                      </div>
                      <p>Check the <a href=\"${env.BUILD_URL}\">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """

                emailext (
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: 'ofosubernard357@gmail.com',
                    // Use the same SMTP user configured in Jenkins or a verified alias
                    from: 'ofosubernard848@gmail.com',
                    replyTo: 'ofosubernard8482024@gmail.com',
                    mimeType: 'text/html',
                    attachLog: true,
                    compressLog: true
                )
            }
        }
    }
} // end pipeline
````
