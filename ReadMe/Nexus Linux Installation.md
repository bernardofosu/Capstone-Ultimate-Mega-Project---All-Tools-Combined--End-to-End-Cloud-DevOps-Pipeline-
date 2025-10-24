# 📦 Nexus Repository Manager – Linux Installation Notes

## 1️⃣ Purpose

🏗️ Centralized repository manager for storing and managing artifacts (packages, containers, binaries)
🔗 Provides a central hub for teams to consistently manage and share artifacts
⚡ Supports CI/CD integration and scalable deployment

---

## 2️⃣ Create a Dedicated User

It’s recommended to run Nexus as its own user for security.

```bash
sudo useradd -r -m -d /opt/nexus -s /bin/bash nexus
```

Explanation:

- `-r` → Create a system user
- `-m` → Create home directory
- `-d /opt/nexus` → Set home directory
- `-s /bin/bash` → Set shell

Add to sudo group

```sh
usermod -aG sudo nexus
```

change or add passwd

```sh
passwd nexus # at root
```

## 3️⃣ Download & Unpack the Archive

Official Community Edition (64-bit Linux x86-64):
[https://download.sonatype.com/nexus/3/nexus-3.85.0-03-linux-x86_64.tar.gz](https://download.sonatype.com/nexus/3/nexus-3.85.0-03-linux-x86_64.tar.gz)

### Download using `wget`:

```bash
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-3.85.0-03-linux-x86_64.tar.gz
```

### Download using `curl`:

```bash
cd /opt
sudo curl -O https://download.sonatype.com/nexus/3/nexus-3.85.0-03-linux-x86_64.tar.gz
```

### Extract the Archive

```bash
sudo tar xvz --keep-directory-symlink -f ./nexus-3.85.0-03-linux-x86_64.tar.gz
sudo mv nexus-3.85.0-03 nexus   # Rename for simplicity
```

### Setup Data Directory & Permissions

```bash
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work
```

Notes:

- Do not run Nexus from a user's home directory in production.
- Recommended installation directory: `/opt/nexus`
- Extraction creates:

  - `/opt/nexus` → Application directory
  - `/opt/sonatype-work` → Default Data Directory

---

## 4️⃣ Running Nexus Repository

Navigate to the application directory:

```bash
cd /opt/nexus/bin
```

Commands:

```bash
./nexus start      # Start Nexus in background
./nexus stop       # Stop Nexus
./nexus run        # Run in foreground (CTRL+C to stop)
./nexus restart    # Restart Nexus
./nexus status     # Check status
```

Notes:

- Logs are stored in the application log file
- Use `run` for testing; `start` for production

---

## 5️⃣ Running as a Service (Production)

Configure Nexus to run as a systemd service:

Example `/etc/systemd/system/nexus.service`:

```sh
nano /etc/systemd/system/nexus.service
```

- systemd manages services centrally under /etc/systemd/system/.
- By creating a file like /etc/systemd/system/nexus.service, you’re telling systemd how to start, stop, and manage Nexus.

```ini
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus
```

- Ensures automatic restart after server reboots

---

## 6️⃣ Access the User Interface

Open a browser:

```cpp
http://<host_ip>:8081
```

Local test:

```arduino
http://localhost:8081
```

Default credentials:

- Username: `admin`
- Initial password: `/opt/sonatype-work/nexus3/admin.password`

🔑 Important: Change the admin password immediately after first login

---

## 7️⃣ Post-Installation Checklist

✅ Change admin password
✅ Configure anonymous access
✅ Update admin email
✅ Configure SMTP for email notifications
✅ Configure HTTP/HTTPS proxy (if required)
✅ Set up backup procedures (Backup and Restore)

Maintenance tasks:

- Maven: delete unused SNAPSHOTS
- Docker: delete incomplete uploads
- Admin: compact blob store

✅ Configure repository cleanup policies
✅ Set up routing rules to prevent package name hijacking
✅ Consider token-based access for repository security

---

## 8️⃣ Configure Runtime Environment

- Adjust JVM memory in `nexus.vmoptions`
- Optimize memory according to deployment size and available RAM
- Review Nexus Repository Memory Overview

---

## 9️⃣ System Requirements (Recommended)

🖥️ Linux-based system
💽 Disk: 15–20 GB
⚡ CPU: 4 vCPU
💾 Memory: ≥ 2–4 GB RAM

Artifact storage example:

- Small artifact: 100 MB
- Medium artifact: 500 MB
- 100 artifacts → 1–4 GB

---

## 🔟 Deployment Options

- Standalone (Linux application)
- Containerized (Docker, Kubernetes)
- Helm Chart for HA on AWS/Azure
- OpenShift Operator (requires external PostgreSQL, supports active/active HA)

---

✅ This version includes:

- Dedicated `nexus` user
- Proper permissions for `/opt/nexus` and `/opt/sonatype-work`
- Systemd service setup
- wget/curl commands for download
- Recommended producti
