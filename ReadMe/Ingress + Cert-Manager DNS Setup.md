# 🌍 Ingress + Cert-Manager DNS Setup for `nakodtech.xyz`

This guide explains how to set up **Ingress NGINX**, **Cert-Manager**, and **Let’s Encrypt SSL certificates** for your Kubernetes cluster hosted on **AWS** — with the domain **`nakodtech.xyz`**.

---

## 🧱 Step 1: Install NGINX Ingress Controller

Deploy the official **Ingress-NGINX Controller** (cloud version) using this command 👇

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

### ✅ Verification

After a few seconds, run:

```bash
kubectl get pods -n ingress-nginx
```

You should see something like:

```
NAME                                       READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-7f894db6f-9mzs2   1/1     Running   0          2m30s
```

Then check the service:

```bash
kubectl get svc -n ingress-nginx
```

Example output:

```
NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   172.20.152.119   ad95be489983e46039f091c85f77e9e5-1034547914.us-east-1.elb.amazonaws.com   80:31927/TCP,443:32648/TCP   2m41s
```

💡 **This EXTERNAL-IP (ELB hostname)**
`ad95be489983e46039f091c85f77e9e5-1034547914.us-east-1.elb.amazonaws.com`
is your **public entry point** — you’ll map your domain to this in Route 53.

---

## 🔐 Step 2: Install Cert-Manager

Run this command to install **Cert-Manager**, which will handle SSL/TLS certificates:

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.12.2/cert-manager.yaml
```

### ✅ Verification

Check Cert-Manager pods:

```bash
kubectl get pods -n cert-manager
```

Expected output:

```
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-66f4f6fb7f-jlp79              1/1     Running   0          21s
cert-manager-cainjector-6c95876955-f5j7m   1/1     Running   0          21s
cert-manager-webhook-7b845f6857-z6n8n      1/1     Running   0          21s
```

Perfect ✅ — Cert-Manager is up and running.

---

## 💾 Step 3: Configure the ClusterIssuer

Now create a **ClusterIssuer** so Cert-Manager knows how to request certificates from **Let’s Encrypt**.

Create a file named:

```
clusterissuer-letsencrypt-prod.yaml
```

Paste the following:

```yaml
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: office@devopsshack.com # Change to your email
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
      - http01:
          ingress:
            class: nginx
```

Apply the ClusterIssuer:

```bash
kubectl apply -f clusterissuer-letsencrypt-prod.yaml
```

---

## 🌐 Step 4: Configure DNS Records in Route 53

Go to **AWS Route 53 → Hosted Zones → nakodtech.xyz**
Create the following records 👇

| Record Type | Name                | Value / Target                                                            | TTL | Description                                 |
| ----------- | ------------------- | ------------------------------------------------------------------------- | --- | ------------------------------------------- |
| `A`         | `nakodtech.xyz`     | `ad95be489983e46039f091c85f77e9e5-1034547914.us-east-1.elb.amazonaws.com` | 300 | Points root domain to Ingress Load Balancer |
| `CNAME`     | `www.nakodtech.xyz` | `nakodtech.xyz`                                                           | 300 | Redirects `www` to the main domain          |

💡 **Tip:**
If using Route 53 alias records:

- Choose **Type:** A (Alias)
- Select **Alias to Application Load Balancer**
- Choose your ELB from the dropdown list

---

## 🧩 Step 5: Verify DNS Propagation

Run the following:

```bash
nslookup nakodtech.xyz
```

Expected result:

```
nakodtech.xyz canonical name = ad95be489983e46039f091c85f77e9e5-1034547914.us-east-1.elb.amazonaws.com.
```

Also check:

```bash
curl -I http://nakodtech.xyz
```

You should see:

```
HTTP/1.1 404 Not Found
Server: nginx/1.21.6
```

That means your **Ingress Controller** is active and routing requests. 🎯

---

## 🔏 Step 6: Deploy Your Application and Ingress Rule

When deploying your app, create an **Ingress resource** like this 👇

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bankapp-ingress
  namespace: webapps
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - nakodtech.xyz
        - www.nakodtech.xyz
      secretName: bankapp-tls
  rules:
    - host: nakodtech.xyz
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: bankapp-service
                port:
                  number: 80
```

Apply it:

```bash
kubectl apply -f ingress.yaml
```

---

## 🔍 Step 7: Verify Certificate Issuance

Check if the certificate is created and valid:

```bash
kubectl get certificates -A
kubectl describe certificate bankapp-tls -n webapps
```

You should see:

```
Type: Ready
Status: True
Reason: CertificateIssued
```

🎉 Boom! SSL is automatically handled by Cert-Manager + Let’s Encrypt.

---

## 🧠 Summary

| Component           | Purpose                      | Status        |
| ------------------- | ---------------------------- | ------------- |
| **Ingress NGINX**   | Routes external traffic      | ✅ Installed  |
| **Cert-Manager**    | Manages TLS certificates     | ✅ Installed  |
| **ClusterIssuer**   | Uses Let’s Encrypt for SSL   | ✅ Configured |
| **DNS (Route 53)**  | Maps domain to Ingress       | ✅ Working    |
| **TLS Certificate** | Auto-renewed by Cert-Manager | 🔒 Active     |

---

## 🏁 Final Verification

Visit your site in a browser:

```
https://nakodtech.xyz
```

✅ You should see a **valid SSL certificate** issued by **Let’s Encrypt**.

---

## 💡 Notes

- Certificates renew **automatically** before expiry.
- For testing, you can use `letsencrypt-staging` instead of `letsencrypt-prod`.
- You can manage all certificates by:

  ```bash
  kubectl get certificate -A
  ```

---

📄 **Author:** NakodTech Ltd
🔗 **Domain:** [nakodtech.xyz](https://nakodtech.xyz)
🛠️ **Platform:** AWS EKS + Route 53 + Cert-Manager
