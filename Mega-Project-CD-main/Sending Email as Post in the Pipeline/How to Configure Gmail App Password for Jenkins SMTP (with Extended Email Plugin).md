# 📧 How to Configure Gmail App Password for Jenkins SMTP (with Extended Email Plugin)

## 💡 Purpose

This guide shows how to configure **Jenkins** to send emails securely using **Gmail SMTP** and **Google App Passwords**, including setting up the **Extended E-mail Plugin** and **opening port 587** for SMTP.

---

## ⚙️ Step-by-Step Setup

### 🧙‍♂️ Step 1 — Install the Extended E-mail Notification Plugin

1. Go to **Manage Jenkins → Plugins → Available plugins**.
2. In the search bar, type **“Extended E-mail Notification”**.
3. Check ✅ the box next to it.
4. Click **Install without restart**.
5. Once installed, verify under **Manage Jenkins → Installed plugins**.

💡 This plugin provides better control over mail formatting, triggers, and recipients compared to the default mailer.

---

### 🔐 Step 2 — Generate a Gmail App Password

🔗 Visit: [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)

⚠️ **Prerequisites:**

- You must have **2-Step Verification** enabled on your Google account.
- Sign in with the same Gmail account you plan to use in Jenkins.

**Steps:**

1. Under **Select App**, choose **Other (Custom name)**.
2. Enter `Jenkins` (or a preferred label).
3. Click **Generate**.
4. Copy the **16-character password** (e.g., `abcd efgh ijkl mnop`).

   > ⚠️ Save it securely — it’s shown only once!

---

### ⚙️ Step 3 — Configure SMTP for Gmail

1. Go to **Manage Jenkins → System Configuration → Configure System**.
2. Scroll to the **Extended E-mail Notification** section.
3. Enter these details:

```
SMTP Server: smtp.gmail.com
SMTP Port: 587
Use SMTP Authentication: ✅
Username: your_email@gmail.com
Password: [Paste your App Password]
Use TLS: ✅
Default user e-mail suffix: @gmail.com
```

4. _(Optional)_ Configure **Default Recipients**, **Reply-To**, and **Content Type** as needed.
5. Click **Test configuration** to ensure the email is sent successfully.

---

### 🧾 Step 4 — Add Jenkins Credentials (Recommended)

1. Navigate to **Manage Jenkins → Credentials → Global → Add Credentials**.
2. Choose **Username with password**.
3. Fill in:

   - **Username:** `your_email@gmail.com`
   - **Password:** your **App Password**
   - **ID:** `mail-cred`
   - **Description:** `Gmail SMTP App Password`

4. Click **Add**.

Then, go back to **Configure System → Extended E-mail Notification** and select this credential `mail-cred`.

---

### 🔒 Step 5 — Open Port 587 on Jenkins Server (for Gmail SMTP)

If Jenkins runs on **AWS EC2** or a VM behind a firewall, open the SMTP port:

#### 🔧 AWS Security Group Configuration:

1. Go to **EC2 → Security Groups**.
2. Select your **Jenkins server’s security group**.
3. Click **Edit inbound rules → Add rule**.
4. Choose:

   - **Type:** Custom TCP
   - **Port range:** `587`
   - **Source:** `0.0.0.0/0` _(for testing; restrict later for security)_

5. Click **Save rules**.

✅ Jenkins can now communicate with Gmail’s SMTP over **TLS (port 587)**.

---

### 📩 Step 6 — Test the Email Setup

1. Go to **Manage Jenkins → Configure System → Extended E-mail Notification**.
2. Click **Test configuration** and enter your recipient address.
3. Check your inbox 📥 — if everything’s configured correctly, you’ll receive a test email.

---

## 🧠 Summary

| Step | Action                         | Description                                    |
| ---- | ------------------------------ | ---------------------------------------------- |
| 1    | Install Extended E-mail Plugin | Enables advanced email configuration           |
| 2    | Generate App Password          | Create Gmail App Password for Jenkins          |
| 3    | Configure SMTP                 | Add Gmail SMTP settings                        |
| 4    | Add Credentials                | Store email + password securely as `mail-cred` |
| 5    | Open Port 587                  | Allow Jenkins server to connect to Gmail       |
| 6    | Test Email                     | Verify successful email delivery ✅            |

---

## 🎯 Final Result

Jenkins is now fully configured to send email notifications securely through **Gmail SMTP (TLS/587)** using an **App Password** and the **Extended E-mail Plugin**.
