# 🌐 Domain Hosting & DNS Setup Notes

## 🪐 Step 1: Domain Registration on Spaceship

- You registered your domain → **nakodtech.xyz** with **Spaceship**.
- Spaceship acts as your **domain registrar** (where your domain is owned and managed).
- By default, Spaceship manages DNS through its own nameservers.
- You switched to **custom nameservers** to let AWS Route 53 handle DNS management.

---

## ⚙️ Step 2: Create Hosted Zone in Route 53

- In the **AWS Route 53 console**, you created a **Hosted Zone** named:
  ```
  nakodtech.xyz
  ```
- AWS automatically generated a set of **NS (Name Server)** and **SOA (Start of Authority)** records.  
  Example nameservers:
  ```
  ns-81.awsdns-10.com
  ns-1605.awsdns-08.co.uk
  ns-1081.awsdns-07.org
  ns-998.awsdns-60.net
  ```

📘 **Purpose:**  
A hosted zone is where AWS manages all DNS records (A, CNAME, MX, etc.) for your domain.

---

## 🛰️ Step 3: Update Nameservers in Spaceship

- In **Spaceship → Advanced DNS**, you changed the nameservers to point to Route 53’s NS records:
  ```
  ns-81.awsdns-10.com
  ns-1605.awsdns-08.co.uk
  ns-1081.awsdns-07.org
  ns-998.awsdns-60.net
  ```
- This delegates DNS control from Spaceship → AWS Route 53.
- After a few minutes to hours, the **Propagation Status** showed ✅ **ONLINE** — meaning global DNS recognized AWS as the authoritative DNS.

---

## 🧩 Step 4: Create DNS Records in Route 53

You created **A records** in Route 53 to map subdomains to specific EC2 instance public IPs:

| 🌍 Record Name            | 🔤 Type | 💡 Value (Public IP) | ⏱️ TTL | 🧠 Purpose          |
| ------------------------- | ------- | -------------------- | ------ | ------------------- |
| `jenkins.nakodtech.xyz`   | A       | 54.147.175.50        | 300    | Jenkins server      |
| `nexus.nakodtech.xyz`     | A       | 54.242.229.229       | 300    | Nexus artifact repo |
| `sonarqube.nakodtech.xyz` | A       | 52.87.167.141        | 300    | SonarQube server    |
| `website.nakodtech.xyz`   | A       | 3.129.128.77         | 60     | Web frontend / app  |

🧠 **TTL (Time to Live)** defines how long DNS records are cached by resolvers.  
You used **300 seconds (5 min)** for faster updates.

---

## 🧾 Step 5: Verification

- Checked DNS propagation on Spaceship → “Propagation Status: ONLINE”.
- Accessing:
  - `http://jenkins.nakodtech.xyz:8080` opens Jenkins.
  - `http://sonarqube.nakodtech.xyz:9000` opens SonarQube.
  - `http://nexus.nakodtech.xyz:8081` opens Nexus.
  - `http://website.nakodtech.xyz` points to your hosted web frontend.

✅ **Everything resolves correctly**, confirming Route 53 DNS is active and authoritative.

```sh
nslookup nexus.nakodtech.xyz
nslookup sonarqube.nakodtech.xyz
nslookup jenkins.nakodtech.xyz
```

⚠️ Browser Access Note

- Some modern browsers may block or fail to load sites over plain HTTP — especially when using non-standard ports like 8081.
- If http://nexus.nakodtech.xyz:8081 doesn’t open even though DNS and curl work, Try using a different browser

## 🧠 Summary

| 🪜 Step | ⚙️ Action            | 🧰 Tool             | 🎯 Result                 |
| ------- | -------------------- | ------------------- | ------------------------- |
| 1️⃣      | Registered domain    | Spaceship           | Domain purchased          |
| 2️⃣      | Created hosted zone  | AWS Route 53        | DNS managed in AWS        |
| 3️⃣      | Updated nameservers  | Spaceship           | Delegated DNS to Route 53 |
| 4️⃣      | Created A records    | Route 53            | Subdomains mapped to EC2  |
| 5️⃣      | Verified propagation | Spaceship / Browser | DNS resolution successful |

---

✅ **Final Result:**  
Your domain **nakodtech.xyz** and its subdomains (Jenkins, SonarQube, Nexus, Website) are fully hosted and managed via **AWS Route 53**, with DNS delegated from **Spaceship**. 🚀
