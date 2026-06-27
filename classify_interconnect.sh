#!/usr/bin/env bash
# classify_interconnect.sh
# Detects your Mac's CPU and prints an interconnect guess: Ring / Mesh / NoC
# Works on Intel & Apple Silicon Macs.

set -e

# Helper: safe sysctl getter
get_sysctl() {
  local key="$1"
  if sysctl "$key" >/dev/null 2>&1; then
    sysctl -n "$key"
  else
    echo "unknown"
  fi
}

brand="$(get_sysctl machdep.cpu.brand_string)"
phys="$(get_sysctl hw.physicalcpu)"
logic="$(get_sysctl hw.logicalcpu)"

# Fallbacks from system_profiler if needed
if [[ "$brand" == "unknown" || -z "$brand" ]]; then
  brand="$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Chip|Processor Name|Processor/ {print $2; exit}')"
fi
if [[ -z "$phys" || "$phys" == "unknown" ]]; then
  phys="$(system_profiler SPHardwareDataType 2>/dev/null | awk -F': ' '/Total Number of Cores/ {print $2; exit}')"
fi
if [[ -z "$logic" || "$logic" == "unknown" ]]; then
  logic="$(get_sysctl hw.ncpu)"
fi

# Trim spaces
brand="${brand#"${brand%%[![:space:]]*}"}"
brand="${brand%"${brand##*[![:space:]]}"}"

interconnect="Unknown"

# Classification rules (based on typical vendor architectures)
# - Apple M-series: NoC (Network-on-Chip, Unified Memory)
# - Intel Xeon >=10 cores: Mesh
# - Intel Core i5/i7/i9 <=8 cores: Ring
# Notes: This is a heuristic for educational purposes and may not cover every SKU.
shopt -s nocasematch
if [[ "$brand" == *"Apple"* ]]; then
  interconnect="NoC (Network-on-Chip, Unified Memory)"
elif [[ "$brand" == *"Xeon"* ]]; then
  # treat >=10 physical cores as mesh
  if [[ "$phys" =~ ^[0-9]+$ && "$phys" -ge 10 ]]; then
    interconnect="Mesh (Intel Xeon, >=10 cores)"
  else
    interconnect="Likely Ring (low-core Xeon)"
  fi
elif [[ "$brand" == *"Core"* || "$brand" == *"Intel"* ]]; then
  if [[ "$phys" =~ ^[0-9]+$ && "$phys" -le 8 ]]; then
    interconnect="Ring (Intel Core, <=8 cores)"
  else
    interconnect="Mesh or Hybrid (high-core Intel)"
  fi
fi
shopt -u nocasematch

echo "================ Interconnect Classification ================"
echo "CPU Brand     : $brand"
echo "Physical Cores: ${phys:-unknown}"
echo "Logical CPUs  : ${logic:-unknown}"
echo "Result        : $interconnect"
echo "-------------------------------------------------------------"
echo "Notes:"
echo "- Apple M-series use on-chip fabric/NoC with Unified Memory."
echo "- Typical Intel Core (<=8 cores) uses a Ring bus."
echo "- Typical Intel Xeon (>=10 cores) uses a Mesh interconnect."
echo "This is a heuristic; consult vendor docs for definitive details."

# cd ~/   # or the folder you saved it to
# chmod +x classify_interconnect.sh
# ./classify_interconnect.sh
