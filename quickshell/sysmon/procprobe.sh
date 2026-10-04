#!/bin/bash
# Process probe for the sysmon panel (runs only while it is open).
# Lists the user's own processes grouped by executable, so a multi-process app
# (browser, Electron) is one row that can be killed as a whole. Prints one JSON
# line with the top groups by CPU and by memory, each with its processes —
#   {"cpu":[[name,pcpu,rss_kb,[[pid,comm,pcpu,rss_kb],...]],...],"mem":[...]}
# Started from procprobe.sh in gdeyoung/omarchy-sysmon (MIT).
set -u
ps -u "$USER" -o pid=,pcpu=,rss=,exe= | awk '
  {
    pid = $1; name = $4
    for (i = 5; i <= NF; i++) name = name " " $i
    comm = ""
    getline comm < ("/proc/" pid "/comm")
    close("/proc/" pid "/comm")
    if (comm == "") next                     # already gone
    sub(/ \(deleted\)$/, "", name)
    sub(/.*\//, "", name)
    # No usable exe name (unreadable, or a bare version number like
    # versions/2.1.288 for claude): group by comm instead.
    if (name == "-" || name ~ /^[0-9]/) name = comm
    gsub(/[\\"]/, "", name)
    gsub(/[\\"]/, "", comm)
    cpu[name] += $2; rss[name] += $3
    procs[name] = procs[name] sprintf("%s[%d,\"%s\",%.1f,%d]", (name in n ? "," : ""), pid, comm, $2, $3)
    n[name]++
  }
  function top(by,    out, k, best, i, seen) {
    out = ""
    for (i = 0; i < 10; i++) {
      best = ""
      for (k in n)
        if (!(k in seen) && (best == "" || by[k] > by[best])) best = k
      if (best == "") break
      seen[best] = 1
      out = out sprintf("%s[\"%s\",%.1f,%d,[%s]]", (i ? "," : ""), best, cpu[best], rss[best], procs[best])
    }
    return out
  }
  END { printf "{\"cpu\":[%s],\"mem\":[%s]}\n", top(cpu), top(rss) }
'
