/* --------------------
   Case Study Questions
   --------------------*/

SET search_path = dannys_diner;

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
   sum(menu.price),
    customer_id
FROM sales
join menu using (product_id) 
group by 2
;


-- 2. How many days has each customer visited the restaurant?
select count(distinct order_date), customer_id
from sales
group by 2
;


-- 3. What was the first item from the menu purchased by each customer?
select customer_id, array_agg(distinct product_id) from 
(
select --first_value(product_id) over (partition by customer_id order by order_date), customer_id
rank() over (partition by customer_id order by order_date) as r, customer_id, product_id
from sales
) a
where r = 1
group by 1
;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select count(1), product_name
from sales
join menu using (product_id)
group by 2
order by 1 desc
limit 1
;

-- 5. Which item was the most popular for each customer?
select customer_id, array_agg(product_name)
from
(
select rank() over (partition by customer_id order by count desc), customer_id, product_name
from
(
select count(1), customer_id, product_name
from sales
join menu using (product_id)
group by 2,3
order by 1 desc
)a
)b
where rank = 1
group by 1
;

--5 alternate
-- SELECT customer_id, array_agg(product_name) FROM 
-- (SELECT S.customer_id, M.product_name,COUNT(1) PURCHASE,
-- RANK() OVER(PARTITION BY S.customer_id ORDER BY COUNT(S.product_id) DESC ) AS R
-- FROM sales AS S
-- JOIN menu AS M
-- ON S.product_id = M.product_id
-- GROUP BY S.customer_id, M.product_name)a
-- WHERE R=1
-- group by 1;


-- 6. Which item was purchased first by the customer after they became a member?
select distinct first_value(product_name) over (partition by customer_id order by order_date), customer_id
from sales
join menu using (product_id)
join members using (customer_id)
where order_date > join_date
;


-- 7. Which item was purchased just before the customer became a member?
select * from
(
select 
--last_value(product_name) over (partition by sales.customer_id order by order_date),
rank() over (partition by customer_id order by order_date desc) as r, customer_id, product_name
from sales
join menu using (product_id)
join members using (customer_id)
where order_date < join_date
)a
where r = 1
;


-- 8. What is the total items and amount spent for each member before they became a member?
select count(1), sum(price), customer_id
from sales
join menu using (product_id)
join members using (customer_id)
where order_date < join_date
group by 3
;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select sum(case when product_name = 'sushi' then 20 else 10 end * price), customer_id
from sales
join menu using (product_id)
--join members using (customer_id)
-- where order_date < '2021-02-01'
group by 2
;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select
sum(case when (date_part('day', order_date::timestamp - join_date::timestamp) between 0 and 7) or (product_name = 'sushi') then 20 else 10 end * price) 
, customer_id
--sum(case when DATEDIFF(Day, order_date, join_date)   then 20 else 10 end * price), customer_id
from sales
join menu using (product_id)
join members using (customer_id)
where order_date < '2021-02-01'
group by 2
;

