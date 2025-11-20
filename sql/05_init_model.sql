-- =============================================
-- 05_init_model.sql: Initial model training
-- =============================================

-- Train initial model after data insert
INSERT INTO anomaly_model (model_bytes)
SELECT train_isolation_forest(
    ARRAY(
        SELECT extract_log_features_v2(time, service, level, message, endpoint, method, status_code, duration_ms, cost_cents)
        FROM logs
    ),
    100, 256
);

-- (Optional) Manual retraining example
CREATE OR REPLACE FUNCTION retrain_isolation_forest()
RETURNS void AS $$
DECLARE
    new_model bytea;
BEGIN
    new_model := train_isolation_forest(
        ARRAY(
            SELECT extract_log_features_v2(
                time,
                service,
                level,
                message,
                endpoint,
                method,
                status_code::varchar,
                duration_ms::varchar,
                cost_cents::varchar
            ) FROM logs
        ),
        100, 32
    );
    INSERT INTO anomaly_model (model_bytes) VALUES (new_model);
END;
$$ LANGUAGE plpgsql;
