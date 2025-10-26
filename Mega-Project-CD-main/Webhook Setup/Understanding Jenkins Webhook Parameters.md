## 🧩 Understanding Jenkins Webhook Parameters — in Layman Terms

When you connect **GitHub → Jenkins** with a webhook, here’s what really happens behind the scenes 👇

### 🧠 Step 1: What Happens When You Push Code

Whenever you push code to your GitHub repository (for example, running `git push origin main`),
GitHub automatically generates a 📦 **JSON message** — basically a data package — that looks like this:

```json
{
  "ref": "refs/heads/main",
  "repository": {
    "name": "Mega-Project-CI-main",
    "owner": {
      "name": "bernardofosu"
    }
  }
}
```

This JSON tells Jenkins **what just happened** — like which branch got updated, who did it, and what repository it came from.

---

### ⚙️ Step 2: Jenkins Reads the JSON Data

Inside Jenkins, we define a **Post Content Parameter** for the webhook trigger — for example:

- **Variable name:** `ref`
- **Expression:** `$.ref`

This means Jenkins will **extract** the value of `ref` from that JSON.
In this example, the value is:

```
refs/heads/main
```

✅ So Jenkins now knows:

> “A push just happened on the `main` branch!”

---

### 🧩 Step 3: Jenkins Compares the Branch (Optional Filter)

In the **Optional Filter** section, Jenkins checks what you told it to watch for — like this:

- **Text:** `$ref`
- **Expression:** `refs/heads/main`

That means Jenkins will only trigger the job **if** `$ref` (from the webhook) equals `refs/heads/main`.

✅ If it matches → Jenkins runs the pipeline 🚀
❌ If it doesn’t → Jenkins ignores the push 👀

👉 **At the optional filter, you must add the exact branch** (like `refs/heads/main`)
that you want Jenkins to compare against to decide whether to take action.

---

### 💡 Step 4: Why We Use `$.ref`

`$.ref` is the instruction Jenkins uses to **extract** the branch value — it’s like saying:

> “Hey Jenkins, look in the JSON and pick out the branch name.”

Jenkins saves that as `$ref`, so now `$ref = refs/heads/main`.

Then Jenkins checks if `$ref` matches your filter (for example, `refs/heads/main`).

✅ If **yes** → Jenkins runs the job.
🚫 If **no** → Jenkins ignores it.

So basically —
🧠 `$.ref` helps Jenkins **know which branch was pushed**,
🛠️ and lets it **decide whether to start the pipeline** based on that branch.
