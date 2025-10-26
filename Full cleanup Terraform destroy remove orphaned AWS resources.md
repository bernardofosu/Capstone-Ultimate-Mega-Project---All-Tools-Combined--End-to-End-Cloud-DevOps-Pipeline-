# 🧹 Full cleanup: Terraform destroy + remove orphaned AWS resources

**Purpose:** Start from `terraform destroy` and clean everything created for the project (EKS, ELBs, PVs/EBS, IAM, LoadBalancers, ArgoCD, cert-manager, namespaces, etc.). This checklist contains commands and explanations so you can run safely and return your AWS account to a clean state.

> ⚠️ **Warning**: These commands delete resources irreversibly (EBS volumes, DB data, load balancers, IAM roles). BACKUP anything important first.

---

## 0) Pre-flight checks ✅

- Confirm you are using the right AWS account and region.

  ```bash
  aws sts get-caller-identity
  aws configure get region
  ```

- Make sure you have the Terraform working directory with correct `terraform.tfstate` (local or remote backend). If you used a remote state (S3), ensure you have access and lock.

---

## 1) (Optional but recommended) Remove cluster-level apps first

If you installed ArgoCD, cert-manager, ingress controller, etc via Helm / kubectl, uninstall them first so they don’t fight terraform during destroy.

```bash
# example: remove Argo CD and cert-manager via kubectl/helm (adjust names/namespace if different)
kubectl delete -n argocd applicationset --all --ignore-not-found
kubectl delete namespace argocd --ignore-not-found
helm uninstall argocd -n argocd || true
helm uninstall cert-manager -n cert-manager || true
kubectl delete namespace cert-manager --ignore-not-found
kubectl delete namespace webapps --ignore-not-found
```

> Note: If Argo CD was managing the app resources, deleting ArgoCD first may remove apps from the desired state. This is fine because you plan to destroy infra.

---

## 2) (Optional) Clean up Kubernetes PersistentVolumeClaims and PersistentVolumes

If PVCs exist and their PVs are `Released` with `reclaimPolicy: Retain`, dynamic provisioning may not re-create. To fully clean cluster storage:

```bash
kubectl get pvc --all-namespaces
kubectl get pv
# delete PVCs in the target namespace
kubectl -n webapps delete pvc --all || true
# delete PVs that are Released and you don't need the data
kubectl get pv | awk '/Released/ {print $1}' | xargs -r kubectl delete pv
```

If you want to preserve data, identify the PV volume id and snapshot it before deletion from the AWS console.

---

## 3) Run Terraform destroy (recommended approach)

Navigate to your Terraform root (where `main.tf` or backend is). Always run a plan first to inspect.

```bash
cd /path/to/terraform/dir
# Initialize (if not already)
terraform init

# Preview destruction (recommended)
terraform plan -destroy -out=tfdestroy.plan
terraform show -json tfdestroy.plan | less

# When satisfied, destroy the infrastructure
terraform destroy -auto-approve
```

If you use a remote backend (S3), ensure `terraform init` is configured with the proper backend.

---

## 4) If Terraform fails because of orphaned resources (ENI/ELB/EBS) — cleanup steps

Sometimes terraform fails because resources (ELB, PVs, ENIs, SGs) were created outside TF or are stuck. Use these manual cleanup commands.

### 4A) ELB / ALB load balancers

List and delete orchestration-created LB resources (use `elbv2` for ALB/NLB, `elb` for classic):

```bash
# ALB/NLB
aws elbv2 describe-load-balancers --region us-east-1
# delete using ARN
aws elbv2 delete-load-balancer --load-balancer-arn <arn>

# Classic ELB (if any)
aws elb describe-load-balancers --region us-east-1
aws elb delete-load-balancer --load-balancer-name <name>
```

> If Ingress controller created LBs, ensure you remove the ingress or Service of type `LoadBalancer` first. Kubernetes will then delete the LB automatically.

### 4B) EBS volumes left as `Available` (orphaned)

List EBS volumes (filter by tag or by creation range). Delete only volumes you know are orphaned.

```bash
# list volumes by tag or name (example shows volumes that Terraform created naming pattern)
aws ec2 describe-volumes --filters "Name=tag:Name,Values=*nakodtech*" --region us-east-1

# delete by id
aws ec2 delete-volume --volume-id vol-0123456789abcdef0 --region us-east-1
```

### 4C) Security Groups / ENIs / IAM Roles

If destroy fails due to security groups or ENIs, list them, then remove attachments before deleting.

```bash
# list SGs with tag or name
aws ec2 describe-security-groups --filters Name=vpc-id,Values=<vpc-id>
# delete SG
aws ec2 delete-security-group --group-id sg-xxxx --region us-east-1

# IAM roles
aws iam list-roles | jq '.Roles[] | select(.RoleName|test("nakodtech|eks|argocd"))'
aws iam detach-role-policy --role-name <role> --policy-arn <policy-arn>
aws iam delete-role --role-name <role>
```

---

## 5) Clean up Kubernetes cluster (if EKS is destroyed outside Terraform)

If you manually remove EKS cluster or it gets destroyed, kubeconfig entries may remain; you can remove contexts:

```bash
kubectl config get-contexts
kubectl config delete-context <context-name>
kubectl config unset users.<user>
kubectl config unset clusters.<clustername>
```

---

## 6) Final verification & console cleanup

- Check AWS console for leftover resources: EC2 (instances), Load Balancers, EBS volumes, Security Groups, IAM, Route53 records (DNS), S3 buckets (terraform state). Remove as needed.
- If you used S3 for TF backend and want to delete state bucket (careful):

  ```bash
  aws s3 ls
  aws s3 rb s3://your-terraform-state-bucket --force
  ```

---

## 7) Extra: fully delete namespace & CRDs in cluster (if cluster remains)

```bash
kubectl delete namespace webapps --ignore-not-found
kubectl delete namespace argocd --ignore-not-found
kubectl get crd | grep argoproj.io | awk '{print $1}' | xargs -r kubectl delete crd
```

---

## 8) Recreate from scratch (optional)

When you want to rebuild everything:

1. `terraform apply --auto-approve`
2. `aws eks --region <region> update-kubeconfig --name <cluster>`
3. Install ingress controller, cert-manager, ArgoCD via Helm (or via manifests).

---

## Quick tidy checklist (summary) 🧾

- [ ] Backup any data you need
- [ ] `kubectl delete` cluster apps & namespaces (argocd, cert-manager, webapps)
- [ ] Delete PVCs / PVs or snapshot EBS if needed
- [ ] `terraform destroy` (plan first)
- [ ] If TF fails: delete ELBs, EBS volumes, SGs, ENIs manually
- [ ] Delete TF state bucket if desired
- [ ] Verify AWS console for orphaned resources

---

If you want, I can:

- ✍️ Create a targeted sequence for your repo (I see you have `main.tf` in the directory). Tell me the backend type (local or S3) and I’ll give exact `terraform init` & `destroy` commands for your setup.
- 📄 Save this as a downloadable `.md` file in the workspace (with emojis). (I already saved a markdown file for your earlier MySQL fix — say “save cleanup file” and I’ll save this one too.)

Would you like me to generate the exact `terraform destroy` commands for the directory you showed (and include S3 backend handling)?
