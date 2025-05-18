-- Assessment_Q2.sql
-- Question 2: Transaction Frequency Analysis
-- ------------------------------------------------------------
-- Objective:
-- Segment users into three frequency categories based on their
-- average number of inflow transactions per month:
--   - High Frequency (≥ 10 transactions/month)
--   - Medium Frequency (3–9 transactions/month)
--   - Low Frequency (≤ 2 transactions/month)
--
-- Approach:
-- 1. The first CTE (user_activity) aggregates each user's:
--    - Total number of transactions (COUNT)
--    - Duration of activity in months using TIMESTAMPDIFF
--      between their earliest and most recent transaction
--      (plus 1 to avoid division by zero)
--
-- 2. The second CTE (user_frequency) calculates:
--    - The average monthly transaction count
--      → ROUND(total_transactions / active_months, 2)
--    - A frequency category using a CASE expression based on
--      the average transactions per month
--
-- 3. The final SELECT groups users by frequency category and:
--    - Counts how many users fall into each category
--    - Computes the average monthly transaction rate within each group
--    - Orders categories logically using CASE
--
-- The Rationale for using this SQL Techniques:
-- - TIMESTAMPDIFF(MONTH, ...) hepl provides accurate tenure in months,
--   which is better than counting raw dates or weeks.
-- - CTEs (Common Table Expressions) were also used to make each step
--   modular, readable, and easy to debug or extend.
-- - CASE WHEN ... THEN categorization allows clean segmentation
--   logic directly in SQL without needing post-processing.
-- - ROUND is used to control precision for reporting clarity.
--
-- Output Columns:
-- frequency_category | customer_count | avg_transactions_per_month
-- ============================================================


WITH user_activity AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(transaction_date), MAX(transaction_date)) + 1 AS active_months
    FROM savings_savingsaccount
    GROUP BY owner_id
),
user_frequency AS (
    SELECT 
        owner_id,
        total_transactions,
        active_months,
        ROUND(total_transactions / active_months, 2) AS avg_transactions_per_month,
        CASE
            WHEN (total_transactions / active_months) >= 10 THEN 'High Frequency'
            WHEN (total_transactions / active_months) BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM user_activity
)
SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 2) AS avg_transactions_per_month
FROM user_frequency
GROUP BY frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
