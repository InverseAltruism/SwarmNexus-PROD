#!/usr/bin/env bash
set -euo pipefail

HEARTBEAT="${HEARTBEAT_PATH:-/opt/swarmnexus/data/collector_heartbeat.json}"
STALE_SECONDS="${STALE_SECONDS:-600}"   # default 10 minutes
RESTART_IF_STALE="${RESTART_IF_STALE:-0}"

if [ ! -f "$HEARTBEAT" ]; then
  logger -t swarm-heartbeat "ERROR: heartbeat file not found: $HEARTBEAT"
  exit 0
fi

# Extract ts (epoch seconds). Fallback to 0 if parse fails.
TS="$(jq -r '.ts // 0' "$HEARTBEAT" 2>/dev/null || echo 0)"
NOW="$(date +%s)"
AGE=$(( NOW - ${TS%.*} ))

if [ "$AGE" -ge "$STALE_SECONDS" ]; then
  MSG="WARN: collector heartbeat stale (${AGE}s >= ${STALE_SECONDS}s) at $HEARTBEAT"
  logger -t swarm-heartbeat "$MSG"
  echo "$MSG"

  if [ "$RESTART_IF_STALE" = "1" ]; then
    logger -t swarm-heartbeat "Attempting restart: systemctl restart swarm-collector"
    systemctl restart swarm-collector || true
  fi
else
  echo "OK: heartbeat age ${AGE}s < ${STALE_SECONDS}s"
fi
