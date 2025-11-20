# Log Anomaly Detection System

AI-powered log analysis using TimescaleDB and PL/Python (Isolation Forest).

**Key Insight:** All ML processing happens **inside the database** — keep the AI near the data for maximum performance.

## Overview

**Problem:** Cloud logging shows you infrastructure metrics. You need to know:
- Which API endpoint is degrading
- Why costs spiked overnight
- What error pattern just started
- Which customer is experiencing issues

**Solution:** AI-powered log analysis that:
- Learns normal patterns automatically (Isolation Forest in-database)
- Alerts on real anomalies (not just thresholds)
- Explains the root cause (feature importance analysis)
- Tracks cost per customer/endpoint

## Architecture

```
┌─────────────────────────────────────────────────┐
│         Lightweight Log Ingestion API           │
│         (HTTP → SQL)                            │
└──────────────────┬──────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────┐
│              TimescaleDB                        │
│  ┌──────────────────────────────────────┐      │
│  │  PL/Python Functions (AI Core)        │      │
│  │  • extract_log_features_v2()          │      │
│  │  • train_isolation_forest()           │      │
│  │  • score_isolation_forest()           │      │
│  └──────────────────────────────────────┘      │
│                                                 │
│  ┌──────────────────────────────────────┐      │
│  │  Triggers (Automatic Processing)     │      │
│  │  • On INSERT: Extract features       │      │
│  │  • On INSERT: Score for anomalies    │      │
│  └──────────────────────────────────────┘      │
│                                                 │
│  ┌──────────────────────────────────────┐      │
│  │  Background Jobs (Manual/Planned)    │      │
│  │  • Retrain IF model                  │      │
│  └──────────────────────────────────────┘      │
└─────────────────────────────────────────────────┘
```

**Benefits:**
- ⚡ **Fast**: No data movement, native in-database Python performance
- 💰 **Cheap**: No external ML services, compute happens where data lives
- 🔒 **Secure**: Data never leaves your database
- 📈 **Scalable**: TimescaleDB handles billions of logs

## Tech Stack

- **TimescaleDB**: Time-series optimized PostgreSQL for log storage
- **PL/Python**: In-database anomaly detection (Isolation Forest)
- **Isolation Forest**: Fast real-time outlier detection (100% in-database)
- **Python/PL/Python**: Feature extraction, model training, scoring
- **Docker Compose**: Local development setup

## Project Structure

```
├── sql/                    # Database schema and setup
│   ├── 01_schema.sql       # Tables, extension, and columns
│   ├── 02_functions.sql    # PL/Python functions (feature extraction, model)
│   ├── 03_triggers.sql     # Trigger functions and creation
│   ├── 04_sample_data.sql  # Sample log data inserts
│   └── 05_init_model.sql   # Initial model training and retraining
├── ingestion-api/          # Lightweight HTTP API (optional)
│   └── src/main.rs         # API server (if used)
├── docker-compose.yml      # Local development setup
└── README.md               # Project documentation
```

## Setup & Deployment

1. Start TimescaleDB using Docker Compose:
   ```bash
   docker-compose up timescaledb
   ```
2. Apply SQL files in order:
   ```bash
   psql -U postgres -d anomaly_detection -f sql/01_schema.sql
   psql -U postgres -d anomaly_detection -f sql/02_functions.sql
   psql -U postgres -d anomaly_detection -f sql/03_triggers.sql
   psql -U postgres -d anomaly_detection -f sql/04_sample_data.sql
   psql -U postgres -d anomaly_detection -f sql/05_init_model.sql
   ```
3. (Optional) Start the ingestion API for log input.

## Notes
- All ML logic is in PL/Python functions inside the database.
- For maintainability, SQL is split into logical modules.
- Retraining and advanced jobs can be scheduled or run manually.

---

For details on each SQL file, see comments at the top of each file in the `sql/` directory.
# pl-sql-ai-workloads-example
