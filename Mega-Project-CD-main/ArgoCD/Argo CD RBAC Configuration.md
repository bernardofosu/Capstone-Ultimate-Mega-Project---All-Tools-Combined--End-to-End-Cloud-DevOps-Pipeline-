# ⚙️ **Argo CD RBAC Configuration & Verification Notes**

---

## 🧩 **Option 1 — Use YAML Patch (Cleanest)**

Run this multi-line `kubectl patch` command — it avoids any JSON escape issues:

```bash
kubectl -n argocd patch configmap argocd-rbac-cm --type merge -p '
data:
  policy.csv: |
    p, role:devops, applications, *, *, allow
    p, role:devops, clusters, *, *, allow
    p, role:devops, repositories, *, *, allow
    p, role:devops, projects, *, *, allow
    p, role:devops, accounts, *, *, allow
    g, devops, role:devops
  policy.default: role:readonly
'
```

✅ This gives the `devops` user full access and prevents newline parsing errors.

---

## ✏️ **Option 2 — Use `kubectl edit` (Manual Way)**

If you prefer editing directly in your terminal:

```bash
kubectl -n argocd edit configmap argocd-rbac-cm
```

Then paste this under the `data:` section:

```yaml
kubectl -n argocd patch configmap argocd-rbac-cm --type merge -p '
data:
  policy.csv: |
    # allow devops to fully manage applications
    p, role:devops, applications, get, *, allow
    p, role:devops, applications, list, *, allow
    p, role:devops, applications, create, *, allow
    p, role:devops, applications, update, *, allow
    p, role:devops, applications, delete, *, allow
    p, role:devops, applications, sync, *, allow
    # allow devops to manage clusters/repos/projects if needed
    p, role:devops, clusters, *, *, allow
    p, role:devops, repositories, *, *, allow
    p, role:devops, projects, *, *, allow
    # map user devops -> role:devops
    g, devops, role:devops
  policy.default: role:readonly
'
```

💾 Save and exit (`:wq` in `vi`/`vim`).

---

## 🔄 **Restart Argo CD**

Apply and reload the RBAC configuration to take effect:

```bash
kubectl -n argocd rollout restart deployment argocd-server
kubectl -n argocd wait --for=condition=available --timeout=180s deployment/argocd-server
```

---

## 🔐 **Verify Configuration**

Check that your new policies exist:

```bash
kubectl -n argocd get configmap argocd-rbac-cm -o yaml | grep -A 10 policy.csv
```

✅ You should see the `policy.csv` lines with your `devops` role mappings.

---

## 🧩 **Quick Verification — Confirm `devops` Access**

### 1️⃣ **Refresh the Web UI**

- Log out and log back in as `devops`.
- Open the **Applications** page — it should now load without “permission denied.”

### 2️⃣ **Test from CLI**

Replace `<DEVOPS_PASSWORD>` with your actual password:

```bash
argocd login a5fd69d6de76b4e16a126efc0a2454db-1757951584.us-east-1.elb.amazonaws.com \
  --username devops --password '<DEVOPS_PASSWORD>' --insecure

argocd app list
```

✅ You should see your Argo CD apps listed (e.g., `bankapp`).

---

## 🚫 **Optional: Disable the Default Admin**

Once your new user works fine, disable `admin` for better security:

```bash
kubectl -n argocd patch configmap argocd-cm --type merge -p '{"data":{"admin.enabled":"false"}}'
kubectl -n argocd rollout restart deployment argocd-server
kubectl -n argocd wait --for=condition=available --timeout=180s deployment/argocd-server
```

---

## 🎯 **Optional: Tighten `devops` Permissions (Restrict to Single App)**

If you want `devops` to access only **one app** (e.g., `bankapp`) instead of full cluster rights, apply this:

```bash
kubectl -n argocd patch configmap argocd-rbac-cm --type merge -p '
data:
  policy.csv: |
    # Allow devops to get/list all apps (view)
    p, role:devops, applications, get, *, allow
    p, role:devops, applications, list, *, allow
    # Allow devops to sync and override ONLY argocd/bankapp
    p, role:devops, applications, sync, argocd/bankapp, allow
    p, role:devops, applications, override, argocd/bankapp, allow
    g, devops, role:devops
  policy.default: role:readonly
'

kubectl -n argocd rollout restart deployment argocd-server
```

✅ This limits `devops` to **view all apps** but **sync only `bankapp`**.

---

## 🧾 **Summary Table**

| Step | Action                      | Command / Description                              |
| ---- | --------------------------- | -------------------------------------------------- |
| 1️⃣   | Add RBAC rules (YAML patch) | `kubectl patch configmap argocd-rbac-cm`           |
| 2️⃣   | Edit manually (optional)    | `kubectl edit configmap argocd-rbac-cm`            |
| 3️⃣   | Restart Argo CD             | `kubectl rollout restart deployment argocd-server` |
| 4️⃣   | Verify config               | `kubectl get configmap argocd-rbac-cm -o yaml`     |
| 5️⃣   | Test UI & CLI access        | `argocd login ... && argocd app list`              |
| 6️⃣   | (Optional) Disable admin    | `kubectl patch configmap argocd-cm`                |
| 7️⃣   | (Optional) Restrict user    | Apply specific RBAC policy for one app             |

---

✨ **Pro Tip:**
You can inspect active RBAC policies directly on the server with:

```bash
kubectl -n argocd exec -it deploy/argocd-server -- argocd-util rbac dump
```

This helps verify which roles and permissions each user currently holds.
