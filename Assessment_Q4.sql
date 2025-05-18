-- Assessment_Q4.sql
-- Question 4: Customer Lifetime Value (CLV) Estimation
-- ------------------------------------------------------------
-- Objective:
-- To estimate Customer Lifetime Value (CLV) using a simplified model:
-- CLV = (Average Monthly Transactions) × 12 × Avg Profit Per Transaction
-- 
-- The Assumptions are:
-- - Profit per transaction = 0.1% of the transaction value
-- - confirmed_amount is in kobo and must be converted to naira
-- - Account tenure is measured in months since date_joined
--
-- Here is the Approach:
-- 1. The first CTE (transaction_summary) calculates:
--    - Total number of inflow transactions per customer
--    - Total inflow value in naira (converted from kobo)
--    - Average transaction value in naira
--
-- 2. The second CTE (user_clv):
--    - Joins with the users table to get name and date_joined
--    - Calculates account tenure using TIMESTAMPDIFF in months
--    - Uses a CASE to ensure tenure is never zero (avoids divide-by-zero)
--    - Calculates CLV using the formula:
--      CLV = (transactions / tenure_months) * 12 * 0.1% of avg transaction value
--    - Applies ROUND for reporting precision
--    - Uses COALESCE to construct the best possible name per user
--
-- 3. The final SELECT:
--    - Returns all relevant fields
--    - Orders customers by estimated CLV in descending order
--
-- Rationale for SQL Techniques Used:
-- - Division by 100 ensures correct unit conversion from kobo to naira
-- - COALESCE ensures no user is left without a readable name
-- - TIMESTAMPDIFF gives precise tenure in calendar months
-- - CASE WHEN handles tenure edge cases for new users
-- - ROUND ensures consistent monetary formatting in results
-- - CTEs modularize the logic for easier maintenance and debugging
--
-- Output Columns:
-- customer_id | name | tenure_months | total_transactions | estimated_clv
-- ============================================================

WITH transaction_summary AS (
    SELECT 
        s.owner_id,
        COUNT(*) AS total_transactions,
        SUM(s.confirmed_amount) / 100 AS total_value_naira,  -- convert from kobo to naira
        AVG(s.confirmed_amount) / 100 AS avg_transaction_value_naira
    FROM savings_savingsaccount s
    WHERE s.confirmed_amount > 0
    GROUP BY s.owner_id
),
user_clv AS (
    SELECT 
        u.id AS customer_id,
        COALESCE(NULLIF(TRIM(u.name), ''),
                 CONCAT(TRIM(u.first_name), ' ', TRIM(u.last_name)),
                 u.email,
                 u.username,
                 'No Name') AS name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) AS tenure_months,
        t.total_transactions,
        ROUND(
            (
                t.total_transactions /
                CASE 
                    WHEN TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE()) = 0 THEN 1
                    ELSE TIMESTAMPDIFF(MONTH, u.date_joined, CURDATE())
                END
            ) * 12 * (0.001 * t.avg_transaction_value_naira),
            2
        ) AS estimated_clv
    FROM users_customuser u
    JOIN transaction_summary t ON u.id = t.owner_id
)
SELECT *
FROM user_clv
ORDER BY estimated_clv DESC;
