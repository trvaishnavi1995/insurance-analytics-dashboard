-- ===============================
-- USE DATABASE
-- ===============================
USE insurance_db;

-- ===============================
-- CLEAN VIEW (UPDATED)
-- ===============================
CREATE OR REPLACE VIEW clean_insurance_data AS
SELECT
    STR_TO_DATE(Start_Date, '%Y-%m-%d') AS start_date,
    STR_TO_DATE(End_Date, '%Y-%m-%d') AS end_date,
    Gender AS gender
FROM motor_data
WHERE Start_Date IS NOT NULL
  AND End_Date IS NOT NULL;

-- ===============================
-- FEATURE ENGINEERING
-- ===============================
CREATE OR REPLACE VIEW insurance_features AS
SELECT
    start_date,
    end_date,
    gender,
    YEAR(start_date) AS year,
    MONTH(start_date) AS month,
    DATEDIFF(end_date, start_date) AS duration_days
FROM clean_insurance_data;

-- ===============================
-- KPI VIEW
-- ===============================
CREATE OR REPLACE VIEW dashboard_kpis AS
SELECT
    COUNT(*) AS total_policies,
    ROUND(AVG(duration_days), 2) AS avg_duration_days,
    COUNT(DISTINCT year) AS total_years
FROM insurance_features;

-- ===============================
-- YEARLY TREND
-- ===============================
CREATE OR REPLACE VIEW dashboard_yearly AS
SELECT
    year,
    COUNT(*) AS total_policies
FROM insurance_features
GROUP BY year
ORDER BY year;

-- ===============================
-- MONTHLY TREND
-- ===============================
CREATE OR REPLACE VIEW dashboard_monthly AS
SELECT
    month,
    COUNT(*) AS total_policies
FROM insurance_features
GROUP BY month
ORDER BY month;

-- ===============================
-- GENDER DISTRIBUTION
-- ===============================
CREATE OR REPLACE VIEW dashboard_gender AS
SELECT
    gender,
    COUNT(*) AS total_policies
FROM insurance_features
GROUP BY gender
ORDER BY total_policies DESC;

-- ===============================
-- DURATION CATEGORY
-- ===============================
CREATE OR REPLACE VIEW dashboard_duration_category AS
SELECT
    CASE 
        WHEN duration_days < 365 THEN 'Short-term'
        WHEN duration_days BETWEEN 365 AND 730 THEN 'Medium-term'
        ELSE 'Long-term'
    END AS policy_type,
    COUNT(*) AS total_policies
FROM insurance_features
GROUP BY policy_type;

-- ===============================
-- TEST OUTPUT
-- ===============================

CREATE OR REPLACE VIEW dashboard_gender AS
SELECT 
    CASE 
        WHEN gender = 0 THEN 'Male'
        WHEN gender = 1 THEN 'Female'
        WHEN gender = 2 THEN 'Other'
        ELSE 'Unknown'
    END AS gender,
    COUNT(*) AS total_policies
FROM insurance_features
GROUP BY gender;
CREATE OR REPLACE VIEW insurance_features AS
SELECT
    start_date,
    end_date,
    gender,
    YEAR(start_date) AS year,
    MONTH(start_date) AS month,
    DATEDIFF(end_date, start_date) AS duration_days
FROM clean_insurance_data;
SELECT 
    year,
    COUNT(*) AS total_policies,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2
    ) AS contribution_percent
FROM insurance_features
GROUP BY year;
SHOW FULL TABLES WHERE TABLE_TYPE = 'VIEW';

SELECT * FROM dashboard_kpis;
SELECT * FROM dashboard_yearly;
SELECT * FROM dashboard_monthly;
SELECT * FROM dashboard_gender;