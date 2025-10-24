# 🧩 EKS Add-on Quick Checks

## 🧩 1️⃣ Check with AWS CLI (the official source)

Run:

```bash
aws eks describe-addon \
  --cluster-name nakodtech-cluster \
  --addon-name aws-ebs-csi-driver \
  --region us-east-1 \
  --query "addon.status" \
  --output text
```

If you see:

```
ACTIVE
```

✅ — means AWS is actively managing this driver as an EKS Addon (Terraform created it).

If the add-on didn’t exist or was deleted, you’d get:

```
An error occurred (ResourceNotFoundException) when calling the DescribeAddon operation: Addon not found.
```

👉 Since your Terraform output showed aws_eks_addon.ebs_csi_driver created successfully, it should show as ACTIVE.

## 🧩 2️⃣ Check Kubernetes object labels (to confirm ownership)

Run this:

```bash
kubectl get deployment ebs-csi-controller -n kube-system -o jsonpath='{.metadata.labels}{"\n"}'
kubectl get daemonset ebs-csi-node -n kube-system -o jsonpath='{.metadata.labels}{"\n"}'
```

Look for this label:

```
"app.kubernetes.io/managed-by": "EKS"
```

| Label Found                                         | Meaning                  |
| --------------------------------------------------- | ------------------------ |
| `"app.kubernetes.io/managed-by": "EKS"`             | ✅ Add-on managed by AWS |
| `"app.kubernetes.io/managed-by": "kubectl"` or none | ⚠️ Deployed manually     |

✅ In your earlier logs, you had:

```
"app.kubernetes.io/managed-by": "EKS"
```

That means AWS Addon created it — not a manual apply.

## 🧩 3️⃣ Double-check for manual overlay leftovers

Run this:

```bash
kubectl get all -n kube-system | grep ebs
```

If you see only one set of controllers (like 2 ebs-csi-controller pods and 3 ebs-csi-node pods),
and they carry labels like `app.kubernetes.io/managed-by=EKS`,
then the manual Kustomize deploy (kubectl apply -k ...) was either deleted or overwritten.

If you see duplicates (e.g. two controllers with different names, or versions mismatching), that means both versions (manual + addon) exist — which causes conflicts.

## 🧠 Bonus: the sure-fire add-on registry check

This one is definitive — shows all AWS-managed add-ons:

```bash
aws eks list-addons --cluster-name nakodtech-cluster --region us-east-1
```

Example output:

```json
{
  "addons": ["aws-ebs-csi-driver", "vpc-cni", "coredns", "kube-proxy"]
}
```

If you see `"aws-ebs-csi-driver"` listed there → ✅ it’s AWS-managed.

## 🧩 TL;DR Summary

| Check                    | Command                                      | Expected Result                   |
| ------------------------ | -------------------------------------------- | --------------------------------- |
| AWS Addon Active         | `aws eks describe-addon`                     | status = ACTIVE ✅                |
| K8s Labels               | `kubectl get deployment ... -o jsonpath`     | `"managed-by": "EKS"` ✅          |
| Addon Registry           | `aws eks list-addons`                        | `"aws-ebs-csi-driver"` present ✅ |
| Manual overlay leftovers | `kubectl get all -n kube-system \| grep ebs` | Inspect for duplicates            |

If you paste your output from:

```bash
aws eks describe-addon --cluster-name nakodtech-cluster --addon-name aws-ebs-csi-driver --region us-east-1
```

and

```bash
kubectl get deployment ebs-csi-controller -n kube-system -o jsonpath='{.metadata.labels}{"\n"}'
```

## Check The Cluster

```sh
kubectl config current-context
kubectl cluster-info
kubectl get csidrivers
```
