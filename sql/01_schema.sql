-- =============================================
-- 01_schema.sql: Table definitions
-- =============================================

-- Clean out old tables for a fresh setup
DROP TABLE IF EXISTS logs, anomaly_model CASCADE;

-- Ensure PL/Python is enabled
CREATE EXTENSION IF NOT EXISTS plpython3u;

-- Create logs table for incoming log data
CREATE TABLE IF NOT EXISTS logs (
    id serial PRIMARY KEY,
    time timestamptz NOT NULL,
    service varchar,
    level varchar,
    message varchar,
    endpoint varchar,
    method varchar,
    status_code varchar,
    duration_ms varchar,
    cost_cents varchar
);

-- Table to store latest trained model
CREATE TABLE IF NOT EXISTS anomaly_model (
    id serial PRIMARY KEY,
    trained_at timestamptz DEFAULT now(),
    model_bytes bytea NOT NULL
);

-- Add anomaly_score column to logs table (if not present)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='logs' AND column_name='anomaly_score'
    ) THEN
        ALTER TABLE logs ADD COLUMN anomaly_score double precision;
    END IF;
END$$;
