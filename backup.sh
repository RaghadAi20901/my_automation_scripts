#!/bin/bash
# backup.sh — Backup a folder into timestamped archive

SRC=$1
DEST=$2
STAMP=$(date +%Y%m%d_%H%M%S)

if [ -z "$SRC" ] || [ -z "$DEST" ]; then
  echo "Usage: $0 <source_folder> <backup_folder>"
  exit 1
fi

mkdir -p "$DEST"
tar -czf "$DEST/backup_${STAMP}.tar.gz" "$SRC"
echo "✅ Backup created at $DEST/backup_${STAMP}.tar.gz"
# chmod +x backup.sh
# ./backup.sh /path/to/source /path/to/backup