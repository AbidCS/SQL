CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  -- What is the total amount each customer spent at the restaurant?
  select customer_id,sum(price)  from sales s 
  left join menu m 
  on s.product_id = m.product_id 
  group by customer_id;
  
  -- How many days has each customer visited the restaurant?
select Customer_id,count(*) from (
select customer_id,order_date,count(*) from sales s group by customer_id,order_date order by customer_id) a
group by customer_id;  

select customer_id,count(distinct(order_date))  from sales group by customer_id;

--What was the first item from the menu purchased by each customer?

select customer_id,m.product_name from 
 (select  *,
     rank() over (partition by customer_id order by order_date)as rank 
  from sales s) a
left join menu m on m.product_id=a.product_id where rank=1 ;

--What is the most purchased item on the menu and how many times was it purchased by all customers?

select m.product_name ,count(*) as most_purchased from sales s left join menu m 
on s.product_id=m.product_id group by m.product_name  order by count(*) desc limit 1;


-- Which item was the most popular for each customer?
SELECT 
	Customer_id,
	product_name 
FROM (
 	SELECT 
	customer_id,
	m.product_name,
	count(*) ,
	RANK() over( PARTITION BY customer_id ORDER BY count(*) desc) 
	FROM 
		sales s
 	LEFT JOIN 
	menu m on s.product_id=m.product_id
    group by customer_id,m.product_name 
	order by customer_id, count(*) desc
)a
where RANK=1

--Which item was purchased just before the customer became a member?
SELECT *
FROM
    (SELECT
        s.customer_id,
        menu.product_name,
        order_date,
        join_date,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS rank
    FROM
        sales s
    LEFT JOIN members m ON s.customer_id = m.customer_id
    LEFT JOIN menu ON s.product_id = menu.product_id
    WHERE
        order_date >= join_date) a
WHERE
    rank = 1;

 
--Using CTE
WITH members_sales_CTE AS (
    SELECT
        s.customer_id,
        order_date,
        join_date,
        s.product_id,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS rank
    FROM
        sales s
    LEFT JOIN members m ON s.customer_id = m.customer_id
    WHERE
        order_date >= join_date
)
SELECT
    members_sales_CTE.customer_id,
    order_date,
    join_date,
    menu.product_name
FROM
    members_sales_CTE
LEFT JOIN menu ON members_sales_CTE.product_id = menu.product_id
WHERE
    rank = 1;

--Which item was purchased just before the customer became a member?
WITH members_sales_CTE AS (
 SELECT
        s.customer_id,
        order_date,
        join_date,
        s.product_id,
        RANK() OVER (PARTITION BY s.customer_id ORDER BY order_date) AS rank
    FROM
        sales s
    LEFT JOIN members m ON s.customer_id = m.customer_id
    WHERE
        order_date < join_date
)
SELECT
    members_sales_CTE.customer_id,
    order_date,
    join_date,
    menu.product_name
FROM
    members_sales_CTE
LEFT JOIN menu ON members_sales_CTE.product_id = menu.product_id
WHERE
    rank = 1; 
	
-- What is the total items and amount spent for each member before they became a member?
WITH final_output AS (
    WITH members_sales_CTE AS (
        SELECT
            s.customer_id,
            order_date,
            join_date,
            s.product_id
        FROM
            sales s
        LEFT JOIN members m ON s.customer_id = m.customer_id
        WHERE
            order_date < join_date
    )
    SELECT
        members_sales_CTE.customer_id,
        menu.price
    FROM
        members_sales_CTE
    LEFT JOIN menu ON members_sales_CTE.product_id = menu.product_id
)
SELECT
    customer_id,
    COUNT(*) as total_items,
    SUM(price) as total_spending
FROM
    final_output
GROUP BY
    customer_id;
	
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?

WITH Total_point_CTE AS (
    SELECT
        customer_id,
        product_name,
        price,
        CASE
            WHEN product_name = 'sushi' THEN price * 10 * 2
            ELSE price * 10
        END AS points
    FROM
        sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
)
SELECT
    customer_id,
    SUM(points)
FROM
    Total_point_CTE
GROUP BY
    customer_id;

--In the first week after a customer joins the program (including their join date)
--they earn 2x points on all items, not just sushi - 
--how many points do customer A and B have at the end of January?


select s.customer_id,sum(price*2) as points from sales s left join members m on s.customer_id=m.customer_id 
left join menu on s.product_id=menu.product_id 
where order_date >=join_date and order_date <=join_date+5
group by s.customer_id
UNION 
select s.customer_id,sum(price*2) as points from sales s left join members m on s.customer_id=m.customer_id 
left join menu on s.product_id=menu.product_id 
where order_date >join_date+5 and order_Date
<=(DATE_TRUNC('MONTH', DATE '2021-01-07') + INTERVAL '1 MONTH' - INTERVAL '1 DAY')::DATE
group by s.customer_id;


SELECT (DATE_TRUNC('MONTH', DATE '2021-01-07') + INTERVAL '1 MONTH' - INTERVAL '1 DAY')::DATE AS last_day_of_month;


--Bonus question
WITH Sales_order_CTE AS (
    SELECT
        s.customer_id,
        s.order_date,
        m.product_name,
        m.price
    FROM
        sales s
    LEFT JOIN menu m ON s.product_id = m.product_id
)
SELECT
    Sales_order_CTE.customer_id,
    Sales_order_CTE.order_date,
    Sales_order_CTE.product_name,
    Sales_order_CTE.price,
    CASE
        WHEN Sales_order_CTE.order_date >= join_date THEN 'Y'
        ELSE 'N'
    END AS membership
FROM
    Sales_order_CTE
LEFT JOIN members ON Sales_order_CTE.customer_id = members.customer_id 
ORDER BY
    Sales_order_CTE.customer_id,
    Sales_order_CTE.order_date;
	
	
--Bonus 2 with ranking.
WITH membered_CTE AS (
    WITH Sales_order_CTE AS (
        SELECT
            s.customer_id,
            s.order_date,
            m.product_name,
            m.price
        FROM
            sales s
        LEFT JOIN menu m ON s.product_id = m.product_id
    )
    SELECT
        Sales_order_CTE.customer_id,
        Sales_order_CTE.order_date,
        Sales_order_CTE.product_name,
        Sales_order_CTE.price,
        CASE
            WHEN Sales_order_CTE.order_date >= join_date THEN 'Y'
            ELSE 'N'
        END AS membership
    FROM
        Sales_order_CTE
    LEFT JOIN members ON Sales_order_CTE.customer_id = members.customer_id 
    ORDER BY
        Sales_order_CTE.customer_id,
        Sales_order_CTE.order_date
)
SELECT
    *,
    CASE
        WHEN membered_CTE.membership = 'Y' THEN 
            RANK() OVER (PARTITION BY membered_CTE.customer_id, membered_CTE.membership ORDER BY membered_CTE.order_date)
        ELSE NULL
    END AS ranked
FROM
    membered_CTE;
	



	








 
 









   