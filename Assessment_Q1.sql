-- Assessment_Q1.sql
-- Question 1: High-Value Customers with Multiple Products
-- ------------------------------------------------------------
-- Objective:
-- Identify customers who have both a funded savings plan 
-- (is_regular_savings = 1) and a funded investment plan 
-- (is_a_fund = 1). Return the number of each plan type, 
-- along with total deposit value per user.
--
-- Here is the Approach:
-- - Join users with their plans and savings transactions.
-- - Filter for non-zero confirmed inflows.
-- - Use COUNT with CASE to split savings vs investments.
-- - Group by customer, and order by total deposits.
--
-- Output Columns:
-- owner_id | name | savings_count | investment_count | total_deposits
-- ============================================================


 -- Use COALESCE to display the most complete available name for each user.
-- Priority order:
-- 1. u.name — if present and not blank
-- 2. CONCAT(u.first_name, ' ', u.last_name) — if both names exist
-- 3. u.email — fallback if no name
-- 4. u.username — further fallback if email is also unavailable
-- 5. 'No Name' — default label for completely anonymous users

SELECT 
    u.id AS owner_id,
    COALESCE(
        NULLIF(TRIM(u.name), ''),
        NULLIF(CONCAT(TRIM(u.first_name), ' ', TRIM(u.last_name)), ' '),
        u.email,
        u.username,
        'No Name'
    ) AS name,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 1 THEN p.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.plan_type_id = 2 THEN p.id END) AS investment_count,
    ROUND(IFNULL(SUM(s.confirmed_amount), 0), 2) AS total_deposits
FROM users_customuser u
JOIN plans_plan p ON u.id = p.owner_id
JOIN savings_savingsaccount s ON s.plan_id = p.id
GROUP BY u.id, name
HAVING savings_count > 0 AND investment_count > 0
ORDER BY total_deposits DESC;

