# ⚠️ Argo CD Cleanup — Inspect & Delete (Safe Checklist)

> **Warning:** These commands will delete Argo CD cluster resources (ClusterRoles, ClusterRoleBindings, CRDs). They **do not** delete PVCs in other namespaces unless you explicitly run commands to remove them. If you have important data you want to keep (e.g., database PVCs), back them up first.

---

## 🔍 1) Inspect cluster-scoped Argo CD resources (what exists now)

Run these commands to list potential conflicts. Do _not_ delete yet — just inspect the output first.

```bash
# List ClusterRoles related to Argo CD
kubectl get clusterrole | grep argocd || true

# List ClusterRoleBindings related to Argo CD
kubectl get clusterrolebinding | grep argocd || true

# List Argo CRDs
kubectl get crd | grep argoproj.io || true

# Show full YAML of common ClusterRoles so you can inspect labels/annotations
kubectl get clusterrole argocd-application-controller -o yaml || true
kubectl get clusterrole argocd-server -o yaml || true

# Show any Argo-related ClusterRoleBindings YAML for inspection
kubectl get clusterrolebinding argocd-application-controller -o yaml || true
kubectl get clusterrolebinding argocd-server -o yaml || true
```

> ✅ **Goal of this step:** See which cluster-scoped resources are present and whether Helm will conflict when creating them. Helm requires ownership annotations on resources it manages; if resources exist without those annotations, Helm will refuse to install.

---

## 💾 2) Backup (save YAML) — do this before deleting anything important

Run these to save current ClusterRoles/Bindings/CRDs to `~/argocd-backup/`.

```bash
mkdir -p ~/argocd-backup

# Backup clusterroles and clusterrolebindings
kubectl get clusterrole,clusterrolebinding -o yaml > ~/argocd-backup/argocd-clusterroles-bindings.yaml || true

# Backup any argoproj CRDs (if present)
kubectl get crd | awk '/argoproj.io/{print $1}' | xargs -r kubectl get crd -o yaml > ~/argocd-backup/argocd-crds.yaml || true

# Backup the argocd namespace (metadata)
kubectl get namespace argocd -o yaml > ~/argocd-backup/argocd-namespace.yaml || true

echo "Backups written to ~/argocd-backup/"
```

> 💡 Tip: For safety, also snapshot underlying PVs in your cloud provider (AWS EBS snapshots) if you have important PVCs in other namespaces.

---

## 🧹 3) Delete cluster-scoped Argo CD remnants

This removes ClusterRoles/ClusterRoleBindings and Argo CD CRDs so Helm can create them cleanly.

```bash
# Delete ClusterRoleBindings and ClusterRoles that Helm complains about
kubectl delete clusterrolebinding argocd-application-controller argocd-server argocd-repo-server argocd-application-controller argocd-manager --ignore-not-found
kubectl delete clusterrole argocd-application-controller argocd-server argocd-repo-server argocd-application-controller argocd-manager --ignore-not-found

# Delete all argoproj CRDs (if present)
CRDS=$(kubectl get crd | awk '/argoproj.io/{print $1}' || true);
if [ -n "$CRDS" ]; then kubectl delete crd $CRDS; fi
```

---

## 🧱 4) Delete the `argocd` namespace (if present) so Helm starts fresh

```bash
kubectl delete namespace argocd --ignore-not-found --wait=true

# Wait (optional) until gone:
kubectl wait --for=delete namespace/argocd --timeout=120s || true
```

---

## ▶️ Next steps (after cleanup)

Once cleanup completes successfully:

- Recreate namespace → `kubectl create namespace argocd`
- Reinstall using Helm → `helm install argocd argo/argo-cd -n argocd -f argocd-values.yaml`

✅ This ensures a fresh installation with clean ownership metadata so Helm manages all resources properly.
