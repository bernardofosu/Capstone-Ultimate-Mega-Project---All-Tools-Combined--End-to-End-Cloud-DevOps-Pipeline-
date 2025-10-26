# 📊 **Prometheus & Grafana Monitoring Setup via Helm**

Easily deploy **Prometheus**, **Grafana**, and **Node Exporter** using **Helm** 🧠 — all in one clean monitoring stack! 💡

---

## 🧩 **Step 1: Add Prometheus Helm Repository**

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

✅ This adds the official Prometheus community charts.

---

## ⚙️ **Step 2: Create `values.yaml` Configuration**

📄 Example configuration file (customize if needed):

```yaml
alertmanager:
  enabled: false

prometheus:
  prometheusSpec:
    service:
      type: LoadBalancer
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: ebs-sc
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 5Gi

grafana:
  enabled: true
  service:
    type: LoadBalancer
  adminUser: admin
  adminPassword: admin123

nodeExporter:
  service:
    type: LoadBalancer

kubeStateMetrics:
  enabled: true
  service:
    type: LoadBalancer

additionalScrapeConfigs:
  - job_name: node-exporter
    static_configs:
      - targets:
          - node-exporter:9100
  - job_name: kube-state-metrics
    static_configs:
      - targets:
          - kube-state-metrics:8080
```

💾 Save this file as **`values.yaml`**

---

## 🚀 **Step 3: Install Prometheus Stack with Helm**

Run this command to install everything in the `monitoring` namespace:

```bash
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -f values.yaml -n monitoring --create-namespace
```

This installs:

- 🧠 **Prometheus** (metrics collection)
- 📊 **Grafana** (visualization)
- ⚙️ **Node Exporter** (node metrics)
- 📦 **Kube State Metrics** (K8s object metrics)

---

## 🌐 **Step 4: Expose Services via LoadBalancer**

Make sure all components are accessible externally 👇

```bash
kubectl patch svc monitoring-kube-prometheus-prometheus -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'
kubectl patch svc monitoring-kube-state-metrics -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'
kubectl patch svc monitoring-prometheus-node-exporter -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'
kubectl patch svc monitoring-grafana -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'
```

---

## 🔐 **Step 5: Get Grafana Login Credentials**

Retrieve your Grafana admin username and password:

```bash
kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-user}" | base64 --decode; echo
kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode; echo
```

🌐 **Access URL:**

```
http://<EXTERNAL-IP>:80
```

🧑‍💻 Login → **admin** / _(decoded password)_

---

## ✅ **Step 6: Verify Everything**

Check pod and service status:

```bash
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

Expected output:

- ✅ Prometheus pods running
- ✅ Grafana service exposed
- ✅ Node Exporter collecting metrics
- ✅ Kube State Metrics active

---

## 🧠 **Quick Summary**

| Component             | Function                    | Access Type  |
| --------------------- | --------------------------- | ------------ |
| 🧠 Prometheus         | Collects cluster metrics    | LoadBalancer |
| 📊 Grafana            | Visualizes metrics          | LoadBalancer |
| ⚙️ Node Exporter      | Exposes node-level metrics  | LoadBalancer |
| 📦 Kube State Metrics | Tracks K8s resource metrics | LoadBalancer |

---

🎯 **Result:** You now have a fully functional **Kubernetes Monitoring Stack** deployed via Helm — ready to integrate with your dashboards, alerts, and DevOps workflows 🚀
