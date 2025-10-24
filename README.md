<p align="center">
  <img src="https://github.com/InverseAltruism/SwarmNexus-PROD/blob/main/SwarmNexusTransparent.png?raw=1" alt="Swarm Nexus" width="360" />
</p>

# Swarm Nexus

**Swarm Memory. Torus Intelligence.**

Where the swarm converges, patterns emerge. From secrets to prophecy.

---

## 🧠 What is Swarm Nexus?

Swarm Nexus is the **memory organ of the Torus Network**—a decentralized system that ingests, stores, and surfaces every interaction related to Torus across X (Twitter) and beyond.

Every mention. Every prediction. Every ticker. **Every interaction feeds our collective memory.**

- 🔍 **Real-time ingestion** of Torus-related content from X
- 📊 **Performance tracking** and leaderboards for contributors
- 🏆 **SWARM Points** — gamified rewards for network engagement
- 🔌 **REST API** for developers building on Torus
- 🌐 **Live at** [swarm-nexus.xyz](https://swarm-nexus.xyz)

---

## 🎯 For Developers

### API Endpoints

Access the Swarm Memory through our public REST API:

**Base URL:** `https://swarm-nexus.xyz/agent/`

#### Get Recent Mentions
```bash
curl "https://swarm-nexus.xyz/agent/memory/mentions?limit=10"
```

**Response:**
```json
{
  "items": [
    {
      "type": "mention.v1",
      "id": "1234567890",
      "tweetUrl": "https://x.com/user/status/1234567890",
      "text": "Bullish on $TORUS...",
      "author": {
        "handle": "cryptotrader",
        "id": "123456"
      },
      "tickers": ["$TORUS"],
      "ingestedAt": "2025-10-24T08:30:00Z"
    }
  ]
}
```

#### Search by Ticker
```bash
curl "https://swarm-nexus.xyz/agent/memory/tickers?ticker=%24TORUS&limit=20"
```

#### Filter by Author
```bash
curl "https://swarm-nexus.xyz/agent/memory/mentions?author=username&limit=50"
```

**Full API Documentation:** [OpenAPI Spec](https://swarm-nexus.xyz/agent/openapi.yaml)

---

## 🏆 SWARM Points System

Contribute to the network and earn SWARM points:

| Activity | Points | Description |
|----------|--------|-------------|
| **$TORUS Ticker** | 0.1 | Tweet mentions of $TORUS |
| **@SwarmNexus Mention** | 0.3 | Direct engagement with Swarm Nexus |
| **Long-form Content** | 0.5 | Detailed analysis (>1000 characters) |

Track your rank on the [Leaderboard](https://swarm-nexus.xyz/leaderboard) and compete for top contributor status.

---

## 🌟 Key Features

### Memory Ingestion
- Automated scraping of X for Torus-related content
- Real-time processing of mentions, predictions, and ticker usage
- Thread hydration to capture full conversation context

### Performance Analytics
- Author leaderboards with time-window filtering (12h, 24h, 7d, 30d)
- Prediction accuracy tracking
- Community engagement metrics

### Developer-First
- RESTful API with OpenAPI documentation
- Read-only database access for safety
- JSON responses with structured data

### Web Dashboard
- Live prediction feed
- User profiles with wallet integration
- Performance visualization
- SWARM points tracking

---

## 🚀 Get Started

1. **Visit** [swarm-nexus.xyz](https://swarm-nexus.xyz)
2. **Create an account** to track your contributions
3. **Engage with Torus** on X — mention $TORUS or @SwarmNexus
4. **Earn SWARM points** and climb the leaderboard
5. **Use the API** to build your own Torus-powered applications

---

## 🛠️ Technical Stack

- **Backend:** Node.js (Collector, Agent) + Python (Dashboard)
- **Database:** SQLite with WAL mode for concurrent access
- **Scraping:** Puppeteer-based X monitoring
- **Web Server:** Flask + Gunicorn behind Nginx
- **Infrastructure:** Ubuntu 23.04, systemd services, Let's Encrypt TLS

---

## 📚 Resources

- **Live Site:** [swarm-nexus.xyz](https://swarm-nexus.xyz)
- **API Docs:** [OpenAPI Spec](https://swarm-nexus.xyz/agent/openapi.yaml)
- **GitHub:** Component repositories
  - [SwarmNexus-PROD](https://github.com/InverseAltruism/SwarmNexus-PROD) — Production deployment
  - [SwarmNexus-Dashboard](https://github.com/InverseAltruism/SwarmNexus-Dashboard) — Web interface
  - [SwarmNexus-Agent](https://github.com/InverseAltruism/SwarmNexus-Agent) — REST API
  - [SwarmNexus-Collector](https://github.com/InverseAltruism/SwarmNexus-Collector) — Ingestion engine

---

## 🤝 Contributing

Swarm Nexus is built for the Torus community. Contributions welcome:

- **Engage:** Mention @SwarmNexus or use $TORUS on X
- **Build:** Use our API to create Torus tools
- **Feedback:** Open issues or suggestions in our repos
- **Spread the word:** Share Swarm Nexus with the Torus community

---

## 📄 License

MIT License — See [LICENSE](LICENSE) for details

---

<p align="center">
  <strong>Build. Contribute. Earn.</strong><br>
  Every interaction feeds the Swarm.
</p>