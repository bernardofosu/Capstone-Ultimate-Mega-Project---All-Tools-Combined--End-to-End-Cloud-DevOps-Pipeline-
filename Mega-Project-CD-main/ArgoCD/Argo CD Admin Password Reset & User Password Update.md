# 🔧 **Argo CD Admin Password Reset & User Password Update Notes**

---

## 🧰 **1️⃣ Install the Helper Tool (`apache2-utils`)**

You need this tool to generate a secure bcrypt hash for your new Argo CD password.

```bash
sudo apt-get update && sudo apt-get install -y apache2-utils
```

🧠 _This installs `htpasswd`, which lets you create bcrypt-hashed passwords._

---

## 🔐 **2️⃣ Generate & Patch a New Admin Password**

### 👉 Example new password: `NewAdminP@ssw0rd!`

(Replace it with your own strong password.)

```bash
# Generate bcrypt hash and base64 encode it
htpasswd -bnBC 10 "" 'NewAdminP@ssw0rd!' | tr -d ':
' > /tmp/argocd_bcrypt.txt
ADMIN_PW_B64=$(base64 -w0 /tmp/argocd_bcrypt.txt)
```

Now patch the Argo CD Kubernetes secret with this new password:

```bash
kubectl -n argocd patch secret argocd-secret \
  -p "{\"data\":{\"admin.password\":\"${ADMIN_PW_B64}\",\"admin.passwordMtime\":\"$(date +%FT%T%Z | base64 -w0)\"}}"
```

✅ This immediately replaces the stored admin password with your new one.

---

## 🔓 **3️⃣ Re-Enable the Admin Account (If Disabled)**

If you previously disabled `admin`, turn it back on so you can log in.

```bash
kubectl -n argocd patch configmap argocd-cm --type merge -p '{"data":{"admin.enabled":"true"}}'
```

Then restart the Argo CD API server:

```bash
kubectl -n argocd rollout restart deployment argocd-server
kubectl -n argocd wait --for=condition=available --timeout=180s deployment/argocd-server
```

---

## 🚪 **4️⃣ Log In with the New Admin Password**

Use the CLI to log in to Argo CD.

```sh
argocd account get-user-info
```

```bash
argocd login a5fd69d6de76b4e16a126efc0a2454db-1757951584.us-east-1.elb.amazonaws.com \
  --username admin \
  --password 'NewAdminP@ssw0rd!' \
  --insecure
```

```bash
argocd login a3f85743a7cc046968481b5369bed7d5-1180477962.us-east-1.elb.amazonaws.com\
  --username admin \
  --password 'X4bCVy9o0WYBgyzM' \
  --insecure
```

✅ You should see:

```
'admin:login' logged in successfully
Context '<your-argocd-server>' updated
```

---

## 👤 **5️⃣ Update a New User’s Password (e.g., devops)**

Once logged in as admin:

```bash
argocd account update-password --account devops
```

Then follow the prompts:

```
*** Enter password of currently logged in user (admin):  NewAdminP@ssw0rd!
*** Enter new password for user devops:  <new-devops-password>
*** Confirm new password for user devops:  <repeat-password>
Password updated
```

✅ You’ll see `Password updated` when successful.

---

## 🚷 **6️⃣ (Optional) Disable Admin Again for Security**

Once the new user (`devops`) works fine, disable the `admin` account:

```bash
kubectl -n argocd patch configmap argocd-cm --type merge -p '{"data":{"admin.enabled":"false"}}'
kubectl -n argocd rollout restart deployment argocd-server
```

---

## 🧾 **Summary Table**

| Step | Action                          | Command / Notes                                   |
| ---- | ------------------------------- | ------------------------------------------------- |
| 1️⃣   | Install helper                  | `sudo apt install apache2-utils -y`               |
| 2️⃣   | Generate & patch admin password | `htpasswd`, `kubectl patch secret`                |
| 3️⃣   | Enable admin                    | `kubectl patch configmap argocd-cm`               |
| 4️⃣   | Login with new admin password   | `argocd login ... --username admin`               |
| 5️⃣   | Update user password            | `argocd account update-password --account devops` |
| 6️⃣   | (Optional) Disable admin        | `kubectl patch configmap argocd-cm`               |

---

✨ **Pro Tip:**
Always restart the `argocd-server` deployment after modifying secrets or the ConfigMap, and confirm pods are running before logging in again.
