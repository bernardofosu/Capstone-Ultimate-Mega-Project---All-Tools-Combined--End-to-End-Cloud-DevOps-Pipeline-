# 🔔 How to Configure GitHub Webhook for Argo CD

Enable **instant GitOps synchronization** between your private GitHub repository and Argo CD by configuring a webhook. This ensures that every time you push changes to your repo, Argo CD automatically detects and deploys them — no manual refresh or polling delay required 🚀.

---

## 🧩 Step 1: Get Your Argo CD API Server URL

You’ll need the **public endpoint** (LoadBalancer or Ingress) of your Argo CD API server.

Run this command:

```bash
kubectl -n argocd get svc argocd-server
```

Look for the `EXTERNAL-IP` or domain (for example):

```
EXTERNAL-IP: a5fd69d6e76b4e16a126efc0a2454db-1757951584.us-east-1.elb.amazonaws.com
```

👉 Copy this URL — you’ll use it in your GitHub webhook.

Your **webhook URL** format will be:

```
https://<ARGOCD_EXTERNAL_IP>/api/webhook
```

> 💡 Example:
>
> ```
> https://a5fd69d6e76b4e16a126efc0a2454db-1757951584.us-east-1.elb.amazonaws.com/api/webhook
> ```

If you use a domain (like `argocd.nakodtech.xyz`), your webhook URL would be:

```
https://argocd.nakodtech.xyz/api/webhook
```

---

## ⚙️ Step 2: Add Webhook in GitHub

1. Go to your repository → **Settings → Webhooks → Add Webhook**

2. Fill in the following:

   - **Payload URL:**

     ```
     https://<ARGOCD_EXTERNAL_IP>/api/webhook
     ```

   - **Content type:** `application/json`
   - **Secret:** _(leave blank or set a custom secret — optional)_
   - **SSL verification:** Keep enabled ✅
   - **Which events would you like to trigger this webhook?**

     - Select **Just the push event** 🔁

3. Click **Add Webhook**.

GitHub will immediately send a test ping to your Argo CD server.

---

## 🧠 Step 3: Verify in Argo CD

Once configured:

- Go to your Argo CD UI → select your app (e.g. `bankapp`).
- Open **App Details → History and Rollback**.
- When you push to GitHub, Argo CD will automatically detect the change and start syncing instantly.

If you have **auto-sync enabled**, deployment will occur automatically 🎯.

---

## 🧩 Step 4: Troubleshooting

If Argo CD doesn’t auto-sync:

🔍 Check the Argo CD server logs:

```bash
kubectl -n argocd logs deploy/argocd-server | grep webhook
```

🔐 Make sure your Argo CD server is accessible publicly (via LoadBalancer or Ingress).

⚠️ If you’re using a self-signed certificate, disable SSL verification in the webhook setup temporarily (for testing only).

---

## 🎉 Final Result

| Feature                 | Status             |
| ----------------------- | ------------------ |
| Auto-deploy on Git push | ✅ Enabled         |
| Secure HTTPS webhook    | ✅ Configured      |
| Sync delay eliminated   | 🚀 Instant updates |

You now have **real-time GitOps deployments** — every code push to your main branch will instantly trigger Argo CD to update your Kubernetes cluster ⚡.
