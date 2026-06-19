
CREATE TABLE IF NOT EXISTS public.online_retail (
    invoiceno VARCHAR(20),
    stockcode VARCHAR(20),
    description TEXT,
    quantity INTEGER,
    invoicedate TIMESTAMP,
    unitprice NUMERIC(10, 2),
    customerid INTEGER,
    country VARCHAR(100)
);

-- Check imported data after loading the CSV.
SELECT *
FROM online_retail
LIMIT 10;


-- Milestone 1: Clean the Data

DROP TABLE IF EXISTS cleaned_online_retail;

CREATE TABLE cleaned_online_retail AS
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    invoice_date::date AS order_date,
    unit_price,
    customer_id,
    country,
    ROUND(quantity * unit_price, 2) AS revenue
FROM online_retail
WHERE customer_id IS NOT NULL
  AND invoice_no IS NOT NULL
  AND invoice_date IS NOT NULL
  AND quantity > 0
  AND unit_price > 0
  AND invoice_no NOT ILIKE 'C%';

SELECT *
FROM cleaned_online_retail
LIMIT 10;

-- Milestone 2: Build Customer Summary Table

DROP TABLE IF EXISTS customer_summary;

CREATE TABLE customer_summary AS
WITH order_level AS (
    SELECT
        customer_id,
        invoice_no,
        MIN(order_date) AS order_date,
        COUNT(*) AS line_items,
        SUM(quantity) AS total_quantity,
        SUM(revenue) AS order_revenue
    FROM cleaned_online_retail
    GROUP BY customer_id, invoice_no
)
SELECT
    customer_id,
    MIN(order_date) AS first_purchase_date,
    MAX(order_date) AS last_purchase_date,
    COUNT(*) AS total_orders,
    SUM(total_quantity) AS total_quantity,
    ROUND(SUM(order_revenue), 2) AS total_spend,
    ROUND(AVG(order_revenue), 2) AS avg_order_value,
    COUNT(DISTINCT invoice_no) AS unique_orders,
    SUM(line_items) AS total_line_items
FROM order_level
GROUP BY customer_id;

SELECT *
FROM customer_summary
ORDER BY total_spend DESC
LIMIT 20;


-- Milestone 3: Add Recency, Frequency, and Monetary Metrics

DROP TABLE IF EXISTS customer_rfm;

CREATE TABLE customer_rfm AS
WITH max_date AS (
    SELECT MAX(order_date) AS analysis_date
    FROM cleaned_online_retail
)
SELECT
    cs.customer_id,
    cs.first_purchase_date,
    cs.last_purchase_date,
    md.analysis_date - cs.last_purchase_date AS recency_days,
    cs.total_orders AS frequency,
    cs.total_spend AS monetary_value,
    cs.avg_order_value,
    cs.total_quantity,
    cs.total_line_items,
    md.analysis_date
FROM customer_summary cs
CROSS JOIN max_date md;

SELECT
    MIN(recency_days) AS min_recency,
    MAX(recency_days) AS max_recency,
    ROUND(AVG(recency_days), 2) AS avg_recency,
    MIN(frequency) AS min_frequency,
    MAX(frequency) AS max_frequency,
    ROUND(AVG(frequency), 2) AS avg_frequency,
    MIN(monetary_value) AS min_spend,
    MAX(monetary_value) AS max_spend,
    ROUND(AVG(monetary_value), 2) AS avg_spend
FROM customer_rfm;

-- Milestone 4: Create Customer Segments

DROP TABLE IF EXISTS customer_segments;

CREATE TABLE customer_segments AS
SELECT
    customer_id,
    first_purchase_date,
    last_purchase_date,
    recency_days,
    frequency,
    monetary_value,
    avg_order_value,
    total_quantity,
    total_line_items,
    analysis_date,
    CASE
        WHEN recency_days <= 60
             AND frequency >= 5
             AND monetary_value >= 1000
            THEN 'High Value Loyal'

        WHEN recency_days <= 90
             AND monetary_value >= 1000
            THEN 'High Value'

        WHEN recency_days <= 90
             AND frequency >= 3
            THEN 'Loyal'

        WHEN recency_days <= 90
             AND frequency BETWEEN 1 AND 2
            THEN 'Occasional'

        WHEN recency_days BETWEEN 91 AND 180
            THEN 'At Risk'

        WHEN recency_days > 180
            THEN 'Inactive'

        ELSE 'Other'
    END AS customer_segment
FROM customer_rfm;

SELECT
	avg_order_value,
    total_quantity,
    total_line_items,
    analysis_date,
    CASE
        WHEN recency_days <= 60
             AND frequency >= 5
             AND monetary_value >= 1000
            THEN 'High Value Loyal'

        WHEN recency_days <= 90
             AND monetary_value >= 1000
            THEN 'High Value'

        WHEN recency_days <= 90
             AND frequency >= 3
            THEN 'Loyal'

        WHEN recency_days <= 90
             AND frequency BETWEEN 1 AND 2
            THEN 'Occasional'

        WHEN recency_days BETWEEN 91 AND 180
            THEN 'At Risk'

        WHEN recency_days > 180
            THEN 'Inactive'

        ELSE 'Other'
    END AS customer_segment
FROM customer_rfm;

SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(monetary_value) AS total_revenue,
    ROUND(AVG(monetary_value), 2) AS avg_revenue_per_customer
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- ============================================================
-- Milestone 5: Segmentation Using Percentiles
-- ============================================================

DROP TABLE IF EXISTS customer_segments_percentile;

CREATE TABLE customer_segments_percentile AS
WITH rfm_scores AS (
    SELECT
        *,
        NTILE(4) OVER (ORDER BY recency_days ASC) AS recency_score,
        NTILE(4) OVER (ORDER BY frequency DESC) AS frequency_score,
        NTILE(4) OVER (ORDER BY monetary_value DESC) AS monetary_score
    FROM customer_rfm
)
SELECT
    customer_id,
    first_purchase_date,
    last_purchase_date,
    recency_days,
    frequency,
    monetary_value,
    avg_order_value,
    total_quantity,
    total_line_items,
    analysis_date,
    recency_score,
    frequency_score,
    monetary_score,
    CASE
        WHEN recency_score = 1
             AND frequency_score = 1
             AND monetary_score = 1
            THEN 'Best Customers'

        WHEN recency_score <= 2
             AND frequency_score <= 2
             AND monetary_score <= 2
            THEN 'High Value Loyal'

        WHEN recency_score <= 2
             AND monetary_score <= 2
            THEN 'High Value'

        WHEN recency_score <= 2
             AND frequency_score <= 2
            THEN 'Loyal'

        WHEN recency_score >= 3
             AND monetary_score <= 2
            THEN 'At Risk High Value'

        WHEN recency_score = 4
            THEN 'Inactive'

        ELSE 'Occasional'
    END AS customer_segment
FROM rfm_scores;

SELECT *
FROM customer_segments_percentile
LIMIT 20;



-- Question 1: Who are the top customers?
SELECT
    customer_id,
    frequency,
    monetary_value,
    avg_order_value,
    recency_days,
    customer_segment
FROM customer_segments_percentile
ORDER BY monetary_value DESC
LIMIT 10;

-- Question 2: Which customers are inactive?
SELECT
    customer_id,
    last_purchase_date,
    recency_days,
    frequency,
    monetary_value,
    customer_segment
FROM customer_segments_percentile
WHERE customer_segment = 'Inactive'
ORDER BY monetary_value DESC;

-- Question 3: Which customers buy frequently?
SELECT
    customer_id,
    frequency,
    monetary_value,
    avg_order_value,
    recency_days,
    customer_segment
FROM customer_segments_percentile
ORDER BY frequency DESC, monetary_value DESC
LIMIT 20;

-- Question 4: Which customer segment brings the most revenue?
SELECT
    customer_segment,
    COUNT(*) AS number_of_customers,
    SUM(monetary_value) AS total_revenue,
    ROUND(AVG(monetary_value), 2) AS avg_revenue_per_customer
FROM customer_segments_percentile
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Question 5: Which customers may need re-engagement?
SELECT
    customer_id,
    last_purchase_date,
    recency_days,
    frequency,
    monetary_value,
    customer_segment
FROM customer_segments_percentile
WHERE customer_segment IN ('Inactive', 'At Risk High Value')
ORDER BY monetary_value DESC;


-- Customers with declining activity:
-- compares the most recent 90 days to the 90 days before that.
WITH customer_activity_windows AS (
    SELECT
        c.customer_id,
        COUNT(DISTINCT c.invoice_no) FILTER (
            WHERE c.order_date >= m.analysis_date - INTERVAL '90 days'
        ) AS recent_orders,
        COUNT(DISTINCT c.invoice_no) FILTER (
            WHERE c.order_date >= m.analysis_date - INTERVAL '180 days'
              AND c.order_date < m.analysis_date - INTERVAL '90 days'
        ) AS previous_orders,
        SUM(c.revenue) FILTER (
            WHERE c.order_date >= m.analysis_date - INTERVAL '90 days'
        ) AS recent_revenue,
        SUM(c.revenue) FILTER (
            WHERE c.order_date >= m.analysis_date - INTERVAL '180 days'
              AND c.order_date < m.analysis_date - INTERVAL '90 days'
        ) AS previous_revenue
    FROM cleaned_online_retail c
    CROSS JOIN (
        SELECT MAX(order_date) AS analysis_date
        FROM cleaned_online_retail
    ) m
    GROUP BY c.customer_id
)
SELECT
    s.customer_id,
    s.customer_segment,
    s.monetary_value,
    s.recency_days,
    a.previous_orders,
    a.recent_orders,
    COALESCE(a.previous_revenue, 0) AS previous_revenue,
    COALESCE(a.recent_revenue, 0) AS recent_revenue
FROM customer_activity_windows a
JOIN customer_segments_percentile s
    ON a.customer_id = s.customer_id
WHERE a.previous_orders > 0
  AND a.recent_orders < a.previous_orders
ORDER BY s.monetary_value DESC;

-- ============================================================
-- Window Function Analysis
-- ============================================================

DROP TABLE IF EXISTS customer_order_history;

CREATE TABLE customer_order_history AS
WITH order_level AS (
    SELECT
        customer_id,
        invoice_no,
        MIN(order_date) AS order_date,
        SUM(revenue) AS order_revenue
    FROM cleaned_online_retail
    GROUP BY customer_id, invoice_no
)
SELECT
    customer_id,
    invoice_no,
    order_date,
    order_revenue,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date, invoice_no
    ) AS purchase_number,
    LAG(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, invoice_no
    ) AS previous_order_date,
    LAG(order_revenue) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, invoice_no
    ) AS previous_order_revenue
FROM order_level;

-- ROW_NUMBER: Top customer by country
WITH country_customer_revenue AS (
    SELECT
        country,
        customer_id,
        SUM(revenue) AS total_revenue
    FROM cleaned_online_retail
    GROUP BY country, customer_id
),
ranked_customers AS (
    SELECT
        country,
        customer_id,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY country
            ORDER BY total_revenue DESC
        ) AS country_rank
    FROM country_customer_revenue
)
SELECT
    country,
    customer_id,
    total_revenue
FROM ranked_customers
WHERE country_rank = 1
ORDER BY total_revenue DESC;

-- RANK: Overall customer revenue ranking
SELECT
    customer_id,
    monetary_value,
    RANK() OVER (
        ORDER BY monetary_value DESC
    ) AS revenue_rank
FROM customer_segments_percentile
ORDER BY revenue_rank
LIMIT 25;

-- DENSE_RANK: Product revenue ranking
SELECT
    stock_code,
    description,
    SUM(revenue) AS product_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(revenue) DESC
    ) AS product_rank
FROM cleaned_online_retail
GROUP BY stock_code, description
ORDER BY product_rank
LIMIT 25;

-- NTILE: Customer spending quartiles
SELECT
    customer_id,
    monetary_value,
    NTILE(4) OVER (
        ORDER BY monetary_value DESC
    ) AS spending_quartile
FROM customer_rfm;

-- LAG: Customers with declining order value
SELECT
    customer_id,
    invoice_no,
    order_date,
    purchase_number,
    order_revenue,
    previous_order_revenue,
    order_revenue - previous_order_revenue AS order_value_change
FROM customer_order_history
WHERE previous_order_revenue IS NOT NULL
  AND order_revenue < previous_order_revenue
ORDER BY order_value_change ASC;

-- Business Recommendations

-- Reward loyal and best customers
SELECT
    customer_id,
    customer_segment,
    frequency,
    monetary_value,
    recency_days,
    'Reward with VIP offers, referral incentives, or early product access.' AS recommendation
FROM customer_segments_percentile
WHERE customer_segment IN ('Best Customers', 'High Value Loyal', 'Loyal')
ORDER BY monetary_value DESC;

-- Target inactive customers
SELECT
    customer_id,
    customer_segment,
    last_purchase_date,
    recency_days,
    frequency,
    monetary_value,
    'Send a re-engagement campaign or win-back discount.' AS recommendation
FROM customer_segments_percentile
WHERE customer_segment IN ('Inactive', 'At Risk High Value')
ORDER BY monetary_value DESC;

-- Focus on high-spending repeat buyers
SELECT
    customer_id,
    customer_segment,
    frequency,
    monetary_value,
    avg_order_value,
    recency_days,
    'Prioritize with premium bundles, cross-sell offers, and retention messaging.' AS recommendation
FROM customer_segments_percentile
WHERE frequency > 1
  AND monetary_score <= 2
ORDER BY monetary_value DESC;

-- Segment-level action plan
SELECT
    customer_segment,
    COUNT(*) AS customers,
    SUM(monetary_value) AS total_revenue,
    ROUND(AVG(monetary_value), 2) AS avg_customer_value,
    ROUND(AVG(frequency), 2) AS avg_purchase_frequency,
    ROUND(AVG(recency_days), 2) AS avg_recency_days,
    CASE
        WHEN customer_segment IN ('Best Customers', 'High Value Loyal')
            THEN 'Protect these customers with loyalty rewards and exclusive offers.'

        WHEN customer_segment = 'High Value'
            THEN 'Encourage repeat purchases with personalized recommendations.'

        WHEN customer_segment = 'Loyal'
            THEN 'Reward loyalty and invite referrals.'

        WHEN customer_segment = 'At Risk High Value'
            THEN 'Use urgent win-back campaigns because spend potential is high.'

        WHEN customer_segment = 'Inactive'
            THEN 'Test low-cost reactivation or suppress from expensive campaigns.'

        ELSE 'Use nurture campaigns to encourage the next purchase.'
    END AS business_action
FROM customer_segments_percentile
GROUP BY customer_segment
ORDER BY total_revenue DESC;