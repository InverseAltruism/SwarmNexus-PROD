<p align="center">
  <img src="https://raw.githubusercontent.com/InverseAltruism/SwarmNexus-Dashboard/e381a51e384d753c1ce16c7ee0998f8b73ba7183/static/SwarmNexusTransparent.png" alt="Swarm Nexus" width="360" />
</p>

# Swarm Nexus
where the swarm converges, patterns emerge. From secrets to prophecy.

Swarm Nexus is a small, resilient stack that:
- Collects X/Twitter mentions and thread context for a configured handle
- Extracts tickers and “call” metadata into a shared SQLite database (WAL)
- Serves a Dashboard (UI + JSON APIs) and a read-only Memory Agent (REST + Torus Agent)

This repo (SwarmNexus-PROD) is the operational home: architecture, systemd units, Nginx, and environment.

---

## Live domain

- https://swarm-nexus.xyz

Nginx reverse-proxies:
- / → Dashboard on 127.0.0.1:3010
- /agent/ → Agent REST on 127.0.0.1:3011
- TLS via Let’s Encrypt (see ops/nginx/swarm-nexus.conf)
- certbot.timer is enabled on the host

---

## Architecture

- Shared SQLite (WAL): /opt/swarmnexus/data/swarm.db
- Collector (Node.js + Puppeteer)
  - Scrapes mentions/replies of @SwarmNexus (configurable)
  - Hydrates threads, extracts $TICKERs, saves to predictions and tickers
  - Emits heartbeat JSON at /opt/swarmnexus/data/collector_heartbeat.json
- Dashboard (Flask/Gunicorn)
  - Read-only DB access; UI + JSON APIs (leaderboards, evals, NLP, social)
- Memory Agent (Node.js)
  - Read-only DB; REST endpoints + Torus Agent methods

Ports (local)
- Dashboard (Gunicorn): 3010 (proxied by Nginx)
- Agent REST: 3011 (proxied under /agent/)
- Torus Agent: 3012 (optional)

```mermaid
flowchart LR
  subgraph Host (Ubuntu 23.04)
    Nginx <--> D[Dashboard: 3010]
    Nginx <-- /agent/ --> A[Agent REST: 3011]
    A & D -. read-only .-> DB[(SQLite WAL)]
    C[Collector] -. write -> DB
    C -.-> HB[(collector_heartbeat.json)]
  end
  Internet --> Nginx
```

---

## Repositories

