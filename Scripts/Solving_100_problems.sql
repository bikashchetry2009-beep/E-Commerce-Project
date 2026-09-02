--Here I will try to solve 100 busieness questions from basic to advance



USE e_commerce;
--1. Find the total revenue generated from all delivered orders.
SELECT  
		SUM(total_amount) AS total_revenue

FROM bronze.orders
WHERE order_status='Delivered';

--2. Find the top 10 customers by total spending.
SELECT	TOP 10
		c.customer_id,
		c.customer_name,
		SUM(total_amount) AS total_spending
FROM bronze.customers AS c
LEFT JOIN bronze.orders AS o
ON c.customer_id=o.customer_id
GROUP BY c.customer_id,
		c.customer_name
ORDER BY SUM(total_amount) DESC;

--3. Find customers who have placed more orders than the average customer.


--process1

WITH customer_order AS
(
SELECT  customer_id AS customer_id,
		COUNT(order_id) AS total_orders
FROM bronze.orders
GROUP BY customer_id

)
,avg_orders AS
(
SELECT  customer_id,
		total_orders,
		AVG(total_orders) OVER() AS avg_orders
FROM customer_order
)
SELECT * 
FROM avg_orders	
WHERE total_orders>avg_orders;

GO 

--process 2
WITH customer_orders AS
(
SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM bronze.orders
    GROUP BY customer_id
)
SELECT *
FROM customer_orders
WHERE order_count >
      (SELECT AVG(order_count)
       FROM customer_orders);

--4. Find the highest-value order for every customer.
--process1
SELECT  customer_id,
		MAX(total_amount)  AS highest_value
FROM bronze.orders
GROUP BY customer_id
ORDER BY customer_id asc;


--process2
WITH ranking as
(
SELECT customer_id,
	   order_id,
	   total_amount,
	   ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY total_amount DESC) AS rn
FROM bronze.orders
)
SELECT customer_id,
		total_amount
FROM ranking
WHERE rn=1;

--5. Find the second-highest order value overall.
--process1
SELECT MAX(total_amount) AS second_highest_order
FROM bronze.orders
WHERE total_amount < (
    SELECT MAX(total_amount)
    FROM bronze.orders
);

--process2
WITH ranking_no AS
(
SELECT  total_amount,
		ROW_NUMBER() OVER(ORDER BY total_amount DESC) AS rn 
FROM bronze.orders
)
SELECT total_amount
FROM ranking_no
WHERE rn=2;

--6. Find the second-highest order for every customer.

WITH ranking AS
(
SELECT  customer_id,
		total_amount,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY total_amount DESC) AS rn
FROM bronze.orders
)
SELECT customer_id,
		total_amount
FROM ranking
WHERE rn=2 ;


--7. Find the top 3 customers in every state based on revenue.
WITH revenue AS
(

SELECT  shipping_state,
		customer_id,
		total_amount,
		SUM(total_amount) AS total_revenue 
FROM bronze.orders
GROUP BY 
		shipping_state,
		customer_id,
		total_amount
)
,ranking AS
(
SELECT  shipping_state,
		customer_id,
		total_revenue,
		DENSE_RANK() OVER(PARTITION BY shipping_state ORDER BY total_revenue DESC) AS rn
FROM revenue
)
SELECT shipping_state,
		customer_id,
		total_revenue
FROM ranking
WHERE rn<=3;


--8. Find customers who have never placed an order.
SELECT c.customer_id,
		c.customer_name
FROM bronze.customers  AS c
LEFT JOIN bronze.orders AS o
ON c.customer_id=o.customer_id
WHERE o.customer_id IS NULL;

--9. Find products that have never been sold.
SELECT  p.product_id,
		p.product_name
FROM bronze.products AS p
LEFT JOIN bronze.order_items AS oi
ON p.product_id=oi.product_id
WHERE oi.product_id IS NULL;

--10. Find sellers who have never sold a product.
SELECT  s.seller_id,
		s.seller_name
FROM bronze.sellers AS s
LEFT JOIN bronze.order_items AS oi
ON s.seller_id=oi.seller_id
WHERE oi.seller_id IS NULL;

--11. Find the best-selling product by quantity.

--PROCESS1
WITH product_qty AS
(
SELECT  p.product_id,
		p.product_name,
		SUM(oi.quantity) AS total_qty
FROM bronze.products AS p
JOIN BRONZE.order_items AS oi
ON p.product_id=oi.product_id
GROUP BY p.product_id,
		p.product_name
)
SELECT TOP 1
*
FROM product_qty
ORDER BY total_qty DESC;


--PROCESS2
SELECT TOP 1
		p.product_id,
		p.product_name,
		SUM(oi.quantity) AS total_qty
FROM bronze.products AS p
JOIN BRONZE.order_items AS oi
ON p.product_id=oi.product_id
GROUP BY p.product_id,
		p.product_name
ORDER BY total_qty DESC;



--12. Find the top 5 products in every category.
	
	--process1
	WITH details AS
	(
	SELECT  p.product_id,
			p.product_name,
			p.category_id,
			SUM(oi.quantity) AS total_sold
	FROM bronze.order_items AS oi
	JOIN bronze.products AS p
	ON oi.product_id=p.product_id
		GROUP BY p.product_id,
			p.product_name,
			p.category_id
	)

	SELECT  product_id,
			product_name,
			category_id,
			total_sold
	FROM
	(
	SELECT 
			*,
			DENSE_RANK() OVER(PARTITION BY category_id ORDER BY total_sold DESC) AS rn 
	FROM details) AS ranked
	WHERE rn<=5;

	--process2
	WITH details AS
	(
	SELECT  p.product_id,
			p.product_name,
			p.category_id,
			SUM(oi.quantity) AS total_sold
	FROM bronze.order_items AS oi
	JOIN bronze.products AS p
	ON oi.product_id=p.product_id
		GROUP BY p.product_id,
			p.product_name,
			p.category_id
	)
	, ranking AS
	(
		SELECT 
			*,
			DENSE_RANK() OVER(PARTITION BY category_id ORDER BY total_sold DESC) AS rn 
	FROM details
	
	)
	SELECT  product_id,
			product_name,
			category_id,
			total_sold
	FROM ranking
	WHERE rn<=5;


--13.Find the category generating the highest revenue.
WITH revenue AS
(

SELECT  p.category_id,
		SUM(total_amount) AS total_revenue
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY p.category_id
)
SELECT TOP 1
		category_id,
		total_revenue FROM revenue
		ORDER BY total_revenue  DESC;

--14. Find the highest-revenue seller.
SELECT  TOP 1
		oi.seller_id,
		SUM(o.total_amount) AS total_revenue
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
GROUP BY oi.seller_id
ORDER BY SUM(o.total_amount) DESC;



--15. Find the top 3 sellers in every state.
WITH total AS
(
SELECT  s.state,
		s.seller_id,
		s.seller_name,
		SUM(oi.line_total) AS total
FROM bronze.order_items AS oi
JOIN bronze.sellers AS s
ON oi.seller_id=s.seller_id
GROUP BY s.state,
		s.seller_id,
		s.seller_name
)
,ranking AS
(
SELECT  *,
		DENSE_RANK() OVER(PARTITION BY state ORDER BY total DESC) AS rn
FROM total
)
SELECT  state,
		seller_id,
		seller_name,
		total
FROM ranking 
WHERE rn<=3;

--16. Find average order value for each customer segment.

SELECT  c.customer_segment,
		ROUND(AVG(total_amount),2) AS avg_total
FROM bronze.customers AS c
JOIN bronze.orders AS o
ON c.customer_id=o.customer_id
GROUP BY c.customer_segment
ORDER BY ROUND(AVG(total_amount),2) DESC;

--17. Find customers whose total spending is above the average customer spending.
WITH total_spending_each_customer AS
(
SELECT  customer_id,
		SUM(total_amount) AS total_spending
FROM bronze.orders
GROUP BY customer_id

)
,average_spending_of_customers AS
(
SELECT  customer_id,
		total_spending,
		AVG(total_spending) OVER()AS avg_spending
FROM total_spending_each_customer

)
SELECT  customer_id,
		total_spending,
		ROUND(avg_spending,2) AS avg_spending
FROM average_spending_of_customers
WHERE total_spending>avg_spending
ORDER BY customer_id ASC;


--18. Find the average number of products per order.

WITH sum_count AS
(

SELECT  order_id,
		SUM(quantity) AS total_qty
FROM bronze.order_items
GROUP BY order_id

)
SELECT  order_id,
		total_qty,
		AVG(total_qty) OVER()AS products_per_order
FROM sum_count
;

--19. Find orders containing more than 5 different products.
SELECT  order_id,
		COUNT(DISTINCT(product_id)) AS total_products
FROM bronze.order_items
GROUP BY order_id
HAVING COUNT(DISTINCT(product_id))>5
ORDER BY order_id ASC;

/*
SELECT oi.order_id,    ---To see the which are in the total_products 
       COUNT(DISTINCT oi.product_id) AS total_products,
       STRING_AGG(CAST(oi.product_id AS VARCHAR), ',') 
           WITHIN GROUP (ORDER BY oi.product_id) AS product_list
FROM bronze.order_items AS oi
GROUP BY oi.order_id
HAVING COUNT(DISTINCT oi.product_id) > 5
ORDER BY oi.order_id ASC;
*/


--20. Find customers who purchased products from at least 5 categories Where status is 'delvered'.

WITH categories AS
(
SELECT  o.customer_id,
		COUNT(DISTINCT(p.category_id)) AS total_categories
FROM bronze.order_items AS oi
JOIN bronze.orders AS o
ON o.order_id=oi.order_id
JOIN bronze.products AS p
ON oi.product_id=p.product_id
WHERE o.order_status='Delivered'
GROUP BY o.customer_id

)
SELECT *
FROM categories
WHERE total_categories>=5
ORDER BY customer_id;

--21. Find the most expensive product in each category.
WITH ranking AS
(
SELECT  *,
		ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY selling_price DESC) AS rn
FROM bronze.products
)
SELECT *
FROM ranking	
WHERE rn=1;

--22. Find products priced above their category's average price.
--PROCESS 1
WITH avg_cat AS
(
SELECT  product_id,
		product_name,
		category_id,
		selling_price,
		AVG(selling_price) OVER(PARTITION BY category_id ORDER BY category_id ASC)AS avg_categories
FROM bronze.products
GROUP BY product_id,
		product_name,
		category_id,
		selling_price
)
SELECT *
FROM avg_cat
WHERE selling_price>avg_categories
ORDER BY product_id;

--PROCESS2
SELECT
    p.product_id,
    p.product_name,
    p.selling_price,
    p.category_id
FROM bronze.products p
WHERE p.selling_price >
(
    SELECT AVG(p2.selling_price)
    FROM bronze.products p2
    WHERE p2.category_id = p.category_id
);


SELECT
    p.product_id,
    p.product_name,
    p.selling_price,
    p.category_id
FROM bronze.products p
WHERE p.selling_price >
(
    SELECT AVG(p2.selling_price)
    FROM bronze.products p2
    WHERE p2.category_id = p.category_id
);


--23. Find the most popular payment method.

SELECT TOP 1
		payment_method,
		COUNT(transaction_id) AS total

FROM bronze.payments
GROUP BY payment_method
ORDER BY COUNT(transaction_id) DESC;


--24. Find monthly revenue.
SELECT  MONTH(order_date) AS month,
		SUM(total_amount) AS monthly_revenue
FROM bronze.orders
WHERE order_status='Delivered'
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);



--25. Find the highest-revenue month.

SELECT TOP 1
		MONTH(order_date) AS month,
		SUM(total_amount) AS monthly_revenue
FROM bronze.orders
WHERE order_status='Delivered'
GROUP BY MONTH(order_date)
ORDER BY SUM(total_amount);



/*LEVEL 2 — Very Advanced: Questions 26–50
============================================*/

--26. Calculate month-over-month revenue growth.

WITH next_month_revenue AS
(
SELECT  MONTH(order_date) AS month,
		ROUND(SUM(total_amount),2) AS this_month_revenue,
		LAG(ROUND(SUM(total_amount),2)) OVER (ORDER BY MONTH(order_date)) AS last_month_revenue
FROM bronze.orders 
WHERE order_status='Delivered'
GROUP BY MONTH(order_date)

)
SElECT  *,
		CAST(ROUND(((this_month_revenue-last_month_revenue)/NULLIF(last_month_revenue,0)*100),2)AS nvarchar)+' '+'%' AS growth_percentage
FROM next_month_revenue;


--27. Calculate cumulative revenue by month.
WITH total_revenue_monthly AS
(
SELECT  MONTH(order_date) AS month,
		SUM(total_amount) AS total_revenue 
FROM bronze.orders
WHERE order_status='Delivered'
GROUP BY MONTH(order_date) 
)
SELECT  *,
		SUM(total_revenue) OVER(ORDER BY month) AS cumulative_monthly_revenue
FROM total_revenue_monthly;

