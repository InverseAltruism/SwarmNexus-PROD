# Swarm Nexus — PROD Environment

Production orchestration for the Swarm Nexus stack:
- Collector (Node.js + Puppeteer) scrapes X/Twitter mentions and writes to SQLite.
- Dashboard (Flask) serves a UI and JSON APIs for memory, analytics, and social content.
- Agent (Node.js) exposes memory APIs and a Torus Agent for programmatic access.

All components share a single SQLite database in WAL mode for safe concurrent reads.

---

## Architecture

- Database (SQLite): /opt/swarmnexus/data/swarm.db (WAL)
- Collector: scrapes mentions/replies of @SwarmNexus, extracts tickers and call metadata
- Dashboard: read-only access to DB; serves UI and APIs; includes NLP and evaluations tooling
- Memory Agent: read-only access; REST endpoints + Torus Agent methods for memory retrieval
- Systemd services: persistent background services with health/heartbeat

Ports
- Dashboard: 3010 (default)
- Memory Agent (REST): 3011 (default)
- Torus Agent: 3012 (default)

Logs and Health
- Collector logs: journalctl -u swarm-collector -f
- Dashboard logs: journalctl -u swarm-dashboard -f
- Agent logs: journalctl -u swarm-agent -f
- Collector heartbeat: /opt/swarmnexus/data/collector_heartbeat.json

---

## Repositories

- Collector: [SwarmNexus-Collector](https://github.com/InverseAltruism/SwarmNexus-Collector)
- Dashboard: [SwarmNexus-Dashboard](https://github.com/InverseAltruism/SwarmNexus-Dashboard)
- Agent: [SwarmNexus-Agent](https://github.com/InverseAltruism/SwarmNexus-Agent)

---

## Data Model

SQLite (WAL enabled). Core tables:
- predictions
  - tweet_id (unique), author_handle, text, asset, target_date, status, created_at
  - parent_tweet_id, parent_author_handle, parent_text
  - tweet_created_at, parent_created_at, tweet_url, parent_tweet_url
- tickers
  - ticker, tweet_id, mention_author_handle, parent_author_handle
  - tweet_created_at, parent_created_at, tweet_url, parent_tweet_url
- additional dashboard tables (created on demand):
  - prediction_nlp_labels, nlp_models, evaluations, and caches

---

## Requirements

- Node.js ≥ 18 (Collector, Agent)
- Python ≥ 3.8 (Dashboard)
- SQLite 3
- Puppeteer dependencies (headless Chrome libs)
- Flask + Flask-CORS

---

## Environment Variables

Create a .env (do not commit) and/or systemd env overrides.

Twitter + Collector
- TW_COOKIES_PATH=/opt/swarmnexus/collector/cookies.json
- MENTION_HANDLE=SwarmNexus
- POLL_SECONDS=60
- SOURCE=search or notifications
- MAX_MENTIONS_PER_CYCLE=20
- NAV_TIMEOUT_MS=45000
- POLL_JITTER=true|false
- DEBUG_DETAIL=true|false
- PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium (optional)
- CHROME_USER_DATA_DIR=/var/www/.cache/chrome-profile
- CHROME_DISK_CACHE_DIR=/var/www/.cache/chrome-cache
- BACKOFF_BASE_MS=120000
- BACKOFF_MAX_MS=600000
- STRICT_ACCOUNT_CHECK=true

Dashboard
- PORT=3010
- HOST=0.0.0.0
- SWARM_DB_PATH=/opt/swarmnexus/data/swarm.db
- STANCE_MODEL_PATH=/opt/swarmnexus/data/stance_model.pkl
- GCAL_ICS_URL=... (optional)
- SOCIAL_TW_HANDLES=comma,separated,handles (optional)
- MEDIUM_RSS=https://medium.com/feed/@user1,https://medium.com/feed/@user2 (optional)
- SOCIAL_EDITOR_ALLOWLIST=comma,separated,handles (optional)

Agent
- DB_PATH=/opt/swarmnexus/data/swarm.db
- PORT=3011
- AGENT_KEY=... (for Torus agent; torus-server.js uses PORT=3012 by default)

---

## Setup

Use the Makefile to install dependencies and initialize the database.

```bash
# In PROD repo root
make setup
# This will:
# - init submodules
# - install workspace deps (pnpm)
# - pip install dashboard requirements
# - create data/swarm.db (schema)
```

Initialize or repair the DB:
```bash
make db
```

Run components locally
```bash
# Terminal 1
make dashboard
# Terminal 2
make collector
# Terminal 3
make agent
```

---

## Systemd

Unit files are provided under systemd/ and services/ with helper scripts in ops/.

- swarm-dashboard.service
- swarm-collector.service
- swarm-agent.service

Apply/override environment (example):
```bash
sudo install -d /etc/systemd/system/swarm-dashboard.service.d
sudo install -m 0644 ops/systemd/swarm-dashboard.service.d/env.conf \
  /etc/systemd/system/swarm-dashboard.service.d/env.conf
sudo systemctl daemon-reload
sudo systemctl restart swarm-dashboard
```

Make sure the Collector service sets a WorkingDirectory that points where swarm.db lives (e.g., /opt/swarmnexus/data) so better-sqlite3 opens the shared DB.

---

## Operational Notes

- Database concurrency: WAL is enforced. Writers (Collector) and readers (Dashboard/Agent) can run concurrently.
- Dashboard and Agent must open DB in read-only mode in production to avoid corruption.
- The Collector requires a logged-in X/Twitter session via exported cookies; session handle is verified.
- Heartbeat JSON is written by Collector to /opt/swarmnexus/data/collector_heartbeat.json for ops checks.

---

## APIs and UI

Dashboard UI/Pages
- /          Home/landing
- /dashboard Full dashboard
- /leaderboard Leaderboard
- /status    Status
- /docs, /docs/api Agent docs and OpenAPI explorer
- /agent, /agent/docs, /agent/openapi.yaml quick links

Dashboard APIs (read-only)
- /api/meta, /api/me
- /api/evals/leaderboard, /api/evals/author, /api/evals/preview, /api/evals/nlp
- /api/social/... (articles, feeds, events; controlled by allowlist)

Memory Agent (REST)
- GET /healthz
- GET /capabilities
- GET /openapi.yaml
- GET /memory/mentions?limit&since&until&author&ticker&q
- GET /memory/tickers?limit&ticker&author

Torus Agent (Agent SDK)
- agent.swarmnexus.memory.mentions.get
- agent.swarmnexus.memory.tickers.get

---

## NLP and Evaluations

- stance_train.py trains a TF-IDF + LogisticRegression (optional calibrated) model, saved to STANCE_MODEL_PATH and registered in nlp_models.
- nlp_extract.py includes phrase rules and uses the trained model when present.
- Evaluations endpoints compute author hit rates and time-windowed performance metrics.

---
