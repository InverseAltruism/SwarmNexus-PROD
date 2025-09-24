#!/usr/bin/env bash
set -euo pipefail
sudo install -d /etc/systemd/system/swarm-dashboard.service.d
sudo install -m 0644 ops/systemd/swarm-dashboard.service.d/env.conf \
  /etc/systemd/system/swarm-dashboard.service.d/env.conf
sudo systemctl daemon-reload
sudo systemctl restart swarm-dashboard
