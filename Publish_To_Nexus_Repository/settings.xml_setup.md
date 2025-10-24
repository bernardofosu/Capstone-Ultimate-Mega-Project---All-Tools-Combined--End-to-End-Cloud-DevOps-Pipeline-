# 💡 Maven’s `<id>` Matching Logic

The `<id>` in your `<distributionManagement>` must match the `<id>` in your `settings.xml` `<servers>` section.

That’s how Maven knows which credentials to use when deploying artifacts.

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

### 🗂️ `settings.xml`

```xml
<servers>
  <server>
    <id>maven-releases</id>
    <username>admin</username>
    <password>nakodtech1234</password>
  </server>

  <server>
    <id>maven-snapshots</id>
    <username>admin</username>
    <password>nakodtech1234</password>
  </server>
</servers>
```

---

### ⚙️ `pom.xml`

```xml
<distributionManagement>
  <repository>
    <id>maven-releases</id>
    <url>http://54.159.51.117:8081/repository/maven-releases/</url>
  </repository>
  <snapshotRepository>
    <id>maven-snapshots</id>
    <url>http://54.159.51.117:8081/repository/maven-snapshots/</url>
  </snapshotRepository>
</distributionManagement>
```

---

## ⚙️ How Maven Links Them

### 🔹 Step 1 — In `pom.xml`

You define **where** to deploy:

```xml
<distributionManagement>
  <snapshotRepository>
    <id>maven-snapshots</id>
    <url>http://54.159.51.117:8081/repository/maven-snapshots/</url>
  </snapshotRepository>
</distributionManagement>
```

➡️ Maven now knows: “When deploying a snapshot, use the repository with ID `maven-snapshots` at that URL.”

---

### 🔹 Step 2 — In `settings.xml`

You define **credentials** for that repository ID:

```xml
<servers>
  <server>
    <id>maven-snapshots</id>
    <username>admin</username>
    <password>nakodtech1234</password>
  </server>
</servers>
```

➡️ Maven now knows: “Whenever I need to connect to a repository with ID `maven-snapshots`, log in using `admin / nakodtech1234`.”

---

### 🔹 Step 3 — Maven Connects Them Automatically

When you run:

```bash
mvn deploy
```

Maven:

1. Reads the `pom.xml` to find the `<id>` and `<url>` for the repo.
2. Looks in `settings.xml` for the matching `<id>`.
3. Injects the `username` and `password` from there.
4. Uploads your artifact to the specified `<url>` using those credentials.

---

## 🔐 Summary

| File           | Purpose                         | Example                                  |
| -------------- | ------------------------------- | ---------------------------------------- |
| `pom.xml`      | Tells Maven **where** to deploy | `<url>http://.../maven-snapshots/</url>` |
| `settings.xml` | Tells Maven **how** to log in   | `<username>admin</username>`             |
| Match Key      | Connects both                   | `<id>maven-snapshots</id>`               |

---

## 🧠 Think of `<id>` as a Bridge

`<id>` connects the **Repository URL (pom.xml)** ↔️ **Credentials (settings.xml)**.

Once the IDs match, Maven automatically reads the repo details, adds your login info, and deploys your build securely 🚀
