#  DataAnalytics-Assessment

Welcome to my submission for the SQL Proficiency Assessment and thank you for the opportunity. This repository showcases my ability to translate complex business questions into clean, efficient, and readable SQL solutions, driven by real-world scenarios across customer behavior, finance, marketing, and operations.

Each `.sql` file in this project contains:
- A clear and structured solution to a data problem
- Thoughtfully written comments for clarity
- Scalable logic using Common Table Expressions (CTEs)
- Performance-optimized joins and aggregations
- Practical business reasoning behind every decision

---

## This is the Repository Structure

DataAnalytics-Assessment/
│
├── Assessment_Q1.sql # Cross-product analysis
├── Assessment_Q2.sql # Frequency segmentation
├── Assessment_Q3.sql # Inactivity alert logic
├── Assessment_Q4.sql # CLV estimation modeling
└── README.md



##  Here is the Case-by-Case Breakdown

###  Q1: High-Value Customers with Multiple Products

** Goal:**  
To identify customers with both a savings and an investment plan, sorted by total inflows.

** My Approach:**  
- I used `JOIN` on `plans_plan` and `savings_savingsaccount`  
- Applied `CASE WHEN` to separately count savings vs. investment plans  
- Used `COALESCE` to show the most complete name per customer
- Aggregated confirmed deposits (converted from kobo to naira)
-In all queries that return user names, I implemented a fallback strategy using `COALESCE` to ensure that meaningful, readable names are always shown:

- Primary: `name` column
- Fallback 1: `first_name + last_name`
- Fallback 2: `email`
- Fallback 3: `username`
- Fallback 4: Default label "No Name"

This improves result quality and ensures no rows are missing user identifiers even when certain profile fields are incomplete.


** Business Insight:**  
This Pinpoints multi-product users with high engagement for cross-selling campaigns.

---

###  Q2: Transaction Frequency Analysis

** Goal:**  
Segment users based on monthly transaction frequency: High, Medium, or Low.

** My Approach:**  
- I Calculated user activity period using `TIMESTAMPDIFF`  
- Averaged transactions per month using modular CTEs  
- Categorized frequency behavior using `CASE` logic  
- Ordered results by behavioral tier for operational clarity

** Business Insight:**  
It helps marketing teams tailor communication based on engagement frequency.

---

###  Q3: Account Inactivity Alert

** Goal:**  
To identify accounts with no inflow activity for over a year.

** My Approach:**  
- I calculated the latest inflow using `MAX(transaction_date)`  
- Filtered out archived or deleted plans  
- Measured inactivity in days using `DATEDIFF`  
- Classified plan type using `CASE WHEN` for readability

** Business Insight:**  
To Supports operations(ops) in surfacing dormant plans for recovery or churn prevention.

---

### Q4: Customer Lifetime Value (CLV) Estimation
** Goal: **
It is to estimate a simplified version of Customer Lifetime Value (CLV) using each user's historical transaction activity and account tenure.

** My Approach: **

-Showed the aggregated total number of inflow transactions and their value per user
-Converted all transaction values from kobo to naira
-Measured account tenure in months using TIMESTAMPDIFF between date_joined and the current date
-Handled new users with 0-month tenure using a CASE fallback (replacing 0 with 1 to avoid division errors)
-Estimated CLV using this formula:
CLV = \left(\frac{\text{total_transactions}}{\text{tenure_months}}\right) \times 12 \times (0.1\% \times \text{avg_transaction_value})
-Applied ROUND to format monetary output
- Constructed user-friendly name fallback using COALESCE with first_name, last_name, email, and username

** Business Insight: **
This approach helps prioritize users who are both:

-Highly active (high transaction count)
-Consistently contributing high transaction value
-It supports marketing decisions like identifying VIP users, targeting retention programs, or offering premium incentives.


---

##  Tools & Techniques I Used 

-  **SQL Optimization:** Clean, index-aware join logic  
-  **CTEs:** For modular and readable query design  
-  **CASE + COALESCE:** For flexible categorization and naming  
-  **Unit Normalization:** Kobo → Naira conversion for financial accuracy  
-  **Edge Case Handling:** 0-month tenure, blank names, null fallbacks  
-  **Readable Formatting:** Comments and spacing to support maintainability  

---

## Challenges & How I Solved Them

| Challenge | Resolution |
|----------|------------|
| Missing user names in `users_customuser` | Used `COALESCE` with fallbacks: first name + last name, email, username |
| Monetary inconsistency (kobo vs naira) | Explicitly divided `confirmed_amount` by 100 |
| Potential divide-by-zero in tenure | Applied `CASE` logic to default 0-month tenure to 1 |
| Segmenting non-linear behavior | Applied `CASE` ranges for transaction frequency tiers |

---

##  Please Note:

This isn’t just SQL. Each query reflects:
- Real-world **business intelligence**
- Robust handling of **data edge cases**
- Clean code that’s easy for stakeholders or engineers to maintain
- Strategic thinking around **behavioral modeling, financial analysis, and operational efficiency**

---

Thank you for reviewing my submission. I'm excited about the opportunity and would be happy to discuss any part of my approach further.

