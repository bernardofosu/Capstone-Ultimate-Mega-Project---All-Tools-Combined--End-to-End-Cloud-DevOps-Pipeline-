## 📘 **Amazon EBS CSI Driver – Kubernetes Notes**

---

### 🚀 **Overview**

The **Amazon EBS CSI Driver** allows Kubernetes pods to use **EBS volumes** as persistent storage.
It has two main components:

1. 🧩 **Controller (ebs-csi-controller)**
2. 🧩 **Node (ebs-csi-node)**

---

### ⚙️ **Architecture**

#### 🏗️ **1. Controller Component**

- 🏠 Runs as a **Deployment**
- 🌍 Handles **control plane operations** like:

  - Creating new EBS volumes
  - Attaching/detaching volumes
  - Managing snapshots and resizing

- 🧠 Doesn’t need to run on every node — only a few replicas for redundancy.

💡 **Each controller pod has 6 containers:**

| 🧱 Container      | 🔍 Function               |
| ----------------- | ------------------------- |
| `csi-provisioner` | Creates new volumes       |
| `csi-attacher`    | Attaches volumes to nodes |
| `csi-snapshotter` | Handles snapshots         |
| `csi-resizer`     | Resizes volumes           |
| `liveness-probe`  | Monitors health           |
| `ebs-plugin`      | Core EBS driver logic     |

✅ **Pods Example:**
`ebs-csi-controller-7cdc6cf579-5pwh4  → 6/6 Running`
`ebs-csi-controller-6588fb74fb-4lwkn → 0/6 ContainerCreating`

---

#### 💻 **2. Node Component**

- 🖥️ Runs as a **DaemonSet**
- 📦 Ensures each node can **mount/unmount** EBS volumes
- ⚡ Handles **data plane operations**

💡 **Each node pod has 3 containers:**

| 🧱 Container                | 🔍 Function                   |
| --------------------------- | ----------------------------- |
| `csi-node-driver-registrar` | Registers driver with kubelet |
| `liveness-probe`            | Health checks                 |
| `ebs-plugin`                | Mount/unmount volumes         |

✅ **Pods Example:**
`ebs-csi-node-jqlq5  → 3/3 Running`
`ebs-csi-node-s9xgn  → 3/3 Running`

---

### 🔍 **Why “ContainerCreating”?**

Sometimes pods stay in `ContainerCreating` state due to:

- 🕒 Image pull delays
- 🔐 Missing IAM permissions
- 💾 Node resource pressure
- ⚙️ RBAC/webhook not fully initialized

🧾 **Troubleshoot Commands:**

```bash
kubectl describe pod <pod-name> -n kube-system
kubectl logs <pod-name> -n kube-system -c ebs-plugin
```

---

### 🧠 **Summary Table**

| 🧩 Component   | 🏷️ Type    | 🧮 Pods per Cluster | 📦 Containers per Pod | 🎯 Purpose                                       |
| -------------- | ---------- | ------------------- | --------------------- | ------------------------------------------------ |
| **Controller** | Deployment | ~3 replicas         | 6                     | Volume creation, attach/detach, resize, snapshot |
| **Node**       | DaemonSet  | 1 per node          | 3                     | Volume mount/unmount on nodes                    |

---

### 🌈 **Key Takeaways**

✅ Controller = Brain 🧠 (manages volumes)
✅ Node = Hands 🤲 (mounts volumes)
✅ 6 containers = Control logic
✅ 3 containers = Node logic
