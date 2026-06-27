#!/bin/bash
# update.sh — Update system and packages

echo "🔄 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "🔄 Updating Python packages..."
pip list --outdated --format=freeze | cut -d = -f 1 | xargs -n1 pip install -U

echo "✅ All updates done!"
