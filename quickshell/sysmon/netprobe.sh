#!/bin/bash
# Network probe for the sysmon panel (runs only while it is open). No root
# needed, so it only sees what `ss` shows an ordinary user. Prints one JSON line:
#   {"net":[[name,rx_bytes,tx_bytes,[pid,...]],...]  cumulative TCP bytes of the
#                                                  open non-loopback sockets,
#                                                  grouped by executable
#    "ports":[[pid,name,[port,...],exposed,dir],...]}  listening TCP sockets;
#                                                  pid 0 = not ours to see
set -u

net=$( { ps -u "$USER" -o pid=,exe=; echo ---; ss -tinpH 2>/dev/null; } | awk '
  !sockets && $0 == "---" { sockets = 1; next }
  !sockets {
    name = $2; for (i = 3; i <= NF; i++) name = name " " $i
    sub(/ \(deleted\)$/, "", name); sub(/.*\//, "", name)
    if (name != "-" && name !~ /^[0-9]/) exe[$1] = name
    next
  }
  /^[^ \t]/ {
    name = ""
    if ($5 ~ /^(127\.|\[::1\]|\[::ffff:127\.)/) next
    if (match($0, /users:\(\("[^"]*",pid=[0-9]+/)) {
      s = substr($0, RSTART + 9, RLENGTH - 9)
      pid = s; sub(/.*pid=/, "", pid)
      name = s; sub(/",pid=.*/, "", name)
      if (pid in exe) name = exe[pid]
      if (!((name, pid) in owns)) { owns[name, pid] = 1; pids[name] = pids[name] (pids[name] == "" ? "" : ",") pid }
    }
    next
  }
  name != "" {
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^bytes_received:/) rx[name] += substr($i, 16)
      else if ($i ~ /^bytes_acked:/) tx[name] += substr($i, 13)
    }
    seen[name] = 1; name = ""
  }
  END {
    for (k in seen) {
      label = k; gsub(/[\\"]/, "", label)
      printf "%s[\"%s\",%d,%d,[%s]]", (n++ ? "," : ""), label, rx[k], tx[k], pids[k]
    }
  }')

ports=""
while IFS=$'\t' read -r pid name exposed list; do
  dir=""
  if [ "$pid" -gt 0 ] && cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null) && [ "$cwd" != "/" ] && [ "$cwd" != "$HOME" ]; then
    dir=${cwd##*/}
    dir=${dir//[\\\"]/}
  fi
  ports="${ports}${ports:+,}[${pid},\"${name}\",[${list}],${exposed},\"${dir}\"]"
done < <(ss -Htlnp 2>/dev/null | awk '
  {
    addr = $4; port = addr; sub(/.*:/, "", port); sub(/:[^:]*$/, "", addr)
    pid = 0; name = ""
    if (match($0, /users:\(\("[^"]*",pid=[0-9]+/)) {
      s = substr($0, RSTART + 9, RLENGTH - 9)
      pid = s; sub(/.*pid=/, "", pid)
      name = s; sub(/",pid=.*/, "", name); gsub(/[\\"]/, "", name)
    }
    key = pid ? pid : "0:" port
    if (!(key in pids)) { order[++n] = key; pids[key] = pid; names[key] = name; first[key] = port }
    if (addr !~ /^(127\.|\[::1\]$)/) exposed[key] = 1
    if (!((key, port) in have)) { have[key, port] = 1; list[key] = list[key] (list[key] == "" ? "" : ",") port }
  }
  END {
    for (i = 1; i <= n; i++) {
      k = order[i]
      printf "%d\t%s\t%d\t%s\t%s\n", first[k], pids[k], (k in exposed), names[k], list[k]
    }
  }' | sort -n | cut -f2- | awk -F'\t' '{ printf "%s\t%s\t%s\t%s\n", $1, ($3 == "" ? "?" : $3), ($2 ? "true" : "false"), $4 }')

printf '{"net":[%s],"ports":[%s]}\n' "$net" "$ports"
