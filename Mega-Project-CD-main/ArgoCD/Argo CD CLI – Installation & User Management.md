# 🚀 **Argo CD CLI – Installation & User Management Notes**

📖 **Official Reference:**
🔗 [Argo CD CLI Installation Guide](https://kostis-argo-cd.readthedocs.io/en/refresh-docs/getting_started/install_cli/)

---

## 🧰 **1️⃣ Install Argo CD CLI**

### 🐧 **On Linux**

```bash
# Get the latest release version
ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" \
| grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

# Download the binary
curl -sSL -o /tmp/argocd-${ARGOCD_VERSION} \
https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64

# Make it executable & move to PATH
chmod +x /tmp/argocd-${ARGOCD_VERSION}
sudo mv /tmp/argocd-${ARGOCD_VERSION} /usr/local/bin/argocd

# Verify
argocd version --client
```

🟢 **Expected output:**

```
argocd: v1.x.x
BuildDate: 2025-xx-xxTxx:xx:xxZ
Platform: linux/amd64
```

---

### 🍎 **On macOS (Darwin)**

🧃 **Option 1 – Homebrew:**

```bash
brew install argocd
```

🧃 **Option 2 – Manual:**

```bash
ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" \
| grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

curl -sSL -o /tmp/argocd-${ARGOCD_VERSION} \
https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-darwin-amd64

chmod +x /tmp/argocd-${ARGOCD_VERSION}
sudo mv /tmp/argocd-${ARGOCD_VERSION} /usr/local/bin/argocd

argocd version --client
```

---

### 🪟 **On Windows**

🧩 **Option 1 – Via WSL:**
Install WSL 1 or 2, then follow Linux steps.

🧩 **Option 2 – Manual:**

```cmd
cd c:\
md myapps
cd myapps
curl -sSL -o argocd.exe https://github.com/argoproj/argo-cd/releases/latest/download/argocd-windows-amd64.exe
argocd version --client
```

➡️ Add `C:\myapps` to your Windows PATH variable.

---

## 🔑 **2️⃣ View Current Admin Password**

When Argo CD is first deployed, the default `admin` password is stored in a Kubernetes secret:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## 🔐 **3️⃣ Login & Change the Admin Password**

```bash
argocd login a5fd69d6de76b4e16a126efc0a2454db-1757951584.us-east-1.elb.amazonaws.com \
  --username admin \
  --password YGBATh51FA67LndB \
  --insecure
```

✅ **Output:**

```
'admin:login' logged in successfully
Context '<your-argocd-server>' updated
```

```sh
argocd account get-user-info
```

Now change your password:

```bash
argocd account update-password
```

Then delete the initial secret for security:

```bash
kubectl -n argocd delete secret argocd-initial-admin-secret
```

---

## 👥 **4️⃣ Create a New User**

Argo CD only has one built-in account (`admin`).
You can’t rename it, but you can **create new accounts**.

1️⃣ Edit the ConfigMap:

```bash
kubectl -n argocd edit configmap argocd-cm
```

2️⃣ Add under `data:`

```yaml
data:
  accounts.devops: apiKey, login
```

3️⃣ Restart the Argo CD API server:

```bash
kubectl -n argocd rollout restart deployment argocd-server
```

4️⃣ Set a password for the new user:

```bash
argocd account update-password --account devops
```

---

## 🚫 **5️⃣ Disable the Default Admin (Recommended)**

Once your new user works fine, disable the default admin account:

```bash
kubectl -n argocd edit configmap argocd-cm
```

Add:

```yaml
data:
  admin.enabled: "false"
```

Restart the server:

```bash
kubectl -n argocd rollout restart deployment argocd-server
```

---

## ✅ **Summary Table**

| Task                     | Command                                            | Notes                           |
| ------------------------ | -------------------------------------------------- | ------------------------------- |
| 🔍 View initial password | `kubectl get secret argocd-initial-admin-secret`   | Default admin password          |
| 🔑 Login                 | `argocd login <server>`                            | Use `--insecure` if self-signed |
| 🔁 Change password       | `argocd account update-password`                   | Update admin password           |
| 🧑‍💻 Create new user       | Edit `argocd-cm`                                   | Add `accounts.username`         |
| 🚷 Disable admin         | `admin.enabled: "false"`                           | Better security                 |
| 🔄 Restart API server    | `kubectl rollout restart deployment argocd-server` | Apply changes                   |

---

✨ **Pro Tip:**
Use CLI for day-to-day admin tasks, and UI for visual monitoring & deployment management.
