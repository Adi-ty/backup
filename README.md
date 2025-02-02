# Automated Backup Script

A bash script that automatically backs up specified directories to a remote server using rsync and provides email notifications about the backup status.

## Prerequisites

- SSH access to remote server
- rsync installed on both local and remote machines
- mail command configured on local machine
- SSH key-based authentication (recommended)

## Installation

1. Clone or download the script:

```bash
git clone <repository-url>
cd <repository-directory>
```

2. Make the script executable:

```bash
chmod +x backup.sh
```

3. Copy the example environment file and configure it:

```bash
cp .env.example .env
```

4. Edit the .env file with your settings:

```bash
vim .env
```

Configuration
Edit the `.env` file with your specific settings:

- LOCAL_USER: Your local username
- REMOTE_USER: Username on the remote server
- REMOTE_HOST: IP address or hostname of remote server
- SOURCE_DIRS: Space-separated list of directories to backup
- EMAIL: Email address for notifications

## Setting up Automated Backups

To schedule automated backups using crontab:

1. Open crontab editor:

```bash
crontab -e
```

2. Add a cron job. Examples:

```bash
# Run daily at 2 AM
0 2 * * * /path/to/backup.sh

# Run weekly on Sunday at 3 AM
0 3 * * 0 /path/to/backup.sh

# Run monthly on the 1st at 4 AM
0 4 1 * * /path/to/backup.sh
```

## Backup Structure

Backups are stored on the remote server in the following structure:

```bash
/backups/
└── backup_YYYY-MM-DD_HH-MM-SS/
    ├── documents/
    ├── photos/
    └── projects/
```
