#!/bin/bash
# — Check status for all repos in a directory
BASE_DIR=~/projects
for dir in "$BASE_DIR"/*; do
  if [ -d "$dir/.git" ]; then
    echo "📂 $dir"
    (cd "$dir" && git status -s -b)
    echo
  fi
done
# chmod +x .sh
# ./.sh