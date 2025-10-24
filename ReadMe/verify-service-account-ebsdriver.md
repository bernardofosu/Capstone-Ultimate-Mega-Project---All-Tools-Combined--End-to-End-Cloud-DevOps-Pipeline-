# ✅ Verify IRSA for EBS CSI Driver (Service Account + IAM Role)

Let's verify the EBS CSI Driver's IAM Service Account and associated IAM role using IRSA. There are two parts to check:
1️⃣ the **Kubernetes ServiceAccount** inside the cluster  
2️⃣ the **IAM role** attached to it (via IRSA)

---

## 🧩 1️⃣ Check the Kubernetes Service Account

Run:

```bash
kubectl get serviceaccount ebs-csi-controller-sa -n kube-system -o yaml
```

✅ You should see output like this:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ebs-csi-controller-sa
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<your-account-id>:role/eksctl-nakodtech-cluster-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa-Role1-XXXXX
secrets:
  - name: ebs-csi-controller-sa-token-xxxxx
```

💡 **Key things to look for:**

- `metadata.name` = `ebs-csi-controller-sa`
- `metadata.annotations.eks.amazonaws.com/role-arn` — confirms **IRSA** (IAM Role for Service Account)

---

## 🧠 2️⃣ Check via eksctl

`eksctl` can list all IAM service accounts:

```bash
eksctl get iamserviceaccount --cluster nakodtech-cluster --region us-east-2
```

✅ You should see something like:

```
NAMESPACE     NAME                     ROLE ARN
kube-system   ebs-csi-controller-sa    arn:aws:iam::<your-account-id>:role/eksctl-nakodtech-cluster-addon-iamserviceaccount-kube-system-ebs-csi-controller-sa-Role1-XXXXX
```

---

## 🔐 3️⃣ Check the IAM Role in AWS Console or CLI

To find the role name quickly via CLI:

```bash
aws iam list-roles --query "Roles[?contains(RoleName, 'ebs-csi')].RoleName" --region us-east-2
```

Then describe that role:

```bash
aws iam get-role --role-name <role-name>
```

✅ In the role's **trust policy** you should see the OIDC provider in the Principal, for example:

```json
"Principal": {
  "Federated": "arn:aws:iam::<account-id>:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/<eks-oidc-id>"
}
```

This confirms the role can be assumed by the service account through the cluster's OIDC provider.

---

## 🧾 4️⃣ Optional — Check Which Pods Use It

Once the EBS CSI Driver is deployed, list the driver pods:

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
```

Then inspect one of the controller pods:

```bash
kubectl describe pod <ebs-csi-controller-pod> -n kube-system | grep -i serviceaccount
```

✅ Expected output:

```
Service Account:  ebs-csi-controller-sa
```

This confirms the driver pods are using that IRSA-linked service account.

---

## ✅ Summary (Quick checks)

| Check                 | Command                                                       | Expected                                       |
| --------------------- | ------------------------------------------------------------- | ---------------------------------------------- |
| ServiceAccount in K8s | `kubectl get sa ebs-csi-controller-sa -n kube-system -o yaml` | Has `eks.amazonaws.com/role-arn` annotation    |
| eksctl view           | `eksctl get iamserviceaccount --cluster nakodtech-cluster`    | Lists your service account + role              |
| IAM Role trust        | `aws iam get-role`                                            | Has OIDC provider in trust policy              |
| Pod usage             | `kubectl describe pod ...`                                    | Shows ServiceAccount = `ebs-csi-controller-sa` |

---

📘 **Notes:**

- Replace `us-east-2` and `nakodtech-cluster` with your region/cluster name if different.
- Replace `<your-account-id>` and `<eks-oidc-id>` with the actual values from your environment.

---

**Author:** NakodTech
**Updated:** October 2025
