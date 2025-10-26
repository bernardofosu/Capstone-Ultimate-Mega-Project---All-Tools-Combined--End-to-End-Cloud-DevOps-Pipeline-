# 🚀 Jenkins + GitHub Webhook (Generic Webhook Trigger) — Quick Guide

**Purpose**: Explain in plain terms how GitHub sends webhook JSON to Jenkins, how to extract `$.ref` to detect branch pushes, configure the Generic Webhook Trigger in Jenkins, and avoid the common 404/ping issue.

---

## 🔧 What we will configure

- A **Jenkins job** with the **Generic Webhook Trigger** plugin enabled.
- A **GitHub webhook** that POSTs push events to Jenkins:
  `http://<JENKINS_HOST>:<PORT>/generic-webhook-trigger/invoke?token=<TOKEN>`

---

## 🧩 Why you saw `404` immediately after creating the webhook

When you _add_ a webhook on GitHub, GitHub immediately sends a **ping** to the provided URL to verify it. If Jenkins doesn't yet have a job configured with the matching Generic Webhook Trigger token, the plugin responds with:

```
{"jobs":null,"message":"Did not find any jobs with GenericTrigger configured!\nA token was supplied.\n"}
```

This is normal when the webhook is created before the job + trigger are ready. Later pushes will send real `push` payloads and trigger correctly once setup is complete. ✅

---

## ✅ Recommended order (prevents initial 404)

1. **Create the Jenkins job** first and add the Generic Webhook Trigger settings (see below).
2. Save the job.
3. **Create the GitHub webhook** with the `token` you set in step 1.
4. Optionally: after webhook creation, use GitHub’s **Redeliver** on a push delivery if you created the webhook before job existed.

---

## 🔎 Jenkins Generic Webhook Trigger — fields to configure

In your Jenkins job `Configure` → enable **Generic Webhook Trigger**.

### Post content parameters (to extract branch)

- **Variable name**: `ref`
- **Expression**: `$.ref`
- **Type**: JSONPath

This tells Jenkins: "look inside the incoming JSON and extract the `ref` field". The extracted value will be available as `$ref`, typically `refs/heads/main` for a `main` branch push.

### Optional filter (only trigger on one branch)

- **Expression**: `refs/heads/main` (this is what we expect in `$ref`)
- **Text**: `$ref`

If `$ref` equals `refs/heads/main`, the job will run. Otherwise it will be ignored.

### Token

- Set **Token** to a string, e.g. `nakodtech1234`. This must match the `token=` query param used in the GitHub webhook URL.

---

## 🌐 Example webhook URL (GitHub)

```
http://54.147.175.50:8080/generic-webhook-trigger/invoke?token=nakodtech1234
```

> Replace `54.147.175.50:8080` with your Jenkins host and `nakodtech1234` with the token you configured in the job.

---

## 🧾 What GitHub sends (short view)

When you push to `main`, GitHub posts JSON that contains (among other fields):

```json
{
  "ref": "refs/heads/main",
  "before": "...",
  "after": "...",
  "repository": { "name": "Mega-Project-CI-main", ... }
}
```

`$.ref` uses JSONPath to target that `ref` field.

---

## 🔁 Flow in layman terms

1. You push code to GitHub (e.g., `git push origin main`).
2. GitHub builds a JSON message and POSTS it to your webhook URL.
3. Jenkins plugin reads the incoming JSON, extracts `$.ref`, and stores it to `$ref`.
4. Jenkins compares `$ref` against your optional filter (for example `refs/heads/main`).

   - If it matches → job runs.
   - If it doesn't → nothing happens.

**Note**: GitHub also sends a `ping` event right after webhook creation (it’s a test). That ping may not include a `ref` the way pushes do, and if the job/token isn't present yet you’ll see the 404 message above.

---

## 🛠 Troubleshooting checklist

- ✅ **Token match**: `token=...` in GitHub URL must exactly equal token in Jenkins trigger (case-sensitive).
- ✅ **Job enabled**: Make sure the Jenkins job is enabled and saved.
- ✅ **Trigger created before webhook**: Best practice — create job/trigger first, then create the GitHub webhook.
- ✅ **Optional filter correctness**: If using a filter, ensure it matches expected `$ref` (e.g., `refs/heads/main`).
- ✅ **Debug output**: In trigger config, enable **Print post content** and **Print contributed variables** to see what GitHub actually sent to job logs.
- ✅ **Check GitHub deliveries**: GitHub Webhook → Recent Deliveries shows payloads & response codes — useful for redeliver and debugging.
- ✅ **Network**: Jenkins must be reachable from GitHub (public IP/port or via tunnel). Check firewall / security groups (port 8080/HTTP).

---

## 🔁 If you already created the webhook and got 404

1. Ensure job & Generic Trigger token exist in Jenkins.
2. Open GitHub repo → Settings → Webhooks → recent deliveries → click the failing delivery → choose **Redeliver**.
3. Watch Jenkins and GitHub deliveries — you should now get a 200 response and job triggering (if filter matches).

---

## 📌 Simplified Explanation (short, add to README) ✅

- GitHub sends a JSON package when you `git push`.
- `$.ref` is the JSONPath instruction Jenkins uses to pull the branch value out of that package (e.g., `refs/heads/main`).
- Jenkins saves that value to `$ref`.
- The **optional filter** compares `$ref` to the text you provide (e.g., `refs/heads/main`). If they match, Jenkins runs the job.
- **Important:** Add the branch you want Jenkins to react to in the optional filter — otherwise Jenkins may ignore pushes to other branches.

---

If you want, I can:

- ✍️ also create a copy of this file in your repo (push a `docs/jenkins-webhook.md`) — tell me the target git repo & credentials, or
- 🧩 produce a one-page cheat-sheet image or short script to test webhooks locally.

Would you like the file saved to your workspace (I can create it here for you to download)? ✅
