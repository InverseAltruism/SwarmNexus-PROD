import sqlite3, pathlib
p = pathlib.Path("data/swarm.db"); p.parent.mkdir(exist_ok=True)
conn = sqlite3.connect(p)
conn.executescript("""
CREATE TABLE IF NOT EXISTS predictions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tweet_id TEXT UNIQUE,
  author_handle TEXT,
  author_id TEXT,
  text TEXT,
  asset TEXT,
  target_date TEXT,
  status TEXT DEFAULT 'queued',
  created_at TEXT DEFAULT (datetime('now')),
  parent_tweet_id TEXT,
  parent_author_handle TEXT,
  parent_text TEXT,
  tweet_created_at TEXT,
  parent_created_at TEXT,
  tweet_url TEXT,
  parent_tweet_url TEXT
);
CREATE INDEX IF NOT EXISTS idx_predictions_created_at ON predictions(created_at);
CREATE INDEX IF NOT EXISTS idx_predictions_parent ON predictions(parent_tweet_id);
CREATE TABLE IF NOT EXISTS tickers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  symbol TEXT,
  tweet_id TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);
""")
conn.close()
print("swarm.db ready")
