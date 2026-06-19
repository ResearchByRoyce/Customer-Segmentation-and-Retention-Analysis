# 📊 Customer-Segmentation-and-Retention-Analysis

This project analyzes ecommerce customer behavior using PostgreSQL. It shows how to clean customer transaction data, create customer-level summaries, segment customers with SQL logic, and generate useful business insights for CRM, marketing, growth, and retention teams.

## 🧾 Project Overview

The objective of this project is to understand customer purchasing behavior using recency, frequency, and monetary analysis. SQL is used to clean the dataset, calculate customer-level metrics, create customer segments, and answer business questions related to loyalty, retention, and customer value.

## 🛠️ Tools Used

**PostgreSQL** — For querying, cleaning, aggregation, segmentation, and KPI extraction  
👉 SQL Code

**pgAdmin** — For running SQL scripts and viewing query results  
👉 Query Results

**Excel / CSV** — Raw dataset in spreadsheet format  
👉 Dataset File

## 📂 Dataset Description

Dataset: [Kaggle Ecommerce Data / Online Retail](https://www.kaggle.com/datasets/carrie1/ecommerce-data)

The dataset contains ecommerce transaction data from an online retail business. Each row represents a purchased product and includes invoice, product, quantity, date, price, customer, and country information.

| Column Name | Description |
| --- | --- |
| `invoice_no` | Unique invoice number for each transaction |
| `stock_code` | Product stock code |
| `description` | Product description |
| `quantity` | Number of units purchased |
| `invoice_date` | Date and time of the invoice |
| `unit_price` | Price per unit |
| `customer_id` | Unique customer identifier |
| `country` | Customer country |

## ❓ Questions Answered Using SQL

### ✅ Basic Queries:

- Total customers, invoices, quantity sold, and revenue
- First and latest invoice date
- Revenue by country
- Top customers by total spending
- Most purchased products
- Customers who ordered only once

### 🔁 Intermediate Queries:

- Customer-level aggregation
- Recency, frequency, and monetary analysis
- Repeat purchase analysis
- Inactive customer analysis
- Revenue by customer segment
- Customer order history

### 🔍 Advanced Queries:

- Customer segmentation using `CASE WHEN`
- Customer ranking using `RANK()` and `DENSE_RANK()`
- Customer percentile grouping using `NTILE()`
- Customer order sequence using `ROW_NUMBER()`
- Previous order comparison using `LAG()`
- At-risk customer identification using recency logic

## 👥 Segments Created

- Best Customers
- High Value Loyal
- High Value
- Loyal
- Occasional
- At Risk
- At Risk High Value
- Inactive

## 📈 Key Insights

- 💰 Best customers bring high revenue and purchase frequently.
- 🔁 Loyal customers are valuable because they continue buying over time.
- 📉 Inactive customers may need re-engagement campaigns.
- ⚠️ At-risk high-value customers should be monitored before they fully churn.
- 🛒 Occasional customers may be encouraged with second-purchase offers.
- 🌍 Country-level revenue helps identify stronger customer markets.
- 📦 Product purchase patterns can support marketing and inventory decisions.

## ✅ SQL Analysis Highlights

- Customer summary table with total orders, quantity, revenue, and last purchase date
- RFM-style customer analysis using recency, frequency, and monetary value
- Customer segmentation using simple business rules
- Window functions for ranking and customer order history
- Inactive customer analysis for retention planning
- Business recommendations based on customer behavior

## 📂 Main Tables Created

| Table Name | Purpose |
| --- | --- |
| `online_retail` | Raw imported ecommerce dataset |
| `cleaned_online_retail` | Cleaned transaction data |
| `customer_summary` | Customer-level revenue and purchase summary |
| `customer_rfm` | Recency, frequency, and monetary metrics |
| `customer_segments` | Final customer segment labels |
| `customer_segments_percentile` | Customer percentile grouping |
| `customer_order_history` | Customer order sequence and previous order comparison |

## 💡 Business Recommendations

- Reward loyal and best customers with VIP offers.
- Target inactive customers with re-engagement campaigns.
- Focus marketing on high-spending repeat buyers.
- Create second-purchase campaigns for occasional customers.
- Monitor at-risk high-value customers before they fully churn.

## 🧾 Resume Bullet

**Customer Segmentation & Retention Analysis | SQL**  
Developed SQL-based customer segmentation using purchase frequency, spending behavior, and recency metrics. Built customer summary tables and used `CASE WHEN` logic and window functions to identify loyal, high-value, and at-risk customer groups for targeted business action.

## 🏁 Conclusion

This project demonstrates how SQL can be used to turn raw ecommerce transactions into customer-level business insights. It highlights customer value, loyalty, inactivity, and retention opportunities, making it useful for marketing strategy, CRM planning, and business decision-making.
