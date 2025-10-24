# 🧩 Connect SonarQube to Jenkins — Step-by-Step Guide

---

## **1️⃣ Install SonarQube Scanner Plugin**
- Go to **Manage Jenkins → Plugins → Available plugins**
- Search for **“SonarQube Scanner”**
- Check it → Click **Install without restart**

✅ This plugin allows Jenkins to send build analysis results to SonarQube.

---

## **2️⃣ Generate a Token in SonarQube**
1. Log in to **SonarQube** (e.g., `http://<sonar-ip>:9000`)
2. Navigate to **Administration → Security → Users**
3. Under your user (like *Administrator*), click **⋮ → Tokens → Generate token**
4. Enter a name (e.g., `jenkins-token`)
5. Copy the generated token (you’ll only see it once)

✅ This token is your authentication key for Jenkins.

---

## **3️⃣ Add SonarQube Token in Jenkins**
1. In Jenkins → **Manage Jenkins → Credentials → System → Global credentials (unrestricted)**  
2. Click **Add Credentials**
3. Choose:  
   - **Kind:** Secret text  
   - **Secret:** paste the SonarQube token  
   - **ID:** `sonar-cred`  
   - **Description:** `SonarQube Authentication Token`
4. Click **Create**

---

## **4️⃣ Configure SonarQube Server in Jenkins**
1. Go to **Manage Jenkins → System**
2. Scroll to **SonarQube Servers**
3. Click **Add SonarQube**
4. Fill in:
   - **Name:** `sonar`
   - **Server URL:** `http://<sonarqube-server-ip>:9000`  
     *(e.g., `http://52.87.167.141:9000`)*
   - **Server authentication token:** select `sonar-cred`
5. Click **Save**

✅ Jenkins now knows how to connect to your SonarQube server.

---

## **5️⃣ Configure SonarQube Scanner Tool**
1. Go to **Manage Jenkins → Tools**
2. Scroll to **SonarQube Scanner**
3. Click **Add SonarQube Scanner**
4. Give it a name, e.g., `sonar-scanner`
5. Check “Install automatically” or provide a manual path
6. Click **Save**

---

## **6️⃣ Add SonarQube Stage in Jenkins Pipeline**

Add this stage to your **Jenkinsfile**:

```groovy
pipeline {
  agent any

  tools {
    maven 'Maven'
    jdk 'JDK11'
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/your/repo.git'
      }
    }

    stage('Build') {
      steps {
        sh 'mvn clean install'
      }
    }

    stage('SonarQube Analysis') {
      environment {
        scannerHome = tool 'sonar-scanner'
      }
      steps {
        withSonarQubeEnv('sonar') {
          sh '${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=my-app -Dsonar.sources=. -Dsonar.host.url=http://52.87.167.141:9000 -Dsonar.login=$SONAR_AUTH_TOKEN'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 2, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }
  }
}
```

✅ This triggers code scanning and waits for the Quality Gate result from SonarQube.

---

## **7️⃣ Verify the Integration**
- Run your Jenkins pipeline.
- Open **SonarQube → Projects** — your project should appear automatically.
- Check metrics, issues, and Quality Gate results.

---

## 🧾 **Summary Table**

| Step | Action | Location |
|------|--------|-----------|
| 1️⃣ | Install SonarQube Scanner Plugin | Jenkins → Manage Plugins |
| 2️⃣ | Create token | SonarQube → Administration → Security → Users |
| 3️⃣ | Add token as credential | Jenkins → Manage Credentials |
| 4️⃣ | Configure server | Jenkins → Manage Jenkins → System |
| 5️⃣ | Add SonarQube Scanner tool | Jenkins → Manage Jenkins → Tools |
| 6️⃣ | Update Jenkinsfile | Add SonarQube analysis stage |
| 7️⃣ | Verify connection | Jenkins pipeline & SonarQube UI |

---

### ✅ Final Thought
> Jenkins and SonarQube integration enables automatic code quality analysis 🚀  
Every build triggers SonarQube scanning and enforces Quality Gates before deployments. 🔒
