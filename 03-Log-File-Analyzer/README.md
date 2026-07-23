# 🔍 Log File Analyzer

**A Bash-powered log analysis engine for DevOps engineers — parse, detect, and report on system, application, and access logs in seconds.**

<p align="left">
  <img src="https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white" />
  <img src="https://img.shields.io/badge/OS-Linux%20%7C%20Ubuntu-E95420?logo=ubuntu&logoColor=white" />
  <img src="https://img.shields.io/badge/Category-DevOps%20Automation-1f6feb" />
  <img src="https://img.shields.io/badge/Status-Active-success" />
  <img src="https://img.shields.io/badge/License-MIT-blue" />
</p>

> Part of the [`shell-scripting-projects`](https://github.com/gunasekharvadla/shell-scripting-projects) series — hands-on Bash automation for real DevOps workflows.

---

## 📖 Table of Contents

- [Why This Exists](#-why-this-exists)
- [Features](#-features)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Sample Output](#-sample-output)
- [Configuration](#-configuration)
- [Skills Demonstrated](#-skills-demonstrated)
- [Roadmap](#-roadmap)
- [Author](#-author)

---

## 💡 Why This Exists

Every DevOps engineer eventually gets paged for "something's wrong in prod" — and the first move is almost always: **check the logs.**

This script automates that first pass: scanning application, system, and access logs to surface errors, failed logins, suspicious traffic, and status-code anomalies — turning a manual grep-hunt into a single command.

---

## ✨ Features

| # | Feature | What It Does |
|---|---------|---------------|
| 1 | **Log Summary** | Counts total entries across all monitored logs |
| 2 | **Log Level Breakdown** | Tallies `ERROR`, `WARNING`, `INFO` events |
| 3 | **HTTP Status Analysis** | Buckets responses — `2xx`, `4xx`, `5xx` |
| 4 | **Top IP Detection** | Ranks the most active client IPs |
| 5 | **URL Traffic Analysis** | Surfaces the most-hit endpoints |
| 6 | **Failed Login Detection** | Flags brute-force / auth failure patterns |
| 7 | **Auto-Generated Reports** | Writes timestamped reports to `reports/` |

---

## 📂 Project Structure

```
03-Log-File-Analyzer/
├── analyze-logs.sh
├── README.md
├── config/
│   └── config.conf
├── logs/
│   ├── access.log
│   ├── application.log
│   └── system.log
└── reports/
    ├── analysis-report.txt
    └── reports.txt
```

---

## 🚀 Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/gunasekharvadla/shell-scripting-projects.git

# 2. Move into this project
cd shell-scripting-projects/03-Log-File-Analyzer

# 3. Make the script executable
chmod +x analyze-logs.sh

# 4. Run it
./analyze-logs.sh
```

---

## 📊 Sample Output

```
====================================
        LOG ANALYSIS REPORT
====================================
Hostname : Linux Server
Date     : 2026-07-23

Total Logs : 500

ERROR Count   : 25
WARNING Count : 40
INFO Count    : 435

HTTP Status:
  200 : 450
  404 : 35
  500 : 15

Report Generated Successfully → reports/analysis-report.txt
```

---

## ⚙️ Configuration

Tune behavior via `config/config.conf` — log paths, report output location, and thresholds for what counts as "suspicious" activity, without touching the script itself.

---

## 🛠️ Skills Demonstrated

`Linux Administration` · `Bash Scripting` · `grep / awk / sed` · `Log Monitoring` · `Troubleshooting` · `Automation` · `Git Workflow`

---

## 🔮 Roadmap

- [ ] Interactive CLI menu
- [ ] Colorized terminal output
- [ ] Command-line argument support (`--errors-only`, `--since`, etc.)
- [ ] Log rotation support
- [ ] Email / Slack alerting on threshold breach
- [ ] Prometheus + Grafana metrics export

---

## 👨‍💻 Author

**Gunasekhar Vadla**
DevOps Engineer in progress | Linux · Shell Scripting · Cloud Automation

[![GitHub](https://img.shields.io/badge/GitHub-gunasekharvadla-181717?logo=github)](https://github.com/gunasekharvadla)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/gunasekharvadla/)

---

⭐ **If this project helped you, drop a star — it helps others find it too.**
