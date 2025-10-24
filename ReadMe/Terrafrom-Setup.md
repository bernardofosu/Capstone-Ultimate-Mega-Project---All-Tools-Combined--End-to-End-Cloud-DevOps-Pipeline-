# Terraform — AWS credentials: notes & fixes

> Starting point (command output from your terminal):

```text
ubuntu@ip-172-31-30-52:~/Capstone-.../Mega-Project-Terraform-mine$ terraform plan

Planning failed. Terraform encountered an error while generating this plan.

╷
│ Error: No valid credential sources found
│
│ with provider["registry.terraform.io/hashicorp/aws"],
│ on main.tf line 1, in provider "aws":
│ 1: provider "aws" {
│
│ Please see https://registry.terraform.io/providers/hashicorp/aws
│ for more information about providing credentials.
│
│ Error: failed to refresh cached credentials, no EC2 IMDS role found, operation error ec2imds: GetMetadata, http response error StatusCode: 404, request to
│ EC2 IMDS failed
│
╵
```

---

## Notes (start from)

> Terraform uses AWS access keys (Access Key ID and Secret Access Key) to authenticate and communicate with AWS APIs.

Terraform's AWS provider needs valid AWS credentials from one of several sources. When it can't find any, you'll get the `No valid credential sources found` error (or IMDS errors if it's trying to query EC2 metadata and none exists).

### Credential sources (priority order commonly used)

1. **Environment variables** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, optional `AWS_SESSION_TOKEN`, and `AWS_REGION`).
2. **Shared credentials file** (`~/.aws/credentials`) and profile configured by `aws configure`.
3. **AWS CLI cached or assumed-role credentials** (when using `aws sso` or `aws-vault`).
4. **EC2/ECS/EKS instance role (IMDS)** — credentials provided via the instance metadata service.
5. **Explicit provider configuration** in Terraform (less recommended for secrets).

---

## Quick fixes & commands (code snippets)

### 1) Use environment variables (local/dev)

```bash
export AWS_ACCESS_KEY_ID="AKIAxxxxxxxxxxxx"
export AWS_SECRET_ACCESS_KEY="xxxxxxxxxxxxxxxxxxxx"
export AWS_DEFAULT_REGION="us-east-1"
# if using temporary creds (STS)
export AWS_SESSION_TOKEN="IQoJb3..."
```

Then re-run:

```bash
terraform init
terraform plan
```

---

### 2) Use AWS CLI profile (recommended for local)

Install AWS CLI v2 (if not installed):

```bash
sudo apt update -y
sudo apt install unzip curl -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

Configure a profile:

```bash
aws configure --profile myprofile
# follow prompts for access key, secret, region
```

Tell Terraform to use that profile (in `provider` or env var):

```hcl
provider "aws" {
  profile = "myprofile"
  region  = "us-east-1"
}
```

or set env var:

```bash
export AWS_PROFILE=myprofile
terraform plan
```

---

### 3) Use assume role (cross-account) in Terraform

```hcl
provider "aws" {
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/TerraformDeployerRole"
  }
}
```

You still need base credentials that can assume the role (either env vars or profile).

---

### 4) Running Terraform on an EC2 instance: IMDS errors

If Terraform is running on a non-AWS host (like your laptop or a non-EC2 VM), it will fail when trying to reach EC2 Instance Metadata Service (IMDS). The error you saw (`StatusCode: 404`) indicates no IMDS endpoint — normal if not on EC2.

**If you are on EC2 and see IMDS errors:** verify instance has an IAM role attached and that IMDS is enabled. For IMDS v2, metadata token calls are required; the AWS SDK handles this automatically.

**If you are NOT on EC2 but Terraform is still trying IMDS** — that means no other credential source was found. Provide env vars, a profile, or set `AWS_EC2_METADATA_DISABLED=true` to prevent SDK from calling IMDS:

```bash
export AWS_EC2_METADATA_DISABLED=true
# then run terraform plan
```

---

### 5) Avoid hardcoding credentials in `.tf` files

Bad (do not commit):

```hcl
provider "aws" {
  access_key = "AKIA..."
  secret_key = "..."
  region     = "us-east-1"
}
```

Better: use profiles, env vars, or CI secrets.

---

## Troubleshooting checklist

- Run `aws --version` to confirm AWS CLI v2 is installed.
- Run `aws sts get-caller-identity` to confirm credentials work and to see which identity Terraform would use.
- If using profiles, ensure `~/.aws/credentials` and `~/.aws/config` have correct entries.
- If using EC2 roles: verify the instance has an IAM role and `aws sts get-caller-identity` from the instance shows the role.
- To see Terraform provider debug logs:

```bash
TF_LOG=DEBUG terraform plan 2>&1 | tee tf-debug.log
```

---

## Quick example: minimal secure workflow locally

1. Install AWS CLI v2.
2. `aws configure --profile me` and enter credentials.
3. `export AWS_PROFILE=me`
4. In Terraform `provider "aws" { region = "us-east-1" }`
5. `terraform init && terraform plan`

---

If you want, I can also:

- add this document to a printable PDF layout, or
- create a one-page cheat-sheet for your repo `README.md`.
