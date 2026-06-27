#!/bin/bash
# bigfiles.sh — Find files larger than 50MB

find . -type f -size +50M -exec ls -lh {} \; | awk '{ print $NF ": " $5 }'
# chmod +x bigfiles.sh
# ./bigfiles.sh