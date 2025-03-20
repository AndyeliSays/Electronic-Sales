--					[ CLEANING ]  
/* 
		1. [ Potential Irrelevant data ], 2. [ Duplicate data ], 3.[ Structural Errors - Naming conventions, typos, capitalization, notNULLs, extra spaces ], 
		4. [ Missing Data & NULLs ] 5. [ Standardize - Datatype, Numerics], 6. [ Outliers ] 7. [ Merge, Transform, Drop]
  				--> Done in Powerquery
*/

--					[ ANALYSIS ]

SELECT * 
FROM information_schema.columns
WHERE table_name = 'electronic_sales_sep2023_sep2024_cleaned';

SELECT *
FROM electronic_sales_sep2023_sep2024_cleaned es;

-- Need to be strategic about where to use =completed orders filter
-- Loyalty member can change over time so need to check for last purchase date loyalty member = yes, had to redo all queries with loyalty member because of this

--			(Basic Metrics)

-- 1. Sales KPIs
SELECT 
    SUM(es."Total Price") AS gross_revenue,
    SUM(CASE WHEN es."Order Status" = 'Completed' THEN es."Total Price" ELSE 0 END) AS net_revenue,
    SUM(es."Quantity") AS total_units_sold,
    ROUND(AVG(es."Total Price"),2) AS average_transaction,
    ROUND(AVG(es."Quantity"),2) AS avg_quantity,
    ROUND(AVG(es."Rating"),2) AS average_rating,
    SUM(es."Extended Warranty") AS total_extended_warranties,
    SUM(es."Accessory") AS total_accessories,
    SUM(es."Impulse") AS total_impulse_items,
    SUM(es."Add-on Total") AS addons_revenue
FROM electronic_sales_sep2023_sep2024_cleaned es;

--			(Customer Demographics & Loyalty) 

-- 1. Age Breakdown
WITH latest_status AS (		-- CTE for loyalty member most recent status and age segments
    SELECT 
        es."Customer ID",
        es."Gender",
        es."Loyalty Member",
        MAX(es."Purchase Date") AS latest_date,
        CASE 
            WHEN es."Age" < 25 THEN 'Young Adult'
            WHEN es."Age" BETWEEN 25 AND 40 THEN 'Adult'
            WHEN es."Age" BETWEEN 41 AND 60 THEN 'Middle Age'
            ELSE 'Senior'
        END AS age_segment
    FROM electronic_sales_sep2023_sep2024_cleaned es
    WHERE es."Order Status" = 'Completed'
    GROUP BY es."Customer ID", es."Gender", es."Loyalty Member", 
             CASE 
                 WHEN es."Age" < 25 THEN 'Young Adult'
                 WHEN es."Age" BETWEEN 25 AND 40 THEN 'Adult'
                 WHEN es."Age" BETWEEN 41 AND 60 THEN 'Middle Age'
                 ELSE 'Senior'
             END
),
customer_segments AS (		-- CTE for aggregations joined with main table
    SELECT
        ls."Customer ID",
        ls."Gender",
        ls."Loyalty Member",
        SUM(es."Total Price") AS total_spent,
        COUNT(*) AS purchase_count,
        AVG(es."Rating") AS avg_rating,
        ls.age_segment
    FROM electronic_sales_sep2023_sep2024_cleaned es
    JOIN latest_status ls
        ON es."Customer ID" = ls."Customer ID"
        AND es."Purchase Date" = ls.latest_date
    WHERE es."Order Status" = 'Completed'
    GROUP BY ls."Customer ID", ls."Gender", ls."Loyalty Member", ls.age_segment
)
SELECT
    age_segment,
    "Gender",
    "Loyalty Member",
    COUNT(DISTINCT "Customer ID") AS customer_count, -- Ensures unique customers
    ROUND(AVG(total_spent), 2) AS average_customer_spend,
    ROUND(AVG(avg_rating), 2) AS average_satisfaction
FROM customer_segments
GROUP BY age_segment, "Gender", "Loyalty Member"
ORDER BY age_segment, "Gender", "Loyalty Member";


-- 2. Loyalty Members Percentage