--28. Find each customer's first order.
--process1
SELECT  customer_id,
		MIN(order_date) AS first_order_date
FROM bronze.orders
GROUP BY customer_id
ORDER BY customer_id;

--process2
WITH ranking AS
(
SELECT customer_id,
		order_date AS first_order_date,
	   ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date)AS rn
FROM bronze.orders
)
SELECT  
		customer_id,
		first_order_date
FROM ranking 
WHERE rn=1;

--29. Find each customer's most recent order.
WITH ranking AS
(
SELECT  customer_id,
		order_date AS last_order_date,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS rn
FROM bronze.orders
)
SELECT customer_id,
		last_order_date
FROM ranking 
WHERE rn=1;

--30. Find customers who placed orders in both 2024 and 2025.


SELECT 
	customer_id
FROM bronze.orders
GROUP BY customer_id		
HAVING COUNT(DISTINCT(order_date))=2;

--31. Find customers who ordered in every month of 2025.

SELECT  customer_id
FROM bronze.orders
WHERE YEAR(order_id)=2025
GROUP BY customer_id
HAVING COUNT(DISTINCT(MONTH(order_date)))=12
;


--32. Find the longest gap between two orders for every customer.
WITH last_first_order AS
(
SELECT  customer_id,
		order_date,
		LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date) AS previous_order_date
FROM bronze.orders

)
SELECT  customer_id,
		MAX(DATEDIFF(MONTH,previous_order_date,order_date)) AS longest_gap
FROM last_first_order
GROUP  BY customer_id
ORDER BY customer_id;

--33. Find customers whose second order value is greater than their first order value.
WITH ranking AS
(
SELECT  customer_id,
		total_amount,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY total_amount) AS rn 
FROM bronze.orders
)
, total_amount_pivot AS
(
SELECT  customer_id,
		MAX(CASE
			WHEN rn=1 THEN total_amount
			END) AS first_order,
		MAX(CASE
			WHEN rn=2 THEN total_amount
			END) AS second_order
FROM ranking
GROUP BY customer_id
)
SELECT *
FROM total_amount_pivot
WHERE second_order>first_order;

--34. Find customers whose spending increased year-over-year.
WITH revenue AS
(
SELECT  customer_id,
		YEAR(order_date) AS year,
		SUM(total_amount) AS total_spend 
FROM bronze.orders
WHERE order_status='Delivered'
GROUP BY customer_id,
		YEAR(order_date)
)
,yoy AS
(
SELECT customer_id,
		year,
		total_spend,
		LAG(total_spend) OVER(PARTITION BY customer_id ORDER BY year) AS previos_year_spend
FROM revenue
)
SELECT customer_id,
		total_spend,
		previos_year_spend
FROM yoy
WHERE total_spend>previos_year_spend;


--35. Find the top 10% of customers by revenue..

WITH revenue AS
(
SELECT 
		customer_id,
		SUM(total_amount) AS revenue
FROM bronze.orders
WHERE order_status='Delivered'
GROUP BY customer_id
)
,distribute AS
(
SELECT  *,
		NTILE(10) OVER(ORDER BY revenue DESC) AS bucket
FROM revenue 
)
SELECT * 
FROM distribute
WHERE bucket=1;

--36. Calculate each category's percentage contribution to total revenue.
WITH cat_revenue AS
(
SELECT 
		p.category_id,
		SUM(line_total) AS revenue
FROM bronze.order_items AS oi 
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY p.category_id
)
,overall_revenue AS
(
SELECT  *,
		SUM(revenue) OVER() AS total_revenue
FROM cat_revenue
)
SELECT  *,
		ROUND((revenue/total_revenue)*100,2) AS contri_percent
FROM overall_revenue
ORDER BY category_id;		

--37. Find products responsible for the top 80% of revenue.
WITH revenue_product AS
(
SELECT  product_id,
		SUM(line_total) AS revenue
FROM bronze.order_items 
GROUP BY product_id
)
,cum_rev AS
(
SELECT  *,
		SUM(revenue) OVER(ORDER BY revenue DESC) AS cumulative_revenue,
		SUM(revenue) OVER() AS total_revenue
FROM revenue_product
)
SELECT *

FROM cum_rev
WHERE cumulative_revenue<=total_revenue*.80;


--38. Find the best-selling product for each seller.
WITH seller_product AS
(

SELECT  seller_id,
		product_id,
		SUM(quantity) AS total_sale
FROM bronze.order_items
GROUP BY seller_id,
		product_id
		

)
,ranking AS
(
SELECT  *,
		ROW_NUMBER() OVER(PARTITION BY seller_id ORDER BY total_sale DESC) AS rn
FROM  seller_product
)
SELECT
		seller_id,
		product_id,
		total_sale
FROM ranking
WHERE rn=1;

--39. Find sellers selling products in the largest number of categories.
SELECT  TOP 10
		oi.seller_id,
		COUNT(DISTINCT category_id) AS total_cat
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY oi.seller_id
ORDER BY total_cat DESC;

--40. Find customers who purchased from more than 3 sellers.
SELECT  o.customer_id,
		COUNT(DISTINCT(oi.seller_id)) AS total_seller
FROM bronze.order_items AS oi
JOIN bronze.orders AS o
ON oi.order_id=o.order_id
GROUP BY customer_id
HAVING COUNT(DISTINCT(seller_id))>3;

--41. Find the average discount by category.

SELECT  p.category_id,
		ROUND(AVG(oi.discount)*100,2) AS avg_disc_per 
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY  p.category_id
ORDER BY p.category_id;

--42. Find products with above-average sales but below-average price.
WITH units_sum AS
(

SELECT  p.product_id,
		p.product_name,
		p.selling_price,
		SUM(oi.quantity) AS units
		FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY p.product_id,
		p.product_name,
		p.selling_price
)
SELECT  *
FROM units_sum
WHERE units>(SELECT AVG(units) FROM units_sum)
AND
selling_price<(SELECT AVG(selling_price) FROM bronze.products);

--43. Find customers with exactly one order.
SELECT  customer_id,
		COUNT(customer_id) Total_orders
FROM bronze.orders
GROUP BY customer_id
HAVING COUNT(customer_id)=1
ORDER BY customer_id;

--44. Find repeat customers.
SELECT  customer_id,
		COUNT(customer_id) Total_orders
FROM bronze.orders
GROUP BY customer_id
HAVING COUNT(customer_id)>1
ORDER BY customer_id;

--45. Find the percentage of repeat customers.


