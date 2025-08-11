# Swarm Nexus - PROD Environment

## Overview
Swarm Nexus is a prediction swarm data collector and dashboard.
It monitors Twitter mentions for a target account, parses relevant tweets, and stores them in a local SQLite database.  
The dashboard serves a live view of predictions, tickers, and meta information from the swarm.

This repository contains the **production** environment setup for:
1. **Collector** (`/opt/swarmnexus/collector`) – Node.js + Puppeteer based mention scraper.
2. **Dashboard** (`/opt/swarmnexus/dashboard`) – Flask-based web UI for visualizing collected data.

---

## Features
- **Automated Twitter mention collection** (headless Puppeteer with cookies)
- **Ticker extraction** from tweets
- **SQLite database storage** in WAL mode for concurrency
- **Flask + CORS dashboard** serving JSON API and static HTML/JS frontend
- **Systemd services** for persistent running in PROD
- **Read-only DB access** from dashboard to prevent corruption

---

## Architecture

**Database**: `/opt/swarmnexus/data/swarm.db`  
**Collector log**: `journalctl -u swarm-collector -f`  
**Dashboard port**: `3010` (default)  

---

## Requirements
- **Node.js** ≥ 18  
- **npm** (bundled with Node.js)  
- **Python** ≥ 3.8  
- **pip** (Python package manager)  
- **SQLite 3**  
- **Puppeteer dependencies** (headless Chrome libs)  
- **Flask + Flask-CORS**  

---

## Environment Variables
Create a `.env` file (do not commit this file). Example:
```env
# Twitter
TW_COOKIES_PATH=/opt/swarmnexus/collector/cookies.json
MENTION_HANDLE=SwarmNexus
POLL_SECONDS=60

# Dashboard
PORT=3010
HOST=0.0.0.0