WITH latest_status AS ( 
    SELECT 
        es."Customer ID",
        es."Loyalty Member",
        MAX(es."Purchase Date") AS latest_date
    FROM electronic_sales_sep2023_sep2024_cleaned es
    --WHERE es."Order Status" = 'Completed' 		--filtering for orders that have completed, loyalty %
    GROUP BY es."Customer ID", es."Loyalty Member"
),
most_recent_status AS (
    SELECT DISTINCT ON (ls."Customer ID") -- count(distinct) gives single numerical value need to apply FILTER ON customer id, use DISTINCT ON
        ls."Customer ID",
        ls."Loyalty Member"
    FROM latest_status ls
    ORDER BY ls."Customer ID", ls.latest_date DESC
)
SELECT 
    ROUND(COUNT(*) FILTER (WHERE ms."Loyalty Member" = 'Yes') * 100.0 / COUNT(*), 2) AS percentage_loyalty_yes
FROM most_recent_status ms;
/* WHERE EXISTS (
      SELECT 1
      FROM electronic_sales_sep2023_sep2024_cleaned es
      WHERE es."Customer ID" = ms."Customer ID"
	  AND es."Order Status" = 'Completed'
  );	
  */ 		
-- filtering for all loyalty members of recency where orders are completed - cant use WHERE es."Order Status" , not part of 2nd CTE

-- filtering by complete orders in cte: 21.35%, 
-- filtering in outer query: 21.06% 
-- no filter: 21.05%, suggests uniform participation across order completion status

-- 3. Loyalty Change & Average Order Value
WITH loyalty_changes AS (		--CTE using LAG to track YES->NO & NO->YES
    SELECT
        es."Customer ID",
        es."Purchase Date",
        es."Loyalty Member",
        LAG(es."Loyalty Member") OVER (PARTITION BY es."Customer ID" ORDER BY es."Purchase Date") AS previous_loyalty_status,
        es."Total Price"
    FROM electronic_sales_sep2023_sep2024_cleaned es
),
customer_metrics AS (		--CTE aggregating signup and cancellation dates for each customer
    SELECT
        es."Customer ID",
        MAX(CASE WHEN es."Loyalty Member" = 'Yes' AND previous_loyalty_status = 'No' THEN es."Purchase Date" END) AS signup_date,
        MAX(CASE WHEN es."Loyalty Member" = 'No' AND previous_loyalty_status = 'Yes' THEN es."Purchase Date" END) AS cancellation_date
    FROM loyalty_changes es
    GROUP BY es."Customer ID"
)
SELECT
    COUNT(DISTINCT es."Customer ID") AS total_customers,
    COUNT(DISTINCT CASE WHEN signup_date IS NOT NULL THEN es."Customer ID" END) AS customers_who_signed_up,
    COUNT(DISTINCT CASE WHEN cancellation_date IS NOT NULL THEN es."Customer ID" END) AS customers_who_cancelled,
    (SELECT ROUND(AVG(es."Total Price"), 2) 
     FROM electronic_sales_sep2023_sep2024_cleaned es
     WHERE es."Loyalty Member" = 'Yes' AND es."Order Status" = 'Completed') AS avg_order_value_loyalty,
    (SELECT ROUND(AVG(es."Total Price"), 2) 
     FROM electronic_sales_sep2023_sep2024_cleaned es
     WHERE es."Loyalty Member" = 'No' AND es."Order Status" = 'Completed') AS avg_order_value_non_loyalty,
    (SELECT ROUND(AVG(es."Add-on Total"), 2) 
     FROM electronic_sales_sep2023_sep2024_cleaned es
     WHERE es."Loyalty Member" = 'Yes' AND es."Order Status" = 'Completed') AS avg_addon_value_loyalty,
    (SELECT ROUND(AVG(es."Add-on Total"), 2) 
     FROM electronic_sales_sep2023_sep2024_cleaned es
     WHERE es."Loyalty Member" = 'No' AND es."Order Status" = 'Completed') AS avg_addon_value_non_loyalty
FROM customer_metrics es;

