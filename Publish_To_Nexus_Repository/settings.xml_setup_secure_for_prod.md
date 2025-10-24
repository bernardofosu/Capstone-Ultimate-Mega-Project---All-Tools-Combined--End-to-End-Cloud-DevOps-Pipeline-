# ⚙️ Jenkins Config File Provider Plugin Guide

## 🧩 What Is the Config File Provider Plugin?

The **Config File Provider** plugin in Jenkins allows you to **store and manage configuration files centrally** (instead of copying or hardcoding them inside pipelines, workspaces, or agents).

### ✅ Key Benefits:

- Centralized management of configs like `settings.xml`, `toolchains.xml`, or `.properties` files.
- Secure integration with Jenkins **credentials**.
- Consistent environment configuration across builds.
- Avoids duplication and manual file setup.

---

## 💡 Why We Need It

Without this plugin:

- Each Jenkins agent or job must manually maintain its config files.
- Inconsistent setups can break builds.
- Credentials inside XML files are insecure.

With this plugin:

- Jenkins manages configs in one place.
- They can be dynamically injected during builds.
- Credentials are securely referenced via Jenkins credentials.

💡 **Example use case:**  
When Maven needs to deploy to **Nexus Repository**, it uses `settings.xml` with server credentials and mirrors.

---

## 🪄 Step 1: Install the Plugin

1. Navigate to **Manage Jenkins → Plugins → Available Plugins**.
2. Search for **“Config File Provider”**.
3. Click **Install without restart**.
4. Wait for the installation to complete.

---

## 🧰 Step 2: Add a New Managed Config File

1. Go to **Manage Jenkins → Managed files**.
2. Click **Add a new Config**.
3. Choose:
   - **Maven settings.xml** → for project-specific configs.
   - **Global Maven settings.xml** → for global configurations.

📝 Example form fields:

```
ID: maven-settings
Name: Maven Settings
Comment: Nexus credentials and mirrors
Content: [Paste or upload settings.xml]
```

---

## 🔑 Step 3: Set Up NEXUS_USER and NEXUS_PASS in Jenkins

To securely provide your Nexus credentials to Jenkins and Maven:

<!-- ### 🧭 Option 1 — Add as Jenkins Environment Variables
1. Go to **Manage Jenkins → Configure System**.
2. Scroll to **Global Properties**.
3. Check ✅ **Environment variables**.
4. Add:
   ```
   NEXUS_USER = your-nexus-username
   NEXUS_PASS = your-nexus-password
   ```
5. Click **Save**.

🧩 Jenkins will now expose these environment variables to all builds.

--- -->

### 🔐 Option 2 — Store as Jenkins Credentials (Recommended)

1. Go to **Manage Jenkins → Credentials → (Global)**.
2. Click **Add Credentials**.
3. Choose **Username with password**.
4. Enter:
   - **Username:** your Nexus username
   - **Password:** your Nexus password
   - **ID:** nexus-creds
5. Save ✅.

Then, in your Jenkinsfile, you can inject them like this:

```groovy
environment {
  NEXUS_CREDS = credentials('nexus-creds')
}
```

And reference them as:

```groovy
sh 'mvn deploy -Dnexus.user=$NEXUS_CREDS_USR -Dnexus.pass=$NEXUS_CREDS_PSW'
```

---

## 🧾 Step 4: Create or Edit Your `settings.xml`

Here’s a minimal example for **Nexus Repository** integration:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
          https://maven.apache.org/xsd/settings-1.0.0.xsd">

  <servers>
    <server>
      <id>nexus-releases</id>
      <username>${env.NEXUS_USER}</username>
      <password>${env.NEXUS_PASS}</password>
    </server>
    <server>
      <id>nexus-snapshots</id>
      <username>${env.NEXUS_USER}</username>
      <password>${env.NEXUS_PASS}</password>
    </server>
  </servers>

  <mirrors>
    <mirror>
      <id>nexus</id>
      <mirrorOf>*</mirrorOf>
      <url>http://nexus.nakodtech.xyz:8081/repository/maven-public/</url>
    </mirror>
  </mirrors>

  <profiles>
    <profile>
      <id>nexus</id>
      <repositories>
        <repository>
          <id>central</id>
          <url>http://nexus.nakodtech.xyz:8081/repository/maven-central/</url>
        </repository>
      </repositories>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>nexus</activeProfile>
  </activeProfiles>
</settings>
```

---

## 🧱 Step 5: Use It in Jenkins Jobs

### 🧩 Freestyle Job:

1. Open your Maven job → **Build Environment**.
2. Check ✅ **Provide Configuration Files**.
3. Select the file ID (e.g., `maven-settings`).
4. Jenkins injects it automatically into the build.

---

### 🧩 Pipeline Job (Declarative):

```groovy
pipeline {
  agent any
  environment {
    NEXUS_USER = credentials('nexus-user')
    NEXUS_PASS = credentials('nexus-pass')
  }
  stages {
    stage('Build with Maven') {
      steps {
        configFileProvider([configFile(fileId: 'maven-settings', variable: 'MAVEN_SETTINGS')]) {
          sh "mvn clean deploy --settings $MAVEN_SETTINGS"
        }
      }
    }
  }
}
```

💡 Jenkins temporarily creates the file, assigns it to `$MAVEN_SETTINGS`, and Maven uses it for builds.

---

## 🧹 Step 6: Manage and Update

- Update the file anytime under **Manage Jenkins → Managed files**.
- Update credentials under **Manage Jenkins → Credentials**.
- Jobs automatically pick up updates — no need to reconfigure manually.

---

## ✅ Summary

| Step | Action            | Description                                           |
| ---- | ----------------- | ----------------------------------------------------- |
| 1️⃣   | Install Plugin    | Add **Config File Provider** from Plugin Manager      |
| 2️⃣   | Create Config     | Add `settings.xml` or global file under Managed Files |
| 3️⃣   | Set Up Env Vars   | Configure `NEXUS_USER` and `NEXUS_PASS` in Jenkins    |
| 4️⃣   | Add Nexus Details | Include servers, mirrors, and profiles                |
| 5️⃣   | Use in Jobs       | Inject via `configFileProvider` in Jenkinsfile        |
| 6️⃣   | Manage Centrally  | Update from Jenkins UI anytime                        |

---

### 🚀 End Result:

- Centralized `settings.xml` ✅
- Secure credentials integration 🔒
- Seamless Nexus artifact deployment 🧩
- Cleaner pipelines and consistent environments ⚙️
- Environment variables securely managed 🧠
