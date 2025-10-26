# ✅ Argo CD — MySQL / BankApp troubleshooting & fix notes

**Saved:** steps and commands used to diagnose and fix the `bankapp` / `mysql` sync & CrashLoop issues. Use this as a checklist or paste into your repo/docs.

---

## Summary (one-liner)

We had MySQL pods CrashLooping because of a bad CLI arg + leftover PVs in `Released` state; Argo CD reported the app `OutOfSync` because the `mysql-pvc` was missing. Fix: remove bad `args`, remove leftover PVs (or rebind if preserving data), recreate PVC, let Argo CD sync, verify pods healthy. 🎉

---

## Timeline & key events 🕒

- Argo CD reported `OutOfSync` and `Degraded` for `bankapp` app; mysql pod was `CrashLoopBackOff` then showed `unknown variable 'default-authentication-plugin'` in logs.
- PVC for MySQL had been deleted and the underlying PVs were `Released` with `ReclaimPolicy: Retain` (blocked reprovisioning).
- Steps performed: patched deployment to remove `args`, deleted leftover PVs, re-created PVC, forced Argo CD sync; app synced and pods came up.

---

## Root causes 🔎

1. **Invalid MySQL startup arg** passed via `args: ["--default-authentication-plugin=..."]` that the image rejected → `unknown variable` → MySQL aborted and tables weren't initialized.
2. **PersistentVolume(s) left in `Released` state** with `ReclaimPolicy: Retain` after PVC deletion. These leftover PV objects prevented dynamic provisioning of a new EBS volume.
3. `bankapp` depended on MySQL, so it went `CrashLoopBackOff` while DB was unavailable.

---

## Exact commands we ran (copy/paste) 🧰

> NOTE: run these from the machine with `kubectl`/`argocd` access to the cluster.

### Inspecting state

```bash
argocd app get bankapp
kubectl -n webapps get pods
kubectl -n webapps describe pod <mysql-pod-name>
kubectl get pv
kubectl -n webapps get pvc
kubectl get sc
```

### Remove offending `args` from the running Deployment (temporary — commit to Git later)

```bash
kubectl -n webapps patch deployment mysql --type='merge' -p '{"spec":{"template":{"spec":{"containers":[{"name":"mysql","args":null}]}}}}'
kubectl -n webapps rollout restart deployment/mysql
```

### Delete leftover Released PVs (start fresh) ⚠️

```bash
kubectl delete pv pvc-091a9e55-ea98-4ba9-816b-0936aa30b407 pvc-5727f05e-46e5-484e-8bf7-a9fc1cbe6ecd
```

(If you need to preserve data, use the `volumeName:` bind method instead — see notes below.)

### Recreate PVC (let Argo CD reconcile or create manually)

```bash
cat <<'EOF' | kubectl -n webapps apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
  namespace: webapps
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ebs-sc
  resources:
    requests:
      storage: 5Gi
EOF
```

### Force Argo CD to sync the app (admin or authorized user)

```bash
argocd app sync bankapp --prune --force
```

### Watch pods & logs

```bash
kubectl -n webapps get pods -w
kubectl -n webapps logs -l app=mysql -c mysql --tail=200 -f
kubectl -n webapps logs -l app=bankapp --tail=200 -f
```

---

## Why these steps work 🧩

- Removing the invalid `args` lets the MySQL image start with its defaults so it can initialize system tables in an **empty** data dir.
- Deleting `Released` PV objects frees the way for dynamic provisioning: when a new PVC is created with `storageClassName: ebs-sc`, the EBS CSI driver will provision a fresh EBS volume and bind it.
- Recreating the PVC enables the MySQL pod to mount storage and reach `Running` state; then bankapp can connect and becomes healthy.

---

## Preserve-old-data option (if you needed it) 🗄️

If you wanted to keep the old EBS volume:

1. Inspect the PV YAML to find the underlying EBS volume ID.
2. Remove `spec.claimRef` from the PV (careful) or create a PVC that sets `volumeName: <pv-name>` so it binds to that PV.
3. Ensure cluster/CSI driver state is OK and re-create mysql pod.

Example to bind existing PV:

```bash
kubectl patch pv <pv-name> --type=json -p='[{"op":"remove","path":"/spec/claimRef"}]'
# then create PVC with volumeName: <pv-name>
```

---

## Finalize: commit fix to Git (prevent Argo CD reversion) 💾

1. Edit your Git manifest (remove `args:` from mysql Deployment or change to safe config).
2. Commit & push:

```bash
git add Manifest/path/to/mysql-deployment.yaml
git commit -m "remove mysql args; fix startup & storage reprovisioning"
git push
```

Argo CD will auto-reconcile the committed change.

---

## Verification checklist ✅

- [ ] `argocd app get bankapp` shows **Synced** and **Healthy**
- [ ] `kubectl -n webapps get pods` shows `mysql` and `bankapp` pods with `1/1 Running`
- [ ] `kubectl -n webapps get pvc` shows `mysql-pvc Bound`
- [ ] `kubectl get pv` shows newly provisioned PV (if starting fresh)

---

## Next steps / hardening 💡

- Add an init container or startup probe to bankapp to wait for DB readiness (`wait-for-it` or similar).
- Use `Readiness` probe on MySQL that matches the container's behavior.
- Consider setting `reclaimPolicy: Delete` for testing clusters to avoid orphaned EBS volumes.
- If using Argo CD users (devops), keep RBAC minimal and ensure `accounts.devops` mapping includes `g, devops, role:devops` and appropriate `policy.csv` entries.

---

If you want, I can also:

- ✍️ generate the exact Git-friendly YAML patch (remove `args`) and a PR message, or
- 🗂 create a one-page printable `argocd-mysql-fix.md` cheat-sheet that you can download.
