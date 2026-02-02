Grafana One-Click Disaster Recovery
License Platform Docker

Automated backup and restore solution for Grafana dashboards using Docker volumes and AWS S3.

🎯 Overview
Production-ready disaster recovery for self-hosted Grafana. Ensures dashboards and configuration can be recovered from container crashes, data loss, or service failures.

Key Features: - ✅ Automated backup to AWS S3 - ✅ One-click restore functionality - ✅ IAM role authentication (no hardcoded credentials) - ✅ Docker volume management - ✅ Production-ready error handling

🛠️ Technology Stack
Component	Technology
OS	Ubuntu 22.04/24.04
Cloud	AWS (EC2, S3, IAM)
Containers	Docker, Docker Compose
Monitoring	Grafana, Prometheus, Node Exporter
Automation	Bash
📦 Prerequisites
AWS account with S3 bucket
EC2 instance with IAM role (S3 permissions)
Docker & Docker Compose installed
Security group: ports 3000 (Grafana), 9090 (Prometheus)
🚀 Quick Start
1. Clone Repository
git clone https://github.com/yashvi-itara/Grafana-one-click-disaster-recovery-yashvi-prem.git
cd Grafana-one-click-disaster-recovery-yashvi-prem
2. Configure Environment
cp .env.template .env
nano .env  # Set S3_BUCKET_NAME and AWS_REGION
3. Fix Prometheus Permissions (Critical)
sudo mkdir -p prometheus-data
sudo chown -R 65534:65534 prometheus-data
4. Start Services
docker-compose up -d
5. Access Grafana
URL: http://<EC2-IP>:3000
Login: admin / admin
📖 Usage
Create Backup
./backup.sh
Exports all dashboards and datasources to S3 with timestamp.

Restore from Backup
./restore.sh                    # Latest backup
./restore.sh backup-YYYY-MM-DD  # Specific backup
Downloads from S3 and restores Grafana to previous state.

⚙️ Configuration
Environment Variables (.env):

S3_BUCKET_NAME=your-bucket-name
AWS_REGION=us-east-1
GRAFANA_URL=http://localhost:3000
GRAFANA_USER=admin
GRAFANA_PASSWORD=admin
IAM Policy (S3 Access):

{
  "Effect": "Allow",
  "Action": ["s3:ListBucket", "s3:GetObject", "s3:PutObject"],
  "Resource": ["arn:aws:s3:::your-bucket-name/*"]
}
🔧 Troubleshooting
Issue	Solution
Prometheus won't start	sudo chown -R 65534:65534 prometheus-data
Empty backup	Add dashboards in Grafana UI first
S3 upload fails	Check IAM role: aws sts get-caller-identity
Restore fails	Ensure volume names match in docker-compose.yml
⚠️ Critical Notes
Prometheus Permissions: Runs as UID 65534 - set ownership before starting
Restore Order: Must restore BEFORE starting Grafana container
Volume Names: Must match exactly between backup/restore scripts
No Credentials: Uses IAM roles exclusively - no AWS keys in code
📚 Key Learnings
Docker volumes persist independently of containers
Prometheus requires UID 65534 ownership on data directory
Restore must happen before Grafana initialization
UI visibility ≠ data persistence (verify at database level)
Volume naming must be explicit to avoid mismatches
📂 Repository Structure
.
├── docker-compose.yml    # Container orchestration
├── prometheus.yml        # Prometheus config
├── backup.sh            # Backup automation
├── restore.sh           # Restore automation
├── .env.template        # Environment template
└── README.md            # This file
👥 Contributors
Premkumar K Patel
Yashvi D Patel
📄 License
MIT License - See LICENSE for details.

🔗 Resources
Grafana Docs
Docker Docs
AWS S3 Docs
