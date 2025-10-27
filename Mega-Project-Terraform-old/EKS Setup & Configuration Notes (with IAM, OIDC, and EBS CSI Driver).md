## ☸️ **EKS Setup & Configuration Notes (with IAM, OIDC, and EBS CSI Driver)**

---

### 🔐 **Associate IAM OIDC Provider**

Associate an IAM **OpenID Connect (OIDC)** provider with your EKS cluster.
This allows Kubernetes service accounts to assume AWS IAM roles securely.

```bash
eksctl utils associate-iam-oidc-provider \
  --region us-east-1 \
  --cluster nakodtech-cluster \
  --approve
```

✅ **Explanation:**

- `--region us-east-1` → Your AWS region
- `--cluster nakodtech-cluster` → Your EKS cluster name
- `--approve` → Automatically confirms the OIDC association

This command enables IAM roles for Kubernetes service accounts within your cluster.

---

### 🪪 **Create an IAM Service Account**

Create a Kubernetes service account that has IAM permissions for the **AWS EBS CSI Driver**.

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

✅ **Explanation:**

- `--name ebs-csi-controller-sa` → Service account name
- `--namespace kube-system` → Namespace where it’s created
- `--attach-policy-arn` → Attaches AWS-managed IAM policy for EBS CSI driver
- `--approve` → Automatically approves creation
- `--override-existing-serviceaccounts` → Replaces existing service account if present

This links your Kubernetes service account with the IAM role and permissions required for managing EBS volumes.

---

### 📦 **Deploy the AWS EBS CSI Driver**

Deploy the official AWS EBS CSI driver into your EKS cluster.

```bash
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/ecr/?ref=release-1.11"
```

✅ **Explanation:**

- Uses **Kustomize (-k)** to apply manifests directly from GitHub
- Deploys the **stable EBS CSI driver version 1.11**
- Installs all necessary controller and node components in the `kube-system` namespace

---

### ☸️ **Create EKS Kubeconfig**

Connect your local `kubectl` to your EKS cluster:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name nakodtech-cluster
```

🧠 **Explanation**

| Flag                      | Description                                               |
| ------------------------- | --------------------------------------------------------- |
| `--region`                | AWS region where your EKS cluster is running              |
| `--name`                  | The name of your EKS cluster                              |
| `--role-arn` _(optional)_ | If you want to use a specific IAM role for authentication |
| `--profile` _(optional)_  | Use a specific AWS CLI profile instead of the default one |

---

### 🧾 **Verification Commands**

After configuring kubeconfig:

```bash
kubectl get nodes
```

If you see your worker nodes ✅ — connection successful.

Check contexts:

```bash
kubectl config get-contexts
```

Switch context:

```bash
kubectl config use-context <context-name>
```

---

### 🌈 **Summary**

✅ `aws eks update-kubeconfig` → Connects your local machine to EKS
✅ `eksctl utils associate-iam-oidc-provider` → Enables IAM OIDC for EKS
✅ `eksctl create iamserviceaccount` → Creates IAM-linked service account for EBS
✅ `kubectl apply -k` → Deploys AWS EBS CSI driver
