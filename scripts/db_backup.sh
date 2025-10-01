#!/usr/bin/env bash
set -euo pipefail

DB="/opt/swarmnexus/data/swarm.db"
DEST="/opt/swarmnexus/backups"
RETENTION_DAYS="${RETENTION_DAYS:-14}"

mkdir -p "$DEST"
STAMP="$(date +%F-%H%M)"
TMP="$DEST/swarm-${STAMP}.db"
OUT="$DEST/swarm-${STAMP}.db.gz"

if [ ! -f "$DB" ]; then
  echo "ERROR: DB not found at $DB" >&2
  exit 1
fi

# Online, consistent backup (WAL-safe) to a temporary .db
sqlite3 "$DB" ".backup '$TMP'"

# Compress and remove the temp .db (avoid mv-to-self)
gzip -c -9 "$TMP" > "$OUT"
rm -f "$TMP"

# Lock down perms a bit (optional)
chown root:swarm "$OUT" 2>/dev/null || true
chmod 0640 "$OUT" 2>/dev/null || true

# Retain for N days (compressed files)
find "$DEST" -type f -name 'swarm-*.db.gz' -mtime +"$RETENTION_DAYS" -delete

echo "Backup complete: $OUT"
