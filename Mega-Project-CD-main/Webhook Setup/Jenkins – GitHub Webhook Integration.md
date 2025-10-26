# 🚀 Jenkins – GitHub Webhook Integration (Generic Webhook Trigger)

## 🔧 Purpose

Automatically trigger Jenkins pipeline jobs when you push code to GitHub — using the **Generic Webhook Trigger Plugin**.

---

## 🧩 Step-by-Step Setup

### 🪄 1️⃣ Install the Plugin

- Navigate to **Manage Jenkins → Plugins → Available**
- Search 🔍 for **Generic Webhook Trigger**
- ✅ Check the box and click **Install without restart**
- Confirm it’s listed under **Installed plugins**

---

### 🔑 2️⃣ Add Webhook Token Credential

Go to **Manage Jenkins → Credentials → System → Global → Add Credentials**
Then fill in the following:

| Field       | Example           |
| ----------- | ----------------- |
| Kind        | Secret text       |
| Scope       | Global            |
| Secret      | `nakodtech1234`   |
| ID          | `webhook_trigger` |
| Description | `webhook-trigger` |

Click **Add** ✅

🧠 _This token secures your webhook connection between GitHub and Jenkins._

---

### ⚙️ 3️⃣ Enable Webhook Trigger in Jenkins Job

1. Open your Jenkins pipeline job (e.g., **Mega-Project**)
2. Click **Configure**
3. Scroll to **Build Triggers**
4. ✅ Enable **Generic Webhook Trigger**

You’ll see this info:

```
Triggered by HTTP requests to:
http://<JENKINS_URL>/generic-webhook-trigger/invoke
```

---

### 🗾 4️⃣ Define Webhook Variables

Under the **Generic Webhook Trigger** section:

| Field      | Example  |
| ---------- | -------- |
| Variable   | `ref`    |
| Expression | `$.ref`  |
| Type       | JSONPath |

🧠 This extracts the Git branch reference (like `refs/heads/main`) from the JSON payload sent by GitHub.

---

### 🧮 5️⃣ Add Optional Branch Filter

Add the following values to **Optional filter**:

| Field          | Value             |
| -------------- | ----------------- |
| **Expression** | `refs/heads/main` |
| **Text**       | `$ref`            |

✅ Ensures that Jenkins triggers only when you push to the **main** branch.

---

### 🌐 6️⃣ Build Your Webhook URL

You must append `/invoke?token=TOKEN` to the base webhook URL.

**Base URL:**

```
http://<JENKINS_URL>/generic-webhook-trigger/invoke
```

**Final Webhook URL Example:**

```
http://54.147.175.50:8080/generic-webhook-trigger/invoke?token=nakodtech1234
```

🧠 Replace `nakodtech1234` with your actual Secret Token.

---

### 🧱 7️⃣ Configure the GitHub Webhook

In GitHub:

1. Go to **Settings → Webhooks → Add webhook**
2. Fill in the form like this:

| Field                | Example                                                                        |
| -------------------- | ------------------------------------------------------------------------------ |
| **Payload URL**      | `http://54.147.175.50:8080/generic-webhook-trigger/invoke?token=nakodtech1234` |
| **Content type**     | `application/json`                                                             |
| **Secret**           | (Leave empty or same token)                                                    |
| **SSL verification** | 🚫 Disable (if Jenkins uses HTTP)                                              |
| **Event trigger**    | ✅ Just the push event                                                         |
| **Active**           | ✅ Enabled                                                                     |

---

### 🧪 8️⃣ Test the Webhook

- Push any commit to your **main** branch.
- Jenkins should automatically start the pipeline! 🎉

Check under GitHub → **Settings → Webhooks → Recent Deliveries** — response should be `200 OK ✅`.

---

## 🧠 Example Payload (From GitHub)

GitHub sends a JSON payload like:

```json
{
  "ref": "refs/heads/main",
  "repository": {
    "name": "Mega-Project-CI-main"
  },
  "pusher": {
    "name": "bernardofosu"
  }
}
```

Jenkins reads this data and triggers the job since `ref=refs/heads/main`.

---

## 🧮 Verification Checklist

| ✅ Task                 | Description                             |
| ----------------------- | --------------------------------------- |
| Plugin installed        | Generic Webhook Trigger Plugin added    |
| Credential created      | Secret text (`nakodtech1234`)           |
| Webhook trigger enabled | Checked in job config                   |
| Variable added          | `ref` with `$.ref`                      |
| Branch filter set       | `refs/heads/main`                       |
| Webhook URL configured  | Includes `/invoke?token=...`            |
| Push event test         | Jenkins triggers build automatically 🎯 |

---

### 📊 Test Webhook with Curl

You can test manually from your terminal:

```bash
curl -X POST http://54.147.175.50:8080/generic-webhook-trigger/invoke?token=nakodtech1234 \
-H "Content-Type: application/json" \
-d '{"ref":"refs/heads/main"}'
```

Expected result → Jenkins triggers instantly 🚀

---

## 🗾 Summary

| Step | Action           | Description                                    |
| ---- | ---------------- | ---------------------------------------------- |
| 1️⃣   | Install Plugin   | Add Generic Webhook Trigger Plugin             |
| 2️⃣   | Create Token     | Add Secret Text credential                     |
| 3️⃣   | Enable Trigger   | Turn on Generic Webhook Trigger in Jenkins job |
| 4️⃣   | Add Variable     | Capture branch reference (`$.ref`)             |
| 5️⃣   | Filter Branch    | Trigger only on `main`                         |
| 6️⃣   | Build URL        | Append `/invoke?token=TOKEN`                   |
| 7️⃣   | Configure GitHub | Add Webhook under repo settings                |
| 8️⃣   | Test             | Push to main → Jenkins runs automatically 🎉   |

---

## ✅ Example Webhook URL

```
http://54.147.175.50:8080/generic-webhook-trigger/invoke?token=nakodtech1234
```

---

📬 **Result:**
Your Jenkins pipeline is now fully integrated with GitHub Webhooks — automatic, secure, and branch-specific! 💪✨
