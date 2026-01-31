# 🛡️ Grafana One-Click Disaster Recovery System

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Docker](https://img.shields.io/badge/docker-compose-2496ED.svg) ![AWS](https://img.shields.io/badge/AWS-S3-orange.svg)

> **A resilient monitoring stack that decouples visualization from storage, capable of surviving total container loss and recovering in seconds.**

## 📖 Project Overview
This project demonstrates a robust **Infrastructure-as-Code (IaC)** approach to monitoring. It separates the "Visualization Layer" (Grafana) from the "Storage Layer" (Prometheus) and uses a custom **Disaster Recovery (DR) Engine** to automate backup and restoration.

**Key Features:**
* **Automated Backup:** Exports Dashboards and Datasource configurations to an AWS S3 Vault via API.
* **Resilience:** Survives catastrophic failure (e.g., accidental container or volume deletion).
* **One-Click Restore:** Rebuilds the entire environment on a fresh instance automatically.

---

## 🏗️ Architecture

The system is deployed on **AWS EC2** using Docker containers, with **AWS S3** serving as the off-site backup vault.

| Component | Role | Description |
| :--- | :--- | :--- |
| **Grafana** | The "Brain" | Visualization dashboard (Port 3000). Stateless in this design; config is injected during restore. |
| **Prometheus** | The "Memory" | Time-series database (Port 9090). Scrapes and stores metrics locally. |
| **Node Exporter** | The "Sensors" | Collects hardware metrics (CPU, RAM, Disk) from the host machine. |
| **S3 Vault** | The "Safety Net" | AWS S3 Bucket used to store JSON configuration snapshots. |
| **DR Engine** | The "Logic" | Bash scripts (`backup.sh` / `restore.sh`) utilizing `awscli` and `jq` for API interaction. |

---

## ⚙️ Prerequisites

To run this project, ensure the following are installed and configured:

* **Docker & Docker Compose**
* **AWS CLI** (Configured with `aws configure` and S3 write access)
* **jq** (JSON Processor: `sudo apt install jq`)
* **Git**

---

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone [https://github.com/yashvi-itara/Grafana-one-click-disaster-recovery-yashvi-prem.git](https://github.com/yashvi-itara/Grafana-one-click-disaster-recovery-yashvi-prem.git)
cd Grafana-one-click-disaster-recovery-yashvi-prem
