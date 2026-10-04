#!/bin/bash
# System probe for the sysmon service. Prints one JSON line; cpu_total/cpu_idle
# (jiffies), net_rx/net_tx and io_read/io_write (bytes) are cumulative and the
# service turns their deltas into rates, absent sensors report -1. Derived from sysmon.sh in gdeyoung/omarchy-sysmon (MIT).
set -u

read -r _ u n s i w q sq st _ < /proc/stat
read -r mem_total mem_avail < <(awk '/^MemTotal:/ { t = $2 } /^MemAvailable:/ { a = $2 } END { print t, a }' /proc/meminfo)
read -r disk_used disk_size < <(df -B1 --output=used,size / | tail -n 1)

# Physical interfaces only: bridges and veths would count the same bytes twice.
net_rx=0; net_tx=0
for dev in /sys/class/net/*/device; do
  [ -e "$dev" ] || continue
  net_rx=$((net_rx + $(cat "${dev%/device}/statistics/rx_bytes" 2>/dev/null || echo 0)))
  net_tx=$((net_tx + $(cat "${dev%/device}/statistics/tx_bytes" 2>/dev/null || echo 0)))
done

# Whole disks only (not partitions); sectors are 512 bytes.
read -r io_read io_write < <(awk '$3 ~ /^(nvme[0-9]+n[0-9]+|sd[a-z]+|vd[a-z]+)$/ { r += $6; w += $10 } END { print r * 512, w * 512 }' /proc/diskstats)

# Local filesystems, one per device: ["mount", used, size]
vols=$(df -B1 --local -x tmpfs -x devtmpfs -x efivarfs -x overlay -x squashfs --output=source,used,size,target 2>/dev/null | awk '
  NR > 1 && !seen[$1]++ {
    mnt = $4; for (i = 5; i <= NF; i++) mnt = mnt " " $i
    gsub(/[\\"]/, "", mnt)
    printf "%s[\"%s\",%s,%s]", (n++ ? "," : ""), mnt, $2, $3
  }')

cpu_temp=-1; disk_temp=-1
for d in /sys/class/hwmon/hwmon*; do
  case $(cat "$d/name" 2>/dev/null) in
    k10temp|coretemp|zenpower) [ "$cpu_temp" -lt 0 ] && cpu_temp=$(cat "$d/temp1_input" 2>/dev/null || echo -1) ;;
    nvme)                      [ "$disk_temp" -lt 0 ] && disk_temp=$(cat "$d/temp1_input" 2>/dev/null || echo -1) ;;
  esac
done

# With several cards (iGPU + discrete) report the one with the most VRAM.
gpu_busy=-1; gpu_temp=-1; vram_used=-1; vram_total=-1; gpu_dev=""; best=-1
for d in /sys/class/drm/card*/device; do
  [ -f "$d/gpu_busy_percent" ] || continue
  v=$(cat "$d/mem_info_vram_total" 2>/dev/null || echo 0)
  [[ $v =~ ^[0-9]+$ ]] || v=0
  if [ "$v" -gt "$best" ]; then best=$v; gpu_dev=$d; fi
done
if [ -n "$gpu_dev" ]; then
  gpu_busy=$(cat "$gpu_dev/gpu_busy_percent" 2>/dev/null || echo -1)
  vram_used=$(cat "$gpu_dev/mem_info_vram_used" 2>/dev/null || echo -1)
  vram_total=$(cat "$gpu_dev/mem_info_vram_total" 2>/dev/null || echo -1)
  for h in "$gpu_dev"/hwmon/hwmon*; do
    t=$(cat "$h/temp1_input" 2>/dev/null) || continue
    [[ $t =~ ^[0-9]+$ ]] && gpu_temp=$t
  done
fi

printf '{"cpu_total":%d,"cpu_idle":%d,"mem_total_kb":%d,"mem_avail_kb":%d,"disk_used_b":%d,"disk_size_b":%d,"cpu_temp_mc":%d,"gpu_temp_mc":%d,"disk_temp_mc":%d,"gpu_busy_pct":%d,"net_rx":%d,"net_tx":%d,"vram_used_b":%d,"vram_total_b":%d,"io_read":%d,"io_write":%d,"vols":[%s]}\n' \
  "$((u + n + s + i + w + q + sq + st))" "$((i + w))" \
  "$mem_total" "$mem_avail" "$disk_used" "$disk_size" "$cpu_temp" "$gpu_temp" "$disk_temp" "$gpu_busy" "$net_rx" "$net_tx" \
  "$vram_used" "$vram_total" "$io_read" "$io_write" "$vols"
