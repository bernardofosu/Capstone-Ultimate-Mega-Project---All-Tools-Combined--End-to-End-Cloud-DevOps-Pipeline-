# 🌍 Terraform Plan & Apply — Comprehensive Notes with CI/CD Best Practices

## 🧠 What Terraform Does

Terraform is an **Infrastructure as Code (IaC)** tool that:

- 📜 Defines infrastructure using `.tf` files (declarative syntax)
- 🔍 Compares desired state vs actual state in the cloud
- 🤩 Generates a plan of what to change
- ⚙️ Applies those changes to reach the desired state

---

## ⚙️ Main Commands Overview

| 🗞️ Command          | 🎯 Purpose                                                    |
| ------------------- | ------------------------------------------------------------- |
| `terraform plan`    | Generates an execution plan — shows what changes will be made |
| `terraform apply`   | Executes those changes to create/update/destroy resources     |
| `terraform destroy` | Deletes all resources managed by Terraform                    |

---

## 🧩 `terraform plan -out=tfplan`

### 🔹 Command

```bash
terraform plan -out=tfplan
```

### 🔹 What It Does

- 🧠 Creates a **binary plan file** (`tfplan`) containing all resource actions.
- 💾 Saves the _exact_ set of changes Terraform will apply.
- 🔒 Guarantees **reproducibility** — what you plan is exactly what you’ll apply.

### 🔹 Why It’s Useful

✅ You can review or share the plan before applying.
✅ The plan can be reviewed, approved, or applied later.
✅ Prevents last-minute drift between `plan` and `apply`.

---

## 🚀 `terraform apply "tfplan"`

### 🔹 Command

```bash
terraform apply "tfplan"
```

### 🔹 What It Does

- 🧱 Applies the **pre-saved plan file** from the previous step.
- 🚫 Does **not** re-run the planning step.
- ❌ Skips the “yes/no” confirmation prompt because the plan is already reviewed.

### 🔹 Why No Prompt?

Terraform assumes:

> “You already reviewed and approved this plan during the plan phase.”

---

## ⚙️ `terraform apply --auto-approve`

### 🔹 Command

```bash
terraform apply --auto-approve
```

### 🔹 What It Does

- 🏃 Runs both plan and apply in one step.
- 🤖 Automatically approves all changes (no manual confirmation).
- ⚡ Ideal for **non-production automation** (CI/CD dev runs).

---

## 🧠 Comparison Table

| Feature                     | `terraform apply` | `terraform apply --auto-approve` | `terraform plan -out=tfplan` + `terraform apply "tfplan"` |
| --------------------------- | ----------------- | -------------------------------- | --------------------------------------------------------- |
| 🧍 Prompts for “yes”?       | ✅ Yes            | ❌ No                            | ❌ No                                                     |
| 🔁 Re-runs plan each time?  | ✅ Yes            | ✅ Yes                           | ❌ No                                                     |
| 🧮 CI/CD Friendly?          | ⚠️ Not ideal      | ✅ Simple use                    | ✅✅ Best Practice                                        |
| 🔒 Guaranteed same actions? | ❌ No             | ❌ No                            | ✅ Yes                                                    |
| 👀 Reviewable before apply? | ✅ Yes            | ❌ No                            | ✅ Yes                                                    |
| 🏠 Use Case                 | Manual testing    | Auto deployment                  | Controlled CI/CD deployments                              |

---

## 🛠️ Typical CI/CD Workflow

### 🧩 Step 1 – Initialization

```bash
terraform init
terraform validate
```

### 🧩 Step 2 – Create and Save Plan

```bash
terraform plan -out=tfplan
```

📦 Saves all planned actions to a file.
👀 Review with:

```bash
terraform show tfplan
```

### 🧩 Step 3 – Approval (Optional)

👨‍💼 Human or automated approval process reviews the plan before applying.

### 🧩 Step 4 – Apply the Plan

```bash
terraform apply "tfplan"
```

✅ Applies **exactly** what was planned — safe for production pipelines.

---

## 🧰 Jenkins Pipeline Example

```groovy
pipeline {
  agent any

  stages {
    stage('Init') {
      steps {
        sh 'terraform init'
        sh 'terraform validate'
      }
    }

    stage('Plan') {
      steps {
        sh 'terraform plan -out=tfplan'
      }
    }

    stage('Approval') {
      steps {
        input message: 'Approve Terraform changes?', ok: 'Apply'
      }
    }

    stage('Apply') {
      steps {
        sh 'terraform apply "tfplan"'
      }
    }
  }
}
```

✅ Safe for CI/CD
✅ Reviewable plan
✅ No manual typing of “yes”

---

## 🔒 Benefits of the Plan + Apply Pattern

| 🧩 Benefit                  | 💬 Description                                      |
| --------------------------- | --------------------------------------------------- |
| ✅ **Consistency**          | Ensures exactly the same plan is applied            |
| 🔒 **Safety**               | Prevents configuration drift between plan and apply |
| 🗞️ **Auditability**         | Store plan files for compliance and documentation   |
| 👥 **Separation of Duties** | One person can plan, another can apply              |
| 🤖 **Automation Friendly**  | Works seamlessly in CI/CD without prompts           |

---

## 💣 Why NOT to use just `terraform apply` in CI/CD

- 🚨 It re-runs the plan → potential drift if files change.
- 🧍 Requires a manual “yes” → breaks automation.
- ❌ Could apply unintended changes if configuration updates occur between runs.

---

## 💡 Recommended Usage

| 🌐 Environment     | ✅ Recommended Approach                                            |
| ------------------ | ------------------------------------------------------------------ |
| 🤪 **Development** | `terraform apply --auto-approve`                                   |
| 🤡 **Staging**     | `terraform plan -out=tfplan` → review → `terraform apply "tfplan"` |
| 🏢 **Production**  | Always use reviewed plans (`plan -out` + `apply "tfplan"`)         |

---

## 🗾 Quick Command Reference

```bash
# 🧠 Generate and save plan
terraform plan -out=tfplan

# 👀 Show readable plan
terraform show tfplan

# ⚙️ Apply the exact saved plan
terraform apply "tfplan"

# 🚀 Apply directly (asks for confirmation)
terraform apply

# 🤖 Apply without confirmation (non-interactive)
terraform apply --auto-approve
```

---

## 🏁 Summary

✅ **Best Practice (CI/CD & Production)**
Use:

```bash
terraform plan -out=tfplan
terraform apply "tfplan"
```

⚙️ **For Quick Testing / Dev Environments**
Use:

```bash
terraform apply --auto-approve
```

💡 This ensures:

- Predictable deployments
- Safer automation
- Auditable infrastructure
- Zero surprises in production 🚀
