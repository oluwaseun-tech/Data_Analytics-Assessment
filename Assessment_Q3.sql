-- Assessment_Q3.sql
-- Question 3: Account Inactivity Alert
-- ------------------------------------------------------------
-- Objective:
-- To identify all active savings or investment plans that have not
-- To receive any inflow transactions (confirmed_amount > 0) in
-- the past 365 days.
--
-- This supports the operations team's goal to flag dormant accounts
-- for re-engagement or risk monitoring.
--
-- Here is the Approach:
-- 1. The first CTE (last_transactions) computes the most recent
--    inflow transaction date for each plan by taking the MAX of
--    transaction_date from savings_savingsaccount where the 
--    confirmed_amount is greater than 0 (to exclude non-inflow).
--
-- 2. The main SELECT:
--    - Joins the result with plans_plan to bring in plan metadata.
--    - Filters to active plans only using:
--        → p.is_deleted = 0
--        → p.is_archived = 0
--    - Uses a CASE expression to label plan type as 'Savings',
--      'Investment', or 'Other' based on plan_type_id.
--    - Calculates inactivity_days using DATEDIFF between today
--      (CURDATE()) and the last transaction date.
--
-- 3. Filters for plans with inactivity_days > 365 to isolate those
--    that are dormant for at least one year.
--
-- 4. Results are ordered by inactivity_days DESC to prioritize
--    the longest-inactive plans at the top of the report.
--
-- Rationale for SQL Techniques Used:
-- - MAX(transaction_date) is a simple and efficient way to find
--   the most recent inflow per plan.
-- - DATEDIFF is ideal for calculating days since last activity.
-- - CASE WHEN is used for readable plan type labels without
--   needing another join to a lookup table.
-- - CTE usage keeps the logic modular and improves readability.
--
-- Output Columns:
-- plan_id | owner_id | type | last_transaction_date | inactivity_days
-- ============================================================

WITH last_transactions AS (
    SELECT 
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    WHERE confirmed_amount > 0
    GROUP BY plan_id
)

SELECT 
    p.id AS plan_id,
    p.owner_id,
    CASE 
        WHEN p.plan_type_id = 1 THEN 'Savings'
        WHEN p.plan_type_id = 2 THEN 'Investment'
        ELSE 'Other'
    END AS type,
    lt.last_transaction_date,
    DATEDIFF(CURDATE(), lt.last_transaction_date) AS inactivity_days
FROM plans_plan p
JOIN last_transactions lt ON p.id = lt.plan_id
WHERE 
    p.is_deleted = 0
    AND p.is_archived = 0
    AND DATEDIFF(CURDATE(), lt.last_transaction_date) > 365
ORDER BY inactivity_days DESC;
