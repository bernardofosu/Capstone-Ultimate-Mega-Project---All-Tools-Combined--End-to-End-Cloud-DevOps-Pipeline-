# 🔧 Install & Configure SonarQube Scanner in Jenkins — Notes

## 1️⃣ Prereqs
- Jenkins admin access ✅  
- Internet access from Jenkins (to download scanner) or have scanner archive locally ✅  
- SonarQube server reachable & configured (Manage Jenkins → Configure System → SonarQube servers) ✅

---

## 2️⃣ Install required plugins
1. Manage Jenkins → Manage Plugins.  
2. Install (if not present):  
   - **SonarQube Scanner** (plugin)  
   - **SonarQube** (core plugin for `withSonarQubeEnv`)  
3. Restart Jenkins if requested.  
📝 Note: both plugins allow automatic tool install and `withSonarQubeEnv` usage.

---

## 3️⃣ Add SonarQube Scanner in Global Tool Configuration
1. Manage Jenkins → Global Tool Configuration.  
2. Find **SonarQube Scanner** section → click **Add SonarQube Scanner**.  
3. Set fields:
   - **Name:** `sonar-scanner` *(must match pipeline name)* ✅  
   - Check **Install automatically**.  
   - Choose installer: **Install from Maven Central** or **Extract *.zip/*.tar.gz**.  
   - Pick the version (e.g., SonarScanner 4.x/5.x).  
4. Save.  
🔎 Quick test: The tool name must match `tool '...'` in your Jenkinsfile.

---

## 4️⃣ Configure SonarQube server
1. Manage Jenkins → Configure System → SonarQube servers.  
2. Add server:
   - **Name:** `sonar` (matches `withSonarQubeEnv('sonar')`)  
   - **Server URL:** `http://<sonar-host>:9000`  
   - **Authentication token:** create in SonarQube → paste into Jenkins.  
3. Save.  
📝 Note: This name links Jenkins to your SonarQube instance.

---

## 5️⃣ Add credentials (optional / recommended)
- Manage Jenkins → Credentials → Add Credentials (Secret text or Username/Password).  
- Use Sonar token for authentication.  

---

## 6️⃣ Pipeline usage examples

### 🧩 Using Jenkins-installed Scanner
```groovy
pipeline {
  agent any
  environment {
    SCANNER_HOME = tool 'sonar-scanner'
  }
  stages {
    stage('Sonar') {
      steps {
        withSonarQubeEnv('sonar') {
          sh "$SCANNER_HOME/bin/sonar-scanner -Dsonar.projectKey=myproj -Dsonar.sources=."
        }
      }
    }
  }
}
```

### 🧩 Simpler for Maven projects (no scanner binary required)
```groovy
withSonarQubeEnv('sonar') {
  sh 'mvn sonar:sonar -Dsonar.projectKey=myproj'
}
```
💡 Recommended for Maven-based projects.

---

## 7️⃣ Manual install on agent (optional)
```bash
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-<version>-linux.zip
unzip sonar-scanner-cli-<version>-linux.zip -d /opt/
ln -s /opt/sonar-scanner-<version> /opt/sonar-scanner
```
Then add `/opt/sonar-scanner/bin` to PATH or set `SCANNER_HOME` in pipeline.

---

## 8️⃣ Test installation
Create a test pipeline:
```groovy
pipeline {
  agent any
  environment { SCANNER_HOME = tool 'sonar-scanner' }
  stages {
    stage('Version') {
      steps {
        sh '$SCANNER_HOME/bin/sonar-scanner --version'
      }
    }
  }
}
```
✅ Expected output: SonarScanner version info + Java version.

---

## 9️⃣ Common troubleshooting
| Problem | Cause | Fix |
|----------|--------|-----|
| ❌ No tool named sonar-scanner | Tool name mismatch | Match name in Jenkinsfile & Global Tool Config |
| ⚠️ withSonarQubeEnv fails | SonarQube server not configured | Add in Configure System |
| 🔍 Scanner not found | PATH issue | Use Jenkins tool installer or full path |
| 🕒 Timeout on Quality Gate | Missing webhook | Add webhook `/sonarqube-webhook/` in SonarQube |
| 🚫 403 Authentication error | Wrong token | Use valid SonarQube token |

---

## 🔐 Security tips
- Use tokens instead of passwords.  
- Store secrets in Jenkins Credentials.  
- Never hardcode secrets in pipeline.

---

## ✅ Final checklist
- [ ] SonarQube plugins installed  
- [ ] SonarQube Scanner tool added (name = `sonar-scanner`)  
- [ ] SonarQube server configured  
- [ ] Matching names for `tool` and `withSonarQubeEnv`  
- [ ] Webhook configured for Quality Gate feedback  

---

🚀 Ready! Jenkins can now run SonarQube analysis and wait for Quality Gate results securely.
