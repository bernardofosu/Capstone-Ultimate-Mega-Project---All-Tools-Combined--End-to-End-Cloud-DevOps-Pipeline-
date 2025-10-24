# 🧩 EKS Add-on Verification & Ownership Check Guide

This guide helps you verify **whether the AWS EBS CSI Driver** in your EKS cluster is managed by AWS as an add-on or was deployed manually.

---

## 🧱 1️⃣ Check AWS-Side (Add-on Presence & Status)

```bash
aws eks describe-addon   --cluster-name nakodtech-cluster   --addon-name aws-ebs-csi-driver   --region us-east-1   --output json
```

### 🧠 Interpretation:
- `"status": "ACTIVE"` → ✅ The add-on exists and AWS is managing it.
- `"status": "UPDATING"` / `"DEGRADED"` → ⚙️ AWS is reapplying or having issues.

🔍 Check:
- `.addon.serviceAccountRoleArn`
- `.health.issues`
for more details.

---

## 🔍 2️⃣ Inspect Kubernetes Objects

### 🧩 Deployment (Controller)
```bash
kubectl get deployment ebs-csi-controller -n kube-system   -o jsonpath='{.metadata.labels}{"\n"}{.metadata.annotations}{"\n"}{.metadata.creationTimestamp}{"\n"}'
```

### ⚙️ DaemonSet (Node Plugin)
```bash
kubectl get daemonset ebs-csi-node -n kube-system   -o jsonpath='{.metadata.labels}{"\n"}{.metadata.annotations}{"\n"}{.metadata.creationTimestamp}{"\n"}'
```

### 🧠 What to Look For:
- **Label:** `eks.amazonaws.com/component: aws-ebs-csi-driver` → managed by AWS Add-on.
- **Annotation:** `kubectl.kubernetes.io/last-applied-configuration` → applied manually.
- **Annotation/Label from eksctl** (like `eks.amazonaws.com/cluster`) → may indicate eksctl-managed.

---

### ⚡ Example Quick Checks

#### ✅ Check for AWS Ownership Label
```bash
kubectl get deployment ebs-csi-controller -n kube-system   -o jsonpath='{.metadata.labels.eks\.amazonaws\.com/component}{"\n"}'
```

#### ⚙️ Check if Applied Manually
```bash
kubectl get deployment ebs-csi-controller -n kube-system   -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}{"\n"}'
```

👉 If the first command prints `aws-ebs-csi-driver`, the **add-on** likely owns it.  
👉 If the second prints something non-empty, it was **applied manually**.

---

## ⏰ 3️⃣ Compare Creation Timestamps

Add-on-created objects usually appear right after the add-on itself.

### 🕒 Get Add-on Creation Time
```bash
aws eks describe-addon   --cluster-name nakodtech-cluster   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.createdAt"   --output text
```

### 🕓 Get K8s Object Creation Time
```bash
kubectl get deployment ebs-csi-controller -n kube-system   -o jsonpath='{.metadata.creationTimestamp}{"\n"}'
```

✅ If times match → AWS Add-on likely created it.  
❌ If later (after manual apply) → likely created manually.

---

## 📜 4️⃣ Check Events & Activity (Who Changed It Last?)

```bash
kubectl get events -n kube-system   --field-selector involvedObject.name=ebs-csi-controller   --sort-by='.lastTimestamp' | tail -n 20

kubectl describe deployment ebs-csi-controller -n kube-system
```

🕵️ Look for:
- `Created by addon ...`
- `Configured by EKS addon`
- or manual activity: `kubectl apply` / `kubectl patch`.

---

## 🔐 5️⃣ Check ServiceAccount IRSA Wiring

### AWS Add-on Side
```bash
aws eks describe-addon   --cluster-name nakodtech-cluster   --addon-name aws-ebs-csi-driver   --region us-east-1   --query "addon.serviceAccountRoleArn"   --output text
```

### Kubernetes Side
```bash
kubectl get sa ebs-csi-controller-sa -n kube-system   -o jsonpath='{.metadata.annotations.eks\.amazonaws\.com/role-arn}{"\n"}'
```

✅ If the add-on has a `serviceAccountRoleArn` and the SA annotation matches → AWS Add-on manages the IRSA.  
❌ If not annotated or different → manually deployed.

---

## 🧾 Summary

| Check | Command | What It Tells You |
|--------|----------|------------------|
| Add-on status | `aws eks describe-addon` | Whether AWS manages it |
| Ownership labels | `kubectl get deployment ... -o jsonpath` | AWS or manual |
| Creation timestamps | Compare `createdAt` | Who created it |
| Events | `kubectl get events` | Who modified it |
| IRSA role | Compare `RoleArn` | Add-on-managed or manual |

---

🧠 **Tip:**  
If you confirm AWS manages it, you should *not* reapply manifests manually — let AWS handle the lifecycle to avoid “resource already exists” conflicts.

🚀 **If it’s manual**, consider removing and reinstalling via:
```bash
aws eks create-addon --cluster-name <cluster> --addon-name aws-ebs-csi-driver
```
to move to a fully-managed setup.

---