-- 4. Gender
SELECT 
    es."Gender" ,
    COUNT(*) AS customer_count,
    ROUND(AVG(es."Age" ), 1) AS average_age,
    COUNT(CASE WHEN "Loyalty Member" = 'Yes' THEN 1 END) AS loyalty_members,
    ROUND(COUNT(CASE WHEN "Loyalty Member" = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS loyalty_percentage
FROM electronic_sales_sep2023_sep2024_cleaned es
GROUP BY es."Gender" 
ORDER BY es."Gender";

--			(Customer Value Metrics) : RFM, CLV, AOV, Churn etc.

-- 1. RFM Score
WITH customer_rfm AS (		--CTE aggregates at customer level
    SELECT 
        es."Customer ID",                                   
        MAX(es."Purchase Date") AS last_purchase_date,      
        COUNT(*) AS frequency,                              
        SUM(es."Total Price") AS monetary                    
    FROM electronic_sales_sep2023_sep2024_cleaned es
    WHERE es."Order Status" = 'Completed'                
    GROUP BY es."Customer ID"
),
rfm_scores AS (		--CTE calculates rfm scores
    SELECT 
        es."Customer ID",
        PERCENT_RANK() OVER (ORDER BY last_purchase_date DESC) AS recency_score,
        PERCENT_RANK() OVER (ORDER BY frequency ASC) AS frequency_score,             
        PERCENT_RANK() OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_rfm es
)
SELECT 
    es."Customer ID", 
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total_score  
FROM rfm_scores es
ORDER BY rfm_total_score DESC;

-- 2a. Loyalty Change Transition count for Churn & Conversion Rates
WITH status_changes AS (
    SELECT 
        es."Customer ID",
        es."Purchase Date",
        es."Loyalty Member",
        LAG(es."Loyalty Member") OVER (PARTITION BY es."Customer ID" ORDER BY es."Purchase Date"
        ) AS prev_status
    FROM electronic_sales_sep2023_sep2024_cleaned es
),
transitions AS (
    SELECT 
        "Customer ID",
        prev_status,
        "Loyalty Member",
        CONCAT(prev_status, ' -> ', "Loyalty Member") AS transition
    FROM status_changes
    WHERE prev_status IS NOT NULL
)
SELECT 
    transition,
    COUNT(*) AS transition_count
FROM transitions
GROUP BY transition
ORDER BY transition_count DESC;

-- 2b. check of yes and no event counts for churn/conversion
WITH status_changes AS (
    SELECT 
        es."Customer ID",
        es."Purchase Date",
        es."Loyalty Member",
        LAG(es."Loyalty Member") OVER (
            PARTITION BY es."Customer ID" 
            ORDER BY es."Purchase Date"
        ) AS prev_status
    FROM electronic_sales_sep2023_sep2024_cleaned es
)
SELECT 
    COUNT(*) FILTER (WHERE prev_status = 'No' AND "Loyalty Member" = 'Yes') AS total_conversions,
    COUNT(*) FILTER (WHERE prev_status = 'Yes' AND "Loyalty Member" = 'No') AS total_churns,
    COUNT(*) FILTER (WHERE prev_status = 'Yes') AS total_yes_events,
    COUNT(*) FILTER (WHERE prev_status = 'No') AS total_no_events
FROM status_changes
WHERE prev_status IS NOT NULL;

-- 2c. Churn & Conversion Rates
WITH status_changes AS (
    SELECT 
        es."Customer ID",
        es."Purchase Date",
        es."Loyalty Member",
        LAG(es."Loyalty Member") OVER (
            PARTITION BY es."Customer ID" 
            ORDER BY es."Purchase Date"
        ) AS prev_status
    FROM electronic_sales_sep2023_sep2024_cleaned es
)
SELECT --count(*) returns integer, need to cast
    ROUND((COUNT(*) FILTER (WHERE prev_status = 'Yes' AND "Loyalty Member" = 'No')::NUMERIC / NULLIF(COUNT(*) FILTER (WHERE prev_status = 'Yes')::NUMERIC, 0) * 100), 2) AS "Churn Rate (%)", 
    ROUND((COUNT(*) FILTER (WHERE prev_status = 'No' AND "Loyalty Member" = 'Yes')::NUMERIC / NULLIF(COUNT(*) FILTER (WHERE prev_status = 'No')::NUMERIC, 0) * 100), 2) AS "Conversion Rate (%)"
FROM status_changes
WHERE prev_status IS NOT NULL;
/* 
WITH status_changes AS (
    SELECT 
        es."Customer ID",
        es."Purchase Date",
        es."Loyalty Member",
        LAG(es."Loyalty Member") OVER (
            PARTITION BY es."Customer ID" 
            ORDER BY es."Purchase Date"
        ) AS prev_status
    FROM electronic_sales_sep2023_sep2024_cleaned es
),
transitions AS (
    SELECT 
        "Customer ID",
        prev_status,
        "Loyalty Member",
        CONCAT(prev_status, ' → ', "Loyalty Member") AS transition
    FROM status_changes
    WHERE prev_status IS NOT NULL
),
transition_counts AS (
    SELECT 
        COUNT(*) FILTER (WHERE transition = 'No → Yes') AS total_conversions,
        COUNT(*) FILTER (WHERE transition = 'Yes → No') AS total_churns,
        COUNT(*) FILTER (WHERE prev_status = 'Yes') AS total_yes_events,
        COUNT(*) FILTER (WHERE prev_status = 'No') AS total_no_events
    FROM transitions
)
SELECT 
    total_conversions,
    total_churns,
    (total_conversions::DECIMAL / total_no_events) * 100 AS conversion_rate,
    (total_churns::DECIMAL / total_yes_events) * 100 AS churn_rate
FROM transition_counts;
*/	--gives same output even though accounting for multiple transistions such AS NO-> YES-> NO

--			(Purchase Behavior)		

-- 1. Revenue by Payment Method

SELECT 
    UPPER(TRIM(es."Payment Method")) AS payment_method,
    COUNT(*) AS transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM electronic_sales_sep2023_sep2024_cleaned WHERE "Order Status" = 'Completed'), 2) AS percentage,
    ROUND(AVG(es."Total Price"), 2) AS average_order_value,
    ROUND(SUM(es."Total Price"), 2) AS total_revenue
