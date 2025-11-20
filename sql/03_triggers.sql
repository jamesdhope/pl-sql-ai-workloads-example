-- =============================================
-- 03_triggers.sql: Trigger functions and creation
-- =============================================

-- Trigger function to score each new log on insert
CREATE OR REPLACE FUNCTION score_new_log()
RETURNS trigger AS $$
DECLARE
    latest_model bytea;
    features double precision[];
    score double precision;
BEGIN
    SELECT model_bytes INTO latest_model
    FROM anomaly_model
    ORDER BY trained_at DESC
    LIMIT 1;

    features := extract_log_features_v2(
        NEW.time, NEW.service, NEW.level, NEW.message, NEW.endpoint,
        NEW.method, NEW.status_code, NEW.duration_ms, NEW.cost_cents
    );

    score := score_isolation_forest(latest_model, features);
    NEW.anomaly_score := score;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to score logs on insert
DROP TRIGGER IF EXISTS score_log_after_insert ON logs;
CREATE TRIGGER score_log_after_insert
BEFORE INSERT ON logs
FOR EACH ROW
EXECUTE FUNCTION score_new_log();
