-- =============================================
-- 02_functions.sql: PL/Python functions
-- =============================================

-- Feature extraction function for logs
CREATE OR REPLACE FUNCTION extract_log_features_v2(
    log_time timestamptz,
    service varchar,
    level varchar,
    message varchar,
    endpoint varchar,
    method varchar,
    status_code varchar,
    duration_ms varchar,
    cost_cents varchar
)
RETURNS double precision[]
LANGUAGE plpython3u
AS $$
features = []
import math
# Always set temporal features to zero
features.extend([0.0, 0.0, 0.0])

def to_float(val, default=0.0):
    try:
        return float(val)
    except Exception:
        return default

def to_int(val, default=0):
    try:
        return int(val)
    except Exception:
        return default

# Duration (log-scaled)
duration_val = to_float(duration_ms)
duration_log = math.log(duration_val + 1.0) if duration_val is not None else 0.0
features.append(duration_log)

# Status code (normalized)
status_val = to_int(status_code)
status_normalized = status_val / 600.0 if status_val else 0.0
features.append(status_normalized)
status_category = (status_val // 100) / 10.0 if status_val else 0.0
features.append(status_category)

# Cost (log-scaled)
cost_val = to_float(cost_cents)
cost_log = math.log(cost_val + 0.01) if cost_val is not None else 0.0
features.append(cost_log)

# Log level encoding
is_error = 1.0 if level == 'ERROR' else 0.0
is_warn = 1.0 if level == 'WARN' else 0.0
is_info = 1.0 if level == 'INFO' else 0.0
features.extend([is_error, is_warn, is_info])

# HTTP method encoding
is_get = 1.0 if method == 'GET' else 0.0
is_post = 1.0 if method == 'POST' else 0.0
is_put = 1.0 if method == 'PUT' else 0.0
is_delete = 1.0 if method == 'DELETE' else 0.0
features.extend([is_get, is_post, is_put, is_delete])

return features
$$;

-- Model scoring function
CREATE OR REPLACE FUNCTION score_isolation_forest(model_bytes bytea, features double precision[])
RETURNS double precision
LANGUAGE plpython3u
AS $$
import pickle
import numpy as np
model = pickle.loads(model_bytes)
score = model.decision_function(np.array(features).reshape(1, -1))[0]
return float(score)
$$;

-- Model training function
CREATE OR REPLACE FUNCTION train_isolation_forest(feature_matrix double precision[][], n_estimators integer, max_samples integer)
RETURNS bytea
LANGUAGE plpython3u
AS $$
import pickle
import numpy as np
from sklearn.ensemble import IsolationForest
X = np.array(feature_matrix)
model = IsolationForest(n_estimators=n_estimators, max_samples=max_samples, random_state=42)
model.fit(X)
return pickle.dumps(model)
$$;