FROM electronic_sales_sep2023_sep2024_cleaned es
WHERE es."Order Status" = 'Completed'
GROUP BY UPPER(TRIM(es."Payment Method"))
ORDER BY transaction_count DESC;

--			(Sales Trends)   											

-- 1. Monthly Overview
SELECT 
    TO_CHAR(es."Purchase Date", 'YYYY-MM') AS month,
    COUNT(*) AS order_count,
    SUM(es."Quantity") AS total_units,
    ROUND(SUM(es."Total Price"), 2) AS total_revenue,
    ROUND(AVG(es."Total Price"), 2) AS average_order_value
FROM electronic_sales_sep2023_sep2024_cleaned es
WHERE es."Order Status" = 'Completed'
GROUP BY TO_CHAR(es."Purchase Date", 'YYYY-MM')
ORDER BY month;

--2. Shipping Method
SELECT 
    es."Shipping Type",
    COUNT(DISTINCT es."Customer ID") AS unique_customers,
    ROUND(SUM(es."Quantity") / COUNT(*), 2) AS avg_quantity_per_shipment,
    ROUND(SUM(es."Quantity" * es."Unit Price") / COUNT(*), 2) AS avg_revenue_per_shipment
FROM electronic_sales_sep2023_sep2024_cleaned es
WHERE es."Order Status" = 'Completed'
GROUP BY es."Shipping Type"
ORDER BY avg_revenue_per_shipment DESC;

--			(Addons)																		

-- 1. Addon attach rate
SELECT 
    es."Product Type",
    COUNT(*) AS total_orders,
    SUM(es."Extended Warranty") AS warranty_count,
    ROUND(SUM(es."Extended Warranty") * 100.0 / COUNT(*), 2) AS warranty_attach_rate,
    SUM(es."Accessory") AS accessories_count,
    ROUND(SUM(es."Accessory") * 100.0 / COUNT(*), 2) AS accessories_attach_rate,
    SUM(es."Impulse") AS impulse_items_count,
    ROUND(SUM(es."Impulse") * 100.0 / COUNT(*), 2) AS impulse_items_attach_rate,
    ROUND(AVG(es."Add-on Total"), 2) AS average_addon_value
FROM electronic_sales_sep2023_sep2024_cleaned es
WHERE es."Order Status" = 'Completed'
GROUP BY es."Product Type"
ORDER BY average_addon_value DESC;


