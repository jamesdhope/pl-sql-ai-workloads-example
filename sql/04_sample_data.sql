-- =============================================
-- 04_sample_data.sql: Sample data inserts
-- =============================================

-- Insert initial sample data before triggers and model
INSERT INTO logs (time, service, level, message, endpoint, method, status_code, duration_ms, cost_cents) VALUES
    (NOW(), 'api', 'INFO', 'Request completed', '/v1/data', 'GET', '200', '120', '0.05'),
    (NOW(), 'auth', 'ERROR', 'Login failed', '/v1/login', 'POST', '401', '250', '0.00'),
    (NOW(), 'api', 'WARN', 'Slow response', '/v1/data', 'GET', '200', '900', '0.10'),
    (NOW(), 'billing', 'INFO', 'Payment processed', '/v1/pay', 'POST', '201', '80', '1.99'),
    (NOW(), 'api', 'INFO', 'Request completed', '/v1/data', 'DELETE', '204', '60', '0.00');
