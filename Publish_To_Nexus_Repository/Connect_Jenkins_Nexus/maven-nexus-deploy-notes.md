# 🚀 Maven Distribution Management — Nexus Setup Notes

## 🎯 Purpose
To publish Maven artifacts (build outputs) from your project to your **Nexus Repository Manager**, you must define where **release** and **snapshot** artifacts should be uploaded.  

This is done using the `<distributionManagement>` section in your **pom.xml** file.

---

## ⚙️ Configuration Example

### ✅ Recommended — Using Your DNS Name
```xml
<distributionManagement>
    <repository>
        <id>maven-releases</id>
        <url>http://nexus.nakodtech.xyz:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>maven-snapshots</id>
        <url>http://nexus.nakodtech.xyz:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```

💡 **Why DNS name?**  
Using your domain (`nexus.nakodtech.xyz`) is more reliable than using the IP — EC2 public IPs can change if instances are recreated.

---

### 🧩 Alternative — Using IP Address (Not Recommended)
```xml
<distributionManagement>
    <repository>
        <id>maven-releases</id>
        <url>http://54.242.229.229:8081/repository/maven-releases/</url>
    </repository>
    <snapshotRepository>
        <id>maven-snapshots</id>
        <url>http://54.242.229.229:8081/repository/maven-snapshots/</url>
    </snapshotRepository>
</distributionManagement>
```

⚠️ **Note:** Use this only temporarily — if DNS isn’t propagated yet.

---

## 🧠 Key Maven Concepts

| 🔹 Term | 💬 Description |
|----------|----------------|
| **Releases** | Stable versions of your application (e.g., `1.0`, `2.0`) |
| **Snapshots** | Development versions (e.g., `1.0-SNAPSHOT`) — can be overwritten |
| **Repository URL** | Points to the exact Nexus repo endpoint for uploads |
| **Port 8081** | Default Nexus port (HTTP) |

---

## 💡 Example in Practice
When you run:
```bash
mvn clean deploy -DskipTests
```
➡️ Maven will look at the `distributionManagement` section  
➡️ It will push your built artifacts to either:
- `maven-releases` (for stable builds), or  
- `maven-snapshots` (for development builds).

---

## 🌐 Browser & Network Note
- Some browsers **block plain HTTP** or **non-standard ports** like `8081`.  
- If Nexus doesn’t load in one browser (e.g., Chrome), try another (like Firefox or Brave).  
- This isn’t a DNS issue — it’s a **browser security behavior**.  
- ✅ Use Incognito Mode or set up HTTPS later for full compatibility.

---

## 🧾 Summary

| ✅ Step | 🧠 Action | 📘 Description |
|---------|------------|----------------|
| 1️⃣ | Update POM | Add `<distributionManagement>` for release & snapshot repos |
| 2️⃣ | Use DNS | Prefer `nexus.nakodtech.xyz` over IP address |
| 3️⃣ | Deploy | Run `mvn clean deploy` to push builds |
| 4️⃣ | Verify | Check Nexus → Repositories → “maven-releases” or “maven-snapshots” |
| 5️⃣ | Browser Tip | Try different browsers if HTTP fails |

---

### 🏁 Final Note
> 🧩 You can use either the **DNS name** or the **IP** in your URLs, but DNS is best for long-term setups.  
> 🌐 If you plan to expose Nexus publicly, set up **HTTPS** for security and browser compatibility. 🔒