WITH customer_orders AS 
(
    SELECT
        customer_id,
        COUNT(*) AS order_count
    FROM bronze.orders
    GROUP BY customer_id
)
SELECT
    CAST(
		ROUND(
		(SUM(CASE 
				WHEN order_count > 1 THEN 1 
				ELSE 0
			END)*1.0
			/ COUNT(*)) * 100,2)
			 AS DECIMAL(5,2))AS repeat_customer_percentage
FROM customer_orders;


--46. Find the average delivery time by shipping method.

SELECT  shipping_method,
		CAST(AVG(DATEDIFF(DAY,shipping_date,actual_delivery_date))AS VARCHAR)+' '+'days' AS avg_delivery_time
FROM bronze.shipments
WHERE actual_delivery_date IS NOT NULL
GROUP BY shipping_method;
			
--47. Find the percentage of delayed shipments.
WITH count_status AS
(
SELECT 
	COUNT(delivery_status) AS total_delayed
FROM bronze.shipments
WHERE delivery_status='Delayed'
)
SELECT 
		CAST(ROUND(total_delayed*1.0/(SELECT COUNT(*) FROM bronze.shipments)*100,2) AS DECIMAL(4,2)) AS delayed_percent
FROM count_status;

--48. Find sellers with a delivery delay rate above 10%.
--process1
WITH orders AS
(
SELECT  
	seller_id,
	COUNT(*) AS total_delivery
FROM bronze.shipments 
GROUP BY seller_id

)
,delayed AS
(
SELECT 
	seller_id,
	COUNT(*) AS total_delayed
FROM bronze.shipments
WHERE delivery_status='Delayed'
GROUP BY seller_id
)
SELECT o.seller_id,
		o.total_delivery,
		ISNULL(d.total_delayed,0) AS delayed_total,
		CAST(ISNULL(d.total_delayed,0)*1.0/o.total_delivery*100 AS DECIMAL(5,2)) AS delay_percent
FROM  orders As o
LEFT JOIN delayed AS d
ON o.seller_id=d.seller_id
WHERE CAST(ISNULL(d.total_delayed,0)*1.0/o.total_delivery*100 AS DECIMAL(5,2))>10
ORDER BY o.seller_id;


