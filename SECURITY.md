# Security Policy

This repository documents the production deployment of Swarm Nexus. It does not contain deployment secrets.

- No API keys, cookies, private keys, or mnemonics are stored in Git.
- Runtime secrets (e.g., X/Twitter cookies, service env files) live only on the production host:
  - /opt/swarmnexus/collector/twitter-cookies.json (symlink to /opt/swarmnexus/data/twitter-cookies.json)
  - /opt/swarmnexus/{collector,agent}/.env
- The linked component repositories (Dashboard, Collector, Agent) remain private. Their links are provided for structure and provenance only.

Operational notes:
- SQLite database is read/written locally on the host under /opt/swarmnexus/data/swarm.db (WAL).
- Nginx terminates TLS for https://swarm-nexus.xyz. certbot.timer is enabled for automated renewal.
- Backups run via systemd and are compressed with retention; the backup directory is not public.

If you discover a security issue, please contact the maintainer privately.