- Collector: [SwarmNexus-Collector](https://github.com/InverseAltruism/SwarmNexus-Collector)
- Dashboard: [SwarmNexus-Dashboard](https://github.com/InverseAltruism/SwarmNexus-Dashboard)
- Agent: [SwarmNexus-Agent](https://github.com/InverseAltruism/SwarmNexus-Agent)

---

## Data Model (core tables)

- predictions
  - tweet_id (unique), author_handle, text, asset, target_date, status, created_at
  - parent_tweet_id, parent_author_handle, parent_text
  - tweet_created_at, parent_created_at, tweet_url, parent_tweet_url
- tickers
  - ticker, tweet_id, mention_author_handle, parent_author_handle
  - tweet_created_at, parent_created_at, tweet_url, parent_tweet_url

Dashboard may create: prediction_nlp_labels, nlp_models, evaluations, caches, helper views.

---

## Requirements (current prod)

- Ubuntu 23.04
- Node.js v22.x (www-data has v22.18.0)
- Python 3.11.4 (Dashboard venv)
- SQLite 3
- Chromium + headless libs (Puppeteer)
- Nginx + certbot (TLS; certbot.timer enabled)

---

## Environment variables

Collector (Node; .env at /opt/swarmnexus/collector/.env)
- TW_COOKIES_PATH=twitter-cookies.json  # symlink to /opt/swarmnexus/data/twitter-cookies.json
- MENTION_HANDLE=SwarmNexus
- SOURCE=notifications   # current prod
- POLL_SECONDS=60        # current
- MAX_MENTIONS_PER_CYCLE=80  # current
- NAV_TIMEOUT_MS=45000
- POLL_JITTER=true|false
- DEBUG_DETAIL=true|false
- PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium (often overridden by systemd drop-in)
- CHROME_USER_DATA_DIR=/var/www/.cache/chrome-profile
- CHROME_DISK_CACHE_DIR=/var/www/.cache/chrome-cache
- BACKOFF_BASE_MS=120000
- BACKOFF_MAX_MS=600000
- STRICT_ACCOUNT_CHECK=true

Dashboard (Python)
- SWARM_DB_PATH=/opt/swarmnexus/data/swarm.db
- PORT=3010
- HOST=0.0.0.0
- STANCE_MODEL_PATH=/opt/swarmnexus/data/stance_model.pkl (optional)
- GCAL_ICS_URL, SOCIAL_TW_HANDLES, MEDIUM_RSS, SOCIAL_EDITOR_ALLOWLIST (optional)

Agent (Node)
- DB_PATH=/opt/swarmnexus/data/swarm.db   # keep as-is to avoid breaking
- PORT=3011
- AGENT_KEY=... (for Torus Agent on 3012)

Note: We keep SWARM_DB_PATH (Dashboard) and DB_PATH (Agent) for compatibility.

---

## Quickstart (local)

```bash
# In SwarmNexus-PROD
make setup
# -> init submodules, pnpm workspace deps, pip install dashboard reqs, init DB

# Run services in split terminals (dev)
make dashboard
make collector
make agent
```

---

## Systemd (prod)

Unit files (examples in this repo; live units installed under /etc/systemd/system/):

- Collector: systemd/swarm-collector.service (+ override in /etc/systemd/system/swarm-collector.service.d/override.conf)
- Dashboard: systemd/swarm-dashboard.service and services/swarm-dashboard.service
  - Current deployment uses 127.0.0.1:3010 via Gunicorn (matches Nginx).
- Agent: ops/systemd/swarm-agent.service

Status and logs:
```bash
systemctl status swarm-collector swarm-dashboard swarm-agent
journalctl -u swarm-collector -f
journalctl -u swarm-dashboard -f
journalctl -u swarm-agent -f
```

Env locations:
- Collector: /opt/swarmnexus/collector/.env (TW_COOKIES_PATH can be a symlink)
- Agent: /opt/swarmnexus/agent/.env
- Dashboard: optional drop-in at ops/systemd/swarm-dashboard.service.d/env.conf

---

## Nginx

File: ops/nginx/swarm-nexus.conf
- HTTP→HTTPS redirect
- TLS via Let’s Encrypt
- Proxy / → 127.0.0.1:3010 (Dashboard)
- Proxy /agent/ → 127.0.0.1:3011 (Agent REST)

Apply:
```bash
sudo cp ops/nginx/swarm-nexus.conf /etc/nginx/sites-available/swarm-nexus.conf
sudo ln -sf /etc/nginx/sites-available/swarm-nexus.conf /etc/nginx/sites-enabled/swarm-nexus.conf
sudo nginx -t && sudo systemctl reload nginx
```

---

## Database: backups and maintenance

Online backups (WAL-safe) are handled by systemd. Backups are compressed to save space.

Manual run:
```bash
sudo /opt/swarmnexus/scripts/db_backup.sh
```

Schedule:
- Every ~2 days (timer uses OnUnitActiveSec=2d with randomized delay)
- Retention: 14 days by default (customize via RETENTION_DAYS)

Files:
- scripts/db_backup.sh (compressed output)
- systemd/swarm-db-backup.service
- systemd/swarm-db-backup.timer

Compression:
- Backups are written as /opt/swarmnexus/backups/swarm-YYYY-MM-DD-HHMM.db.gz

VACUUM/ANALYZE (low activity window recommended):
```bash
sudo systemctl stop swarm-collector
sqlite3 /opt/swarmnexus/data/swarm.db "PRAGMA journal_mode=WAL; VACUUM; ANALYZE;"
sudo systemctl start swarm-collector
```

---

## Health monitoring

Collector heartbeat (written each cycle by the Collector):
- Path: /opt/swarmnexus/data/collector_heartbeat.json
- Fields: ts (epoch seconds), lastSource, handle

Heartbeat watcher (systemd)
- Checks heartbeat age, logs a warning if older than a threshold (default 10 minutes).
- Optional: auto-restart collector if stale.

Files:
- scripts/heartbeat_watch.sh
- systemd/swarm-heartbeat-watch.service
- systemd/swarm-heartbeat-watch.timer

Install:
```bash
sudo systemctl enable --now swarm-heartbeat-watch.timer
sudo systemctl start swarm-heartbeat-watch.service
journalctl -u swarm-heartbeat-watch.service -n 50 --no-pager
```

Configure:
- Drop-in example (auto-restart and 15-min threshold):
```bash
sudo mkdir -p /etc/systemd/system/swarm-heartbeat-watch.service.d
sudo tee /etc/systemd/system/swarm-heartbeat-watch.service.d/env.conf >/dev/null <<'EOF'
[Service]
Environment=RESTART_IF_STALE=1
Environment=STALE_SECONDS=900
Environment=HEARTBEAT_PATH=/opt/swarmnexus/data/collector_heartbeat.json
EOF
sudo systemctl daemon-reload
sudo systemctl restart swarm-heartbeat-watch.service
```

---

## Security and compliance

- Keep .env and cookies.json out of Git; store at:
  - /opt/swarmnexus/collector/twitter-cookies.json (symlink to /opt/swarmnexus/data/twitter-cookies.json)
  - /opt/swarmnexus/{collector,agent}/.env
- Tighten cookie file perms (example):
```bash
sudo chown www-data:swarm /opt/swarmnexus/data/twitter-cookies.json
sudo chmod 0640 /opt/swarmnexus/data/twitter-cookies.json
```
- Use a sacrificial X account for scraping; X is aggressive against scraping.
- STRICT_ACCOUNT_CHECK=true prevents running with mismatched cookies/handle.
- Social editor endpoints: currently allowlist-only (no extra auth).

---

## Development

- Readers (Dashboard/Agent) should use read-only SQLite where possible; WAL allows concurrent writer (Collector).
- NLP training helpers exist in Dashboard (optional in production).

---

## Branding and screenshots

- Logo included above; keep dashboard/site palette.
- Screenshots: TODO (placeholder)

---

## Housekeeping (safe cleanups)

Legacy/backup files detected (optionally move to docs/legacy; no functional impact):
- dashboard: db_migrate_eval_excess.py_old, app.py.bak, static/performance_v2.html.bak, static/performance_v2.html_old, app.py_working, nlp_extract.py_working, prices_ingest_coingecko.py_working, prices_seed_from_predictions.py_working
- collector: src/parse.js_old
- agent: openapi.yaml.bak

---

## Useful verification commands

- Which account/source:
```bash
cat /opt/swarmnexus/data/collector_heartbeat.json | jq
journalctl -u swarm-collector -n 200 --no-pager | grep -i "Logged in as"
```
- Current throttles:
```bash
sudo grep -E '^(SOURCE|POLL_SECONDS|MAX_MENTIONS_PER_CYCLE|POLL_JITTER|BACKOFF_BASE_MS|BACKOFF_MAX_MS)=' /opt/swarmnexus/collector/.env
```
- Services listening:
```bash
ss -ltnp | egrep ':3010|:3011|:3012'
```
- TLS renew timer:
```bash
systemctl status certbot.timer
```
- Public health:
```bash
curl -I https://swarm-nexus.xyz/agent/healthz
```

---

## License

MIT (see LICENSE file).
