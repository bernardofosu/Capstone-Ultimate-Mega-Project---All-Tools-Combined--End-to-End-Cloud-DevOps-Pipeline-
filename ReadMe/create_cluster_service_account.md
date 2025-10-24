## 🔗 **Associate IAM OIDC Provider**

```bash
eksctl utils associate-iam-oidc-provider \
  --region us-east-1 \
  --cluster nakodtech-cluster \
  --approve
```

Verify:

```bash
aws eks describe-cluster --name nakodtech-cluster --region us-east-1 --query "cluster.identity.oidc.issuer" --output text
```

---

## 🔐 **Create IAM Service Account for EBS CSI Driver**

```bash
eksctl create iamserviceaccount \
  --region us-east-1 \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster nakodtech-cluster \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --override-existing-serviceaccounts
```

🧾 Verify:

```bash
kubectl get serviceaccount ebs-csi-controller-sa -n kube-system -o yaml
```

---

## 📦 **Install the EBS CSI Driver**

```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.11"
```

delete

```sh
kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.11"
```

---
