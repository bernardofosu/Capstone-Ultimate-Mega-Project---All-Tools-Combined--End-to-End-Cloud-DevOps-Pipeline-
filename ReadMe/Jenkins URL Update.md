# 🧩 Terraform + Jenkins URL Update Notes

> 🧠 **Context:** You ran a `sed` command to update Jenkins’ `jenkinsUrl` in the file:
> `/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml` — but the URL didn’t change.

---

## 💡 Root Cause

Your original command:

```bash
sudo sed -i 's#<jenkinsUrl>.\*</jenkinsUrl>#<jenkinsUrl>http://54.147.175.50:8080/</jenkinsUrl>#' /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
```

✅ The issue: You escaped `*` like `\*`, so `sed` literally searched for the characters `. *` — **not** a wildcard pattern. Hence, no match was found and no replacement happened.

Additionally, `sed` reads line by line, so if `<jenkinsUrl>` spans multiple lines, it won’t match across them.

---

## ✅ Correct Command (when tag is on a single line)

```bash
sudo sed -i 's#<jenkinsUrl>.*</jenkinsUrl>#<jenkinsUrl>http://54.147.175.50:8080/</jenkinsUrl>#' /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
```

✨ **Fix:** Use `.*` (not `\.\*`) since inside single quotes `*` doesn’t need escaping.

---

## 🧠 When Tag Might Span Multiple Lines

Use **Perl** to handle multi-line XML safely:

```bash
sudo perl -0777 -i -pe 's#<jenkinsUrl>.*?</jenkinsUrl>#<jenkinsUrl>http://54.147.175.50:8080/</jenkinsUrl>#s' /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
```

Explanation:

- `-0777`: reads the entire file as one string (multi-line mode).
- `.*?`: non-greedy match.
- `s`: allows `.` to match newline characters.

---

## ⚙️ XML-Safe Editing (Recommended)

Use `xmlstarlet` for clean, XML-aware modifications:

```bash
sudo apt install xmlstarlet -y

sudo xmlstarlet ed -u "//jenkinsUrl" -v "http://54.147.175.50:8080/" \
  /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml > tmp.xml && \
  sudo mv tmp.xml /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
```

📘 **Why better?** It understands XML structure, so you won’t break formatting or nested tags.

---

## 🔄 Apply Changes

After editing the file, restart Jenkins to load the new configuration:

```bash
sudo systemctl restart jenkins
```

Verify via browser:
👉 `http://54.147.175.50:8080`

---

## 🔍 Summary Table

| ⚙️ Scenario           | 🧩 Issue                    | 🪄 Solution       |
| --------------------- | --------------------------- | ----------------- |
| Simple one-line tag   | Wrong regex (`.\*` literal) | Use `.*` properly |
| Multiline XML         | `sed` can’t cross lines     | Use Perl `-0777`  |
| Want clean, safe edit | Manual edits risky          | Use `xmlstarlet`  |

---

## 🚀 Bonus Tip — Auto-detect EC2 Public IP

You can dynamically insert your EC2 public IP into Jenkins config:

```bash
PUBIP=$(curl -s http://checkip.amazonaws.com)

sudo sed -i "s#<jenkinsUrl>.*</jenkinsUrl>#<jenkinsUrl>http://$PUBIP:8080/</jenkinsUrl>#" \
  /var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
```

That way, Jenkins always uses the correct external URL after redeployment. 🌍

---

📝 **In short:**

- 🧩 Don’t escape `*` inside single quotes.
- 🧰 Use `Perl` or `xmlstarlet` for multi-line XML.
- ⚙️ Restart Jenkins after config changes.
- 🚀 Optionally automate with EC2 public IP.

✨ _Now your Jenkins URL updates will actually stick!_ 💪