--process2
SELECT
    seller_id,
    ROUND(
        (SUM(CASE WHEN delivery_status = 'Delayed' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100,
        2
    ) AS delay_rate
FROM bronze.shipments
GROUP BY seller_id
HAVING (SUM(CASE WHEN delivery_status = 'Delayed' THEN 1 ELSE 0 END) * 1.0 / COUNT(*)) * 100 > 10
ORDER BY seller_id;

--49. Find the seller with the best average delivery time.
--process1
SELECT TOP 1
		seller_id,
		AVG(DATEDIFF(DAY,shipping_date,actual_delivery_date)) AS avg_days
FROM bronze.shipments
GROUP BY seller_id
ORDER BY avg_days DESC;


--process2
SELECT  TOP 1 s.seller_name,
    ROUND(
        AVG(DATEDIFF(DAY,sh.shipping_date,
            sh.actual_delivery_date
            
        )),2
    ) AS avg_delivery_days
FROM bronze.sellers s
JOIN bronze.shipments sh
    ON s.seller_id = sh.seller_id
WHERE sh.actual_delivery_date IS NOT NULL
GROUP BY s.seller_id, s.seller_name
ORDER BY avg_delivery_days DESC;

		


--process3
WITH duration AS
(
SELECT  seller_id,
		DATEDIFF(DAY,shipping_date,actual_delivery_date) delivery_duration
FROM bronze.shipments
WHERE delivery_status='Delivered'

)
,dt AS
(SELECT  seller_id,
		AVG(delivery_duration) AS avg_delivery_time,
		ROW_NUMBER() OVER(ORDER BY AVG(delivery_duration) DESC) AS rn
FROM duration
GROUP BY seller_id
)
SELECT  seller_id,
		avg_delivery_time
FROM dt
WHERE rn=1
;

--50. Rank sellers based on revenue.
--PROCESS1
SELECT  oi.seller_id,
		SUM(o.total_amount) AS revenue,
		ROW_NUMBER() OVER(ORDER BY SUM(o.total_amount)DESC) AS rn
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
GROUP BY oi.seller_id;


--PROCESS2
WITH revenue AS
(
SELECT  oi.seller_id,
		SUM(o.total_amount) AS revenue
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
GROUP BY oi.seller_id
)
SELECT 
	seller_id,
	revenue,
	DENSE_RANK() OVER(ORDER BY revenue DESC) AS revenue_rank
FROM revenue;

--🚨 LEVEL 3 — Expert SQL: Questions 51–75
--51. Find each customer's most purchased category.
WITH qty AS
(
SELECT  o.customer_id,
		p.category_id,
		SUM(oi.quantity) AS total_qty
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
JOIN bronze.products AS p
ON oi.product_id=P.product_id
GROUP BY o.customer_id,
		p.category_id

)
,ranking AS
(
SELECT  customer_id,
		category_id,
		total_qty,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY total_qty DESC) AS rn
FROM qty
)
SELECT  customer_id,
		category_id,
		total_qty
FROM ranking 
WHERE rn=1;

--52. Find customers who purchased the same product more than 3 times.

SELECT  o.customer_id,
		oi.product_id,
		COUNT(oi.product_id) AS  purchases
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
GROUP BY o.customer_id,
		oi.product_id
HAVING COUNT(oi.product_id)>3
ORDER BY o.customer_id


--53. Find products purchased by customers from at least 5 different states.
SELECT  
		oi.product_id,
		COUNT(DISTINCT c.state) AS total_state
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
JOIN bronze.customers AS c
ON o.customer_id=c.customer_id
GROUP BY oi.product_id
HAVING COUNT(DISTINCT c.state)>=5
ORDER BY oi.product_id


--54. Find customers who bought products from every department.
SELECT 
		o.customer_id
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
JOIN bronze.products AS p
ON oi.product_id=p.product_id
JOIN bronze.categories AS c
ON p.category_id=c.category_id
GROUP BY customer_id
HAVING COUNT(DISTINCT(c.department))=(SELECT 
											COUNT(DISTINCT department) 
									  FROM bronze.categories);

--55. Find the most profitable product.
SELECT  TOP 1 p.product_id,
		p.product_name,
		SUM((oi.unit_price-p.cost_price)*oi.quantity) AS total_profit
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY p.product_id,
		p.product_name
ORDER BY p.product_id DESC;

--56. Find the most profitable category.
SELECT TOP 1
		c.category_id,
		SUM((oi.unit_price-p.cost_price)*quantity) AS total_profit
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
JOIN bronze.categories AS c
ON p.category_id=c.category_id
GROUP BY c.category_id
ORDER BY total_profit DESC;

--57. Find products with negative profit.
SELECT  p.product_id,
		p.product_name,
		SUM((oi.unit_price-p.cost_price)*oi.quantity) AS total_profit
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY p.product_id
HAVING SUM((oi.unit_price-p.cost_price)*oi.quantity)<0;

--58. Find the most profitable seller.
SELECT  TOP  1
		oi.seller_id,
		SUM((oi.unit_price-p.cost_price)*oi.quantity) AS total_profit
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY oi.seller_id
ORDER BY SUM((oi.unit_price-p.cost_price)*oi.quantity) DESC;



--59. Calculate profit margin for every product.
SELECT
    p.product_id,
    p.product_name,
    ROUND(
        (
            SUM((oi.unit_price - p.cost_price) * oi.quantity)
            /
            NULLIF(SUM(oi.unit_price * oi.quantity),0)
        ) * 100,
        2
    ) AS profit_margin
FROM bronze.products p
JOIN bronze.order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name;

--60. Find products with profit margin above 30%.
SELECT  oi.product_id,
		p.product_name,
		SUM((oi.unit_price-p.cost_price)*oi.quantity) AS profit,
		ROUND(SUM((oi.unit_price-p.cost_price)*oi.quantity)/NULLIF(SUM(oi.unit_price*oi.quantity),0)*100,2) AS profit_margin
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY oi.product_id,
		p.product_name
HAVING ROUND(SUM((oi.unit_price-p.cost_price)*oi.quantity)/NULLIF(SUM(oi.unit_price*oi.quantity),0)*100,2)>30;

--61. Find the top 3 categories by profit in each department.

WITH profit AS
(
SELECT  c.department,
		c.category_id,
		ROUND(SUM((oi.unit_price-p.cost_price)*quantity),2) AS total_profit
FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
JOIN bronze.categories AS c
ON p.category_id=c.category_id
GROUP BY c.department,
		c.category_id
)

,ranking AS
(
SELECT 
	department,
	category_id,
	total_profit,
	DENSE_RANK() OVER(PARTITION BY department ORDER BY total_profit DESC) AS rn
FROM profit
)
SELECT *
FROM ranking
WHERE rn<=3;


--62. Find the customer with the highest number of unique products purchased.
WITH unique_p AS
(
SELECT  o.customer_id,
		COUNT(DISTINCT oi.product_id) AS total_unique_products
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
GROUP BY o.customer_id
)
SELECT TOP 1
		customer_id,
		total_unique_products
FROM unique_p
ORDER BY total_unique_products DESC;

--63. Find the average order value by state and rank states.
WITH avg_st AS
(
SELECT  c.state,
		AVG(total_amount) AS avg_value
FROM bronze.orders AS o
JOIN bronze.customers AS c
ON o.customer_id=c.customer_id
GROUP BY c.state
)
SELECT  *,
		ROW_NUMBER() OVER( ORDER BY avg_value DESC) AS rank_state	
FROM avg_st;

--64. Find the highest-revenue customer segment in every state.


WITH segment AS
(
SELECT  c.state,
		c.customer_segment,
		SUM(o.total_amount) AS revenue
FROM bronze.orders AS o
JOIN bronze.customers AS c
ON o.customer_id=c.customer_id
GROUP BY c.state,
		c.customer_segment
)
,ranking AS
(
SELECT 
		state,
		customer_segment,
		revenue,
		DENSE_RANK() OVER(PARTITION BY state ORDER BY revenue DESC) AS rn
FROM segment
)
SELECT *
FROM ranking
WHERE rn=1;

--65. Find customers who have spent more than 1 lakh.
SELECT  customer_id,
		SUM(total_amount) AS total_spend
FROM bronze.orders
GROUP BY customer_id
HAVING SUM(total_amount)>100000


--66. Find the average number of orders per customer for every customer segment.

SELECT  c.customer_segment,
		ROUND(COUNT(o.order_id)/COUNT(DISTINCT c.customer_id),2) AS avg_orders 
FROM bronze.customers AS c
RIGHT JOIN bronze.orders AS o 
ON c.customer_id=o.customer_id
GROUP BY c.customer_segment
ORDER BY c.customer_segment;
		
--67. Find customers whose first order was above the overall average order value.
WITH ranking AS
(
SELECT  *,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS rn
FROM bronze.orders
)
SELECT *
FROM ranking
WHERE rn=1 AND total_amount>(SELECT AVG(total_amount) FROM bronze.orders);

--68. Find customers whose last order was cancelled.
WITH ranking AS
(
SELECT  *,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS rn
FROM bronze.orders
)
SELECT *
FROM ranking
WHERE rn=1 AND order_status='Cancelled'

--69. Find the percentage of cancelled orders by month.
SELECT  
		DATENAME(MONTH,order_date) AS month_name,
		MONTH(order_date) AS month,
		CAST(SUM(CASE
				WHEN order_status='Cancelled' THEN 1 
				ELSE 0
			END)*100.0/COUNT(*) AS DECIMAL(5,2)) AS  cancelled_percentage 
FROM bronze.orders
GROUP BY DATENAME(MONTH,order_date),
		 MONTH(order_date)
ORDER BY MONTH(order_date);

--70. Find states with cancellation rates above the overall cancellation rate.
WITH sales_rate AS
(
SELECT  shipping_state,
		CAST(SUM(CASE
				WHEN order_status='Cancelled' THEN 1
				ELSE 0
			END)*100.0/ COUNT(*) AS decimal(5,2)) AS cancel_rate 
FROM  bronze.orders 
GROUP BY shipping_state
)
,overall AS
(
SELECT 
		SUM(CASE
				WHEN order_status='Cancelled' THEN 1
				ELSE 0
			END)*100.0/ COUNT(*) AS overall_rate

FROM bronze.orders
)
SELECT *
FROM sales_rate 
WHERE cancel_rate>(SELECT overall_rate FROM	overall);


--71. Find the average payment amount by payment method.
SELECT  payment_method,
		ROUND(AVG(payment_amount),2) avg_amount
FROM bronze.payments
GROUP BY payment_method
ORDER BY avg_amount DESC;

--72. Find orders where payment amount is less than order amount.
SELECT  o.order_id,
		o.total_amount,
		SUM(payment_amount) AS total_paid
FROM bronze.orders AS o
JOIN bronze.payments AS p
ON o.order_id=p.order_id
GROUP BY o.order_id,
		o.total_amount
HAVING  SUM(payment_amount)<o.total_amount;

--73. Find orders with multiple payment transactions.
SELECT  order_id,
		COUNT(transaction_id) AS total_transactions
FROM bronze.payments
GROUP BY order_id
HAVING COUNT(transaction_id)>1;

--74. Find the percentage of failed payments.


SELECT CAST(SUM(CASE
				WHEN payment_status='Failed' THEN 1
				ELSE 0
				END)*100.0/COUNT(*) AS DECIMAL(5,2)) AS failed_Percentage
FROM bronze.payments;

--75. Find the payment method with the highest failure rate.
SELECT TOP 1
		payment_method,
		CAST(SUM(CASE 
				WHEN payment_status='Failed' THEN 1 
				ELSE 0
				END)*100.0/COUNT(*) AS DECIMAL(5,2)) AS failure_rate
FROM bronze.payments
GROUP BY payment_method
ORDER BY SUM(CASE 
				WHEN payment_status='Failed' THEN 1 
				ELSE 0
				END)*100.0/COUNT(*) DESC;

--🧠 LEVEL 4 — Interview-Level Business Problems: 76–100
--76. Find customers who spent more than the average customer in their own state.
WITH state AS

(
SELECT  c.customer_id,
		c.state,
		SUM(o.total_amount) AS total_spend
FROM bronze.customers AS c
JOIN bronze.orders AS o
ON c.customer_id=o.customer_id
GROUP BY c.customer_id,
		c.state
)
,state_av AS
(SELECT  customer_id,
		 state,
		 total_spend,
		 ROUND(AVG(total_spend) OVER(PARTITION BY state ),2) AS avg_state 
FROM state
)
SELECT *
FROM state_av
WHERE total_spend>avg_state;


--77. Find the top 10 customers contributing the highest percentage of total revenue.
WITH sales AS
(
SELECT  customer_id,
		SUM(total_amount) AS total_sale
FROM bronze.orders
WHERE order_status='Delivered'
GROUP BY customer_id
)
,revenue AS

(
SELECT 
		customer_id,
		total_sale,
		ROUND(SUM(total_sale) OVER(),2)AS total_revenue
FROM sales
)
SELECT  TOP 10
		*,
		ROUND(total_sale*100.0 /total_revenue,2) AS percent_rev 
FROM revenue
ORDER BY total_sale*100.0 /total_revenue DESC;

--78. Find products whose sales are increasing every month.
WITH monthly AS
(
SELECT  oi.product_id,
		MONTH(o.order_date) AS order_month,
		SUM(oi.quantity) AS total_qty
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
GROUP BY oi.product_id,
		 MONTH(order_date)
)
,previous AS
(
SELECT  *,
		ISNULL(LAG(total_qty) OVER(PARTITION BY product_id ORDER BY order_month ),0) AS previous_month
FROM monthly
)
SELECT product_id 
FROM previous
GROUP BY product_id 
HAVING SUM(
    CASE
        WHEN previous_month IS NOT NULL
             AND total_qty <= previous_month
        THEN 1 ELSE 0
    END
) = 0;
; 

--79. Find customers whose order value increased on every consecutive order.
WITH previous AS
(
SELECT  customer_id,
		order_date,
		total_amount,
		LAG(total_amount) OVER(PARTITION BY customer_id ORDER BY order_date) AS previous_total
FROM bronze.orders 
)
SELECT  customer_id
FROM previous
GROUP BY customer_id
HAVING 
		SUM(CASE 
				WHEN previous_total IS NOT NULL
				AND total_amount<=previous_total THEN 1
				ELSE 0
			END)=0;

--80. Find the longest consecutive sequence of orders for each customer.

WITH ordered AS (
    SELECT
        customer_id,
        order_date,
        LAG(order_date) OVER(
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS previous_date
    FROM bronze.orders
)
,
flags AS (
    SELECT *,
           CASE
               WHEN previous_date IS NULL
                 OR DATEDIFF(DAY,previous_date,order_date) > 30
               THEN 1
               ELSE 0
           END AS new_group
    FROM ordered
)
,
groups AS (
    SELECT *,
           SUM(new_group) OVER(
               PARTITION BY customer_id
               ORDER BY order_date
           ) AS grp
    FROM flags
)
SELECT
    customer_id,
    grp,
    COUNT(*) AS consecutive_orders
FROM groups
GROUP BY customer_id, grp
ORDER BY consecutive_orders DESC;

--81. Find customers who bought Product A but never Product B.
SELECT DISTINCT o.customer_id
FROM bronze.orders o
JOIN bronze.order_items oi
    ON o.order_id = oi.order_id
WHERE oi.product_id = 1
AND o.customer_id NOT IN (
    SELECT o2.customer_id
    FROM bronze.orders o2
    JOIN bronze.order_items oi2
        ON o2.order_id = oi2.order_id
    WHERE oi2.product_id = 2
);


--82. Find product pairs frequently purchased together.
SELECT  TOP 20 
		oi1.product_id AS product_1,
		oi2.product_id AS product_id2,
		COUNT(DISTINCT oi1.order_id) AS  times_bought_together
FROM bronze.order_items AS oi1
JOIN bronze.order_items AS oi2
ON oi1.order_id=oi2.order_id 
AND oi1.product_id<oi2.product_id
GROUP BY oi1.product_id ,
		oi2.product_id 
ORDER BY times_bought_together DESC;


--83. Find sellers whose revenue is above the average seller revenue.

WITH seller_revenue AS (
    SELECT
        seller_id,
        SUM(line_total) AS revenue
    FROM bronze.order_items
    GROUP BY seller_id
)
SELECT *
FROM seller_revenue
WHERE revenue >
(
    SELECT AVG(revenue)
    FROM seller_revenue
);


--84. Find sellers with high revenue but low seller ratings.
SELECT  s.seller_id,
		s.seller_rating,
		SUM(oi.line_total) AS revenue
		
FROM bronze.order_items AS oi
JOIN bronze.sellers AS s
ON oi.seller_id=s.seller_id
GROUP BY s.seller_id,
		s.seller_rating
HAVING s.seller_rating<3.5
ORDER BY revenue DESC;



/*85. Create a seller performance score.
Give:
•	40% revenue 
•	30% seller rating 
•	30% delivery performance*/

WITH seller_data AS
(
	SELECT  s.seller_id,
			s.seller_name,
			SUM(oi.line_total) AS revenue,
			s.seller_rating,
			AVG(CASE 
					WHEN s1.delivery_status='Delivered' THEN 1
					ELSE 0
					END) AS delivery_rate
	FROM bronze.sellers AS s
	LEFT JOIN bronze.order_items AS oi
	ON s.seller_id=oi.seller_id
	LEFT JOIN bronze.shipments AS s1
	ON s.seller_id=s1.seller_id
	GROUP BY s.seller_id,
			s.seller_name,
			s.seller_rating
)
,normalised AS
(
	SELECT  *,
			revenue/MAX(revenue) OVER() AS revenue_score,
			seller_rating/5 AS rating_score
	FROM seller_data
)
SELECT  *,
		ROUND(revenue_score*.40+
		rating_score*.30+
		delivery_rate*.30,4) AS performance_score
FROM normalised
ORDER BY performance_score DESC;


--86. Find the most profitable customer segment.
SELECT TOP 1
		c.customer_segment,
		SUM(oi.line_total-(p.cost_price*oi.quantity)) AS total_profit
FROM bronze.customers AS c
JOIN bronze.orders AS o
ON C.customer_id=o.customer_id
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
JOIN bronze.products AS p
ON oi.product_id=p.product_id
GROUP BY c.customer_segment
ORDER BY total_profit DESC;


--87. Find customers who have high spending but low order frequency.
WITH sum_count AS
(
SELECT  customer_id,
		SUM(total_amount) AS total_spend,
		COUNT(*) AS total_orders
FROM bronze.orders
GROUP BY customer_id
)
,average AS
(
SELECT  customer_id,
		total_spend,
		total_orders,
		AVG(total_spend) OVER() AS avg_spend,
		AVG(total_orders) OVER() AS avg_orders
FROM sum_count

)
SELECT * 
FROM average	
WHERE total_spend>avg_spend
AND total_orders<avg_orders;

--88. Find customers with high order frequency but low average order value.
WITH total AS
(
SELECT  customer_id,
		COUNT(*) AS total_orders,
		AVG(total_amount) AS total_spend
FROM bronze.orders 
GROUP BY customer_id
)
SELECT  *
FROM total
WHERE total_orders>(SELECT AVG(total_orders) FROM total) 
AND	total_spend<(SELECT AVG(total_spend) FROM total)  
 ;

--89. Find the top 5 products by revenue growth between 2024 and 2025.

WITH yearly AS (
    SELECT
        oi.product_id,
        YEAR(o.order_date) AS year,
        SUM(oi.line_total) AS revenue
    FROM bronze.orders o
    JOIN bronze.order_items oi
        ON o.order_id = oi.order_id
    GROUP BY oi.product_id, YEAR(o.order_date)
),
pivoted AS (
    SELECT
        product_id,
        SUM(CASE WHEN year = 2024 THEN revenue ELSE 0 END) AS revenue_2024,
        SUM(CASE WHEN year = 2025 THEN revenue ELSE 0 END) AS revenue_2025
    FROM yearly
    GROUP BY product_id
)
SELECT TOP 5
    product_id,
    revenue_2024,
    revenue_2025,
    ROUND(
        (revenue_2025 - revenue_2024)
        / NULLIF(revenue_2024,0) * 100,
        2
    ) AS growth_percentage
FROM pivoted
ORDER BY growth_percentage DESC


--90. Find the category with the fastest revenue growth.
WITH order_det AS
(
SELECT  p.category_id,
		YEAR(o.order_date) order_year,
		SUM(oi.line_total) AS revenue
		FROM bronze.order_items AS oi
JOIN bronze.products AS p
ON oi.product_id=p.product_id
JOIN bronze.orders AS o
ON o.order_id=oi.order_id
GROUP BY p.category_id,
		YEAR(o.order_date)

)
,pivoted AS
(
SELECT  category_id,
		SUM(CASE
				WHEN order_year=2024 THEN revenue 
				ELSE 0
			END) AS revenue_2024,
		SUM(CASE 
				WHEN order_year=2025 THEN revenue 
				ELSE 0
			END) AS revenue_2025
FROM order_det
GROUP BY category_id
)
SELECT  TOP 1
		*,
		ROUND((revenue_2025-revenue_2024)/NULLIF(revenue_2024,0)*100,2)AS growth
FROM pivoted
ORDER BY growth DESC;

--91. Find orders whose value is greater than the customer's average order value.
WITH ord AS
(
SELECT  order_id,
		customer_id,
		total_amount
FROM bronze.orders
)
,cs_avg AS
(
SELECT  *,
		AVG(total_amount) OVER(PARTITION BY customer_id) AS avg_customer
FROM ord
)
SELECT  order_id,
		customer_id,
		total_amount
FROM cs_avg
WHERE total_amount>avg_customer
ORDER BY order_id;


--92. Find the percentage of revenue generated by the top 10 customers.
WITH revenue_cs AS
(
SELECT  customer_id,
		SUM(total_amount) AS total_revenue
FROM bronze.orders
GROUP BY customer_id
)
,cat AS
(
SELECT TOP 10
		customer_id,
		total_revenue AS top_10_revenue
FROM revenue_cs
order by total_revenue DESC
)
SELECT 
	ROUND(SUM(top_10_revenue)/(SELECT SUM(total_revenue) from revenue_cs)*100,2) AS rev_percentage
FROM cat;


--93. Find the top 10 states by revenue.
SELECT  TOP 10
		c.state,
		SUM(total_amount) AS revenue
FROM bronze.orders AS o
JOIN bronze.customers AS c
ON o.customer_id=c.customer_id
WHERE o.order_status='Delivered'
GROUP BY c.state
ORDER BY revenue DESC;

--94. Find the best-performing customer segment in every state.
WITH revenue AS
(
SELECT  c.state,
		c.customer_segment,
		SUM(o.total_amount) AS revenue
FROM bronze.orders AS o
JOIN bronze.customers AS c
ON o.customer_id=c.customer_id
GROUP BY c.state,
		c.customer_segment
)
,ranking AS
(
SELECT 
		state,
		customer_segment,
		revenue,
		DENSE_RANK() OVER(PARTITION BY state ORDER BY revenue DESC) AS rn
FROM revenue
)
SELECT 
		state,
		customer_segment,
		revenue
FROM ranking
WHERE rn=1;

/*95. Identify potentially risky sellers.
Define risky sellers as:
•	Rating < 3.5 
•	Delivery delay > 10% 
•	Revenue > average seller revenue*/

WITH seller_revenue AS
(
SELECT 
		seller_id,
		SUM(line_total) AS revenue
FROM bronze.order_items
GROUP BY seller_id
)
,seller_delivery AS
(
SELECT 
		seller_id,
		SUM(CASE 
				WHEN delivery_status='Delayed' THEN 1
				ELSE 0
				END)*100.0/COUNT(*) AS delay_rate
FROM bronze.shipments
GROUP BY seller_id
)
SELECT 
		s.seller_id,
		s.seller_name,
		s.seller_rating,
		sr.revenue,
		sd.delay_rate
FROM bronze.sellers AS s
JOIN seller_revenue AS sr
ON s.seller_id=sr.seller_id
JOIN seller_delivery AS sd
ON s.seller_id=sd.seller_id
WHERE s.seller_rating<3.5
AND sd.delay_rate>.10
AND sr.revenue>(SELECT  
					AVG(revenue)
						FROM seller_revenue);


--96. Find customers who have purchased from the same seller in at least 5 different orders.
SELECT  
		o.customer_id,
		oi.seller_id,
		COUNT(DISTINCT o.order_id) AS total_orders
FROM bronze.orders AS o
JOIN bronze.order_items AS oi
ON o.order_id=oi.order_id
GROUP BY  o.customer_id,
		  oi.seller_id
HAVING COUNT(DISTINCT o.order_id)>=5;

--97. Find the customer with the highest lifetime value.

SELECT
	TOP 1
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS lifetime_value
FROM bronze.customers c
JOIN bronze.orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_value DESC
;


--98. Create a customer segmentation using spending and order frequency.

WITH total AS
(
SELECT  customer_id,
		COUNT(*) AS order_count,
		SUM(total_amount) AS total_spending
FROM bronze.orders
WHERE order_status='Delivered'
GROUP BY customer_id
)
SELECT  customer_id,
		order_count,
		total_spending,
		CASE
			WHEN total_spending>=100000 AND order_count>=10 THEN 'VIP'
			WHEN total_spending>=50000 AND order_count>=7 THEN 'High Value'
			WHEN total_spending>=20000 AND order_count>=4 THEN 'Medium'
			ELSE 'Low Value'
		END AS customer_segment
FROM total;


/*🏆 99. FINAL CHALLENGE — Build an Executive Sales Report
Create one SQL query that returns:
Total Customers
Total Orders
Delivered Orders
Cancelled Orders
Total Revenue
Average Order Value
Total Units Sold
Total Profit
Average Discount
Cancellation Rate
Top Product
Top Category
Top Seller*/

WITH metrics AS (
    SELECT
        COUNT(DISTINCT customer_id) AS total_customers,
        COUNT(*) AS total_orders,
        SUM(CASE WHEN order_status = 'Delivered' THEN 1 ELSE 0 END) AS delivered_orders,
        SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
        SUM(CASE WHEN order_status = 'Delivered' THEN total_amount ELSE 0 END) AS total_revenue,
        AVG(CASE WHEN order_status = 'Delivered' THEN total_amount END) AS avg_order_value
    FROM bronze.orders
),
item_metrics AS (
    SELECT
        SUM(oi.quantity) AS total_units,
        SUM((oi.unit_price - p.cost_price) * oi.quantity) AS total_profit,
        AVG(oi.discount) AS avg_discount
    FROM bronze.order_items oi
    JOIN bronze.products p ON oi.product_id = p.product_id
),
top_product AS (
    SELECT TOP 1 p.product_name
    FROM bronze.products p
    JOIN bronze.order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
    ORDER BY SUM(oi.line_total) DESC
),
top_category AS (
    SELECT TOP 1 c.category_name
    FROM bronze.categories c
    JOIN bronze.products p ON c.category_id = p.category_id
    JOIN bronze.order_items oi ON p.product_id = oi.product_id
    GROUP BY c.category_id, c.category_name
    ORDER BY SUM(oi.line_total) DESC
),
top_seller AS (
    SELECT TOP 1 s.seller_name
    FROM bronze.sellers s
    JOIN bronze.order_items oi ON s.seller_id = oi.seller_id
    GROUP BY s.seller_id, s.seller_name
    ORDER BY SUM(oi.line_total) DESC
)
SELECT
    m.total_customers,
    m.total_orders,
    m.delivered_orders,
    m.cancelled_orders,
    ROUND(m.total_revenue,2) AS total_revenue,
    ROUND(m.avg_order_value,2) AS avg_order_value,
    i.total_units,
    ROUND(i.total_profit,2) AS total_profit,
    ROUND(i.avg_discount * 100,2) AS avg_discount_percentage,
    ROUND(m.cancelled_orders * 100.0 / NULLIF(m.total_orders,0),2) AS cancellation_rate,
    tp.product_name AS top_product,
    tc.category_name AS top_category,
    ts.seller_name AS top_seller
FROM metrics m
CROSS JOIN item_metrics i
CROSS JOIN top_product tp
CROSS JOIN top_category tc
CROSS JOIN top_seller ts;


/*💀 100. ULTIMATE SQL CHALLENGE
Business problem
Management wants to identify "High-Value but At-Risk Customers."
A customer is considered High Value if:
Lifetime spending > average customer spending
and At Risk if:
Their most recent order was more than 90 days ago
and they have:
At least 2 previous orders
Return:
customer_id
customer_name
total_orders
lifetime_value
last_order_date
days_since_last_order
customer_state
customer_segment
Sort by lifetime value descending.
*/
WITH customer_stats AS (

    SELECT
        c.customer_id,
        c.customer_name,
        c.state,
        c.customer_segment,

        COUNT(o.order_id) AS total_orders,

        SUM(o.total_amount) AS lifetime_value,

        MAX(o.order_date) AS last_order_date

    FROM bronze.customers c

    JOIN bronze.orders o
        ON c.customer_id = o.customer_id

    WHERE o.order_status = 'Delivered'

    GROUP BY
        c.customer_id,
        c.customer_name,
        c.state,
        c.customer_segment
),

average_value AS (

    SELECT
        AVG(lifetime_value) AS avg_lifetime_value
    FROM customer_stats
)

SELECT
    cs.customer_id,
    cs.customer_name,
    cs.total_orders,
    ROUND(cs.lifetime_value,2) AS lifetime_value,
    cs.last_order_date,

    DATEDIFF(DAY,
        cs.last_order_date,GETDATE()
    ) AS days_since_last_order,

    cs.state,
    cs.customer_segment

FROM customer_stats cs

CROSS JOIN average_value av

WHERE cs.lifetime_value > av.avg_lifetime_value

AND cs.total_orders >= 2

AND DATEDIFF(DAY,
        cs.last_order_date,GETDATE()
        
    ) > 90
	
ORDER BY cs.lifetime_value DESC;
