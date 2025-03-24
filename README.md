--- SQL CLEANING & ANALYSIS -> [ Electronic_Sales_SQL_Markdown ](https://github.com/AndyeliSays/Electronic-Sales/blob/main/electronic_sales_SQLmarkdown.md)

--- TABLEAU DASHBOARD ->

<img src=https://github.com/AndyeliSays/Electronic-Sales/blob/main/assets/Electronic_sales_dashboard1_overview.png>

<img src=https://github.com/AndyeliSays/Electronic-Sales/blob/main/assets/Electronic_sales_dashboard2_customer_rfm.png>

<h1 align="center">Electronic Sales</h1>

## Introduction:
  
Our business wants to leverage electronic sales data to identify untapped opportunities for growth. This projects transform raw electronic sales data into actionable insights to make data-driven decisions. By analyzing sales patterns, customer behaviors, and market trends, we aim to achieve the following objectives:
- Enhancing Sales Performance: Pinpoint areas for improvement in our sales processes.
- Optimizing Revenue Streams: Find trends, cross-selling opportunities, and product performance metrics to refine pricing strategies.
- Customer Experience: Identify preferences and behaviors to personalize experiences and maintain customer membership.

## Business Task & Objectives: 
  
Key metrics such as sales patterns, customer demographics, loyalty membership impact, and add-on performance will be explored to provide a comprehensive understanding of retail operations. Some examples of questions, topics addressed but not limited to:
- What are the key revenue metrics and overall sales performance?
- RFM analysis to identify high-value customers.
- What's the impact of loyalty membership on sales and customer retention?
- How do add-ons like warranties, accessories, and impulse purchases affect revenue?
- What are the monthly sales trends and seasonal patterns?
- How do customer demographics impact purchasing behavior?
- Which payment and shipping methods are most popular and profitable?

The dataset contains electronic sales data spanning September 2023 to September 2024 and includes information about customers, purchases, products, and loyalty membership.
- Cleaning Process and Dataset Breakdown:

<img src=https://github.com/AndyeliSays/Electronic-Sales/blob/main/assets/electronicsales_cleaning.png>

## Tools:
- Data cleaning, preparation, analysis done in POWERQUERY & SQL.
- Data visualizations made in TABLEAU.

## Data Source: 
[Electronic Sales Dataset](https://www.kaggle.com/datasets/cameronseamons/electronic-sales-sep2023-sep2024/data)

---

<h1 align="center">Insights</h1>

## Sales & Revenue Performance
- Total revenue generated is approximately ($63.6 million) with a net revenue of ($42.6 million) from completed orders (109,711 units sold).
- Sales performance significantly improves during the winter months, peaking in January 2024, with the highest total revenue of ($4,516,277.41), and the highest number of orders (1,399). 
    - This suggests a strong seasonal demand, possibly influenced by holiday shopping.
- The average order value (AOV) is highest in June 2024 ($3,310.60) and lowest in September 2023 ($2,287.39). 
    - There seems to be a steady growth in AOV, order count and total units over time suggesting customers are spending more per order. 
- A decline in performance is noticeable from July to September 2024.

## Customer Demographics & Behavior
- Customer base is relatively balanced between genders with (10,165) male customers and (9,835) female customers.
- Seniors age group have the highest average spend amongst non-loyalty members. Specifically Senior Male (non-loyalty Members) with an average spend ($3,186.33).
- Senior and Middle Age groups have the highest customer counts, espeically for non-loyalty members.
    - There seems to be a trend with Age, as Age increases, so do customer counts.
- Young Adults have significantly fewer customers (138 males) but the highest average spending amonst Loyalty Members ($3,344.02). 
- While satisfaction rating hovers around a little over (3/5) across the board for all groups, females tend to have slightly lower satisfaction ratings, especially non-loyalty members.
- Loyalty members generally have higher satisfaction scores across all age segments, though spending varies. 

## Loyalty Program
- Only (21.72%) of customers are loyalty members.
- Average transaction value across all months for Non-Loyalty Members is ($3189.79) compared to ($3115.93) of Loyalty Members.
- Out of (12,136) total customers, (1,328) signed up for loyalty programs, while (1,354) customers cancelled their memberships.
- Loyalty members have a slightly higher average addon value ($62.74) compared to non-loyalty members ($62.06). 
    - This suggests that loyalty members are more likely to purchase addons, even if their overall AOV is lower.

## Payment & Shipping
- PayPal has the most (3,863) transactions (29.03%) and total revenue of ($12,579,687.13).
- Bank Transfer has a significant share with (2,259) transactions (16.82%) and total revenue of ($8,450,692.44).
- Cash transactions are relatively low in volume (1,727, 12.86%) and have the lowest average order value ($2,543.44).
- Standard Shipping has the highest number of unique customers (4,053), making it the most widely used shipping type. 
    - This suggests it aligns best with customer preferences for cost-effectiveness or accessibility.
- Expedited Shipping and Same-Day Shipping are nearly tied in popularity, with (1,971) and (1,935) unique customers. Expedited Shipping generates the highest average revenue per shipment at ($3,814.65), followed closely by Same-Day Shipping with ($3,791.67). 
- Although faster delivery, Overnight Shipping generates an average revenue of ($2,620.26), which is relatively low compared to expedited options.

## Product & Add-on
- Smartphones lead in total revenue ($21,516,755) and most orders (4,004) and impulse items bought and warranty count.
- Smartwatches generate ($14,036,273) in revenue with balanced add-on distribution but have the lowest accessories attach rate (48.37%).
- Laptops contribute ($12,296,240) with the strongest performance in accessory attach rates (50.22%).
- Headphones show the lowest revenue ($4,041,400) and lowest order count (1,361) but still have strong gross add-on performance (1,016 Accessories, 1,068 Impulse items). They also have the highest impulse items attach rate (52.83%) and highest warranty attach rate (51.58%).
- SMP234 stands out with the highest revenue at ($8,418,816) and a strong number of addons (110,261).       
    - This SKU is likely a key revenue driver and should be prioritized in marketing, inventory, and sales strategies.
- SKU1001 performs the worst by far with a revenue of $148,694. 
    - Further investigation is needed for this particular product to understand its performance compared to other products.
- Certain SKUs, like HDP456 and LTP123, have a high number of addons (112,721 and 113,557, respectively) relative to their revenue.
    - This suggests strong customer engagement with add-ons for these products, possibly indicating an opportunity for bundle deals or upselling strategies.

## RFM Analysis
*There is a positive correlation between RFM total score and Revenue.*

- The amount spent per customer ranges from ($21) to upwards of ($29,938).
- **Recency Score:** The majority of customers have a score of 2, 3, 4. These customers also show higher revenue totals. 
- **Frequency Score:** The majority of customers have a frequency score of 3, 2, 1. Customers with a frequency score of 3 and 2 have the highest revenue totals.
- **Monetary Score:** The highest concentration of data points is at Monetary Score of 2, covering a wide range of revenue values, approximately ($12,000) to ($26,000).
  - No Customers have a monetary score of 3 or 4.
  - Customers at Monetary score 1 mostly generate revenues below $6,000, making them the lowest-performing group.
  - Though fewer in number, Monetary score 5 contains customers generating significant revenue values, peaking around ($22,000).
- **RFM total:** Aside from some outliters geenrating high revenue values with moderate RFM scores, as RFM total score increases so does revenue. 
    - The scatter plot shows a dense cluster of customers with RFM Total scores between 4 and 8, contributing variable revenue from $5,000 to $15,000. 
        - This suggests most customers fall into this range and are likely mid-tier in terms of engagement and spending. 
    - Customers with RFM Total scores below 4 consistently generate lower revenue, ranging from $2,000 to $6,000. These are likely at-risk customers who may churn if not re-engaged.
    - Among high RFM scores (9–13), revenue varies significantly from $7,000 to $30,000. 

<h1 align="center">Recommendations </h1>

## 1. Customers
- Increase loyalty program membership from the current 21.72% by:
    - Focusing on converting high-spending segments (e.g., Senior Males).
    - Design segment-specific loyalty offers based on RFM analysis or churned loyalty members.

- Develop targeted marketing strategies for Senior and Middle Age customer segments.
- Develop targeted marketing strategies for young Males who consistently have higher average spending, regardless of loyalty membership indicating that male customers are more likely to spend on higher-ticket items or larger orders.
- Address satisfaction issues, particularly for female non-loyalty members.

- RFM-based
    - Recency score 2, 3, and 4 customers are the most promising segments for driving business growth. These customers are actively purchasing and producing the highest revenue. Concentrating marketing and retention efforts here could maximize ROI.
    - Leverage Frequency score 2 customers' engagement and revenue peaks to scale repeat purchases.
    - Prioritize Monetary score 2 customers, the backbone of revenue, with tailored strategies to maintain their revenue. 
    - Target RFM Total scores 4-8 customers for retention and growth efforts, as they form the majority.
    - Investigate outliers to understand their purchasing behaviors and replicate successful patterns with other customers because they contribute significantly to revenue.
    - Address disengagement among customers with high Recency but low Frequency and Monetary scores through reactivation campaigns.


## 2. Products
- Focus on top-performing SKUs (SMP234, TBL345, SKU1003).
- Further research is needed for severely underperforming (SKU1001) compared to other products.
- Create bundled offerings for Smartphones with popular accessories to leverage their high sales volume.
- Explore bundle deals for SKUs with high add-on potential. (HDP456, LTP123).
- Look into warranty programs for Headphones, which show strong warranty attachment potential.

## 3. Operations
- Optimize inventory and promotions for peak months (January and April).
- Implement targeted promotions during off-peak months (July-September).
- Consider incentives for higher-value payment methods like Bank Transfer and Credit Card to shift traffic from lower AOV methods.
- Promote Expedited and Same-Day Shipping options & investigate pricing and operational costs for Express and Overnight Shipping.
