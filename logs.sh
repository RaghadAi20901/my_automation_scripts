#!/bin/bash
# followlogs.sh — Tail multiple logs
LOG_DIR=/var/log
tail -f "$LOG_DIR"/*.log
# chmod +x logs.sh
# ./logs.sh