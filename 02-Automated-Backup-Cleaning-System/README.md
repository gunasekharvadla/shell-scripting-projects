# Automated Backup & Cleanup System

## Overview

A Bash-based backup automation tool designed for Linux servers.

The script creates compressed backups, validates backup success, maintains logs, removes old backups, and runs automatically using Cron.

---

## Features

- Multiple directory backup
- Timestamped backup files
- tar.gz compression
- Backup verification
- Logging system
- Automatic cleanup
- Retention policy
- Cron scheduling

---

## Project Structure

backup-automation/

├── backup.sh

├── config/

│   └── backup.conf

├── source/

├── backups/

├── logs/

└── README.md


---

## Technologies

- Bash Shell
- Linux
- Cron
- tar
- gzip
- find

---

## Usage

Run manually:

```bash
./backup.sh
