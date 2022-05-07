-- Schema SQL Query SQL ResultsEdit on DB Fiddle
-- Example Query:
-- SELECT
-- 	runners.runner_id,
--     runners.registration_date,
-- 	COUNT(DISTINCT runner_orders.order_id) AS orders
-- FROM pizza_runner.runners
-- INNER JOIN pizza_runner.runner_orders
-- 	ON runners.runner_id = runner_orders.runner_id
-- WHERE runner_orders.cancellation IS NOT NULL
-- GROUP BY
-- 	runners.runner_id,
--     runners.registration_date;

SET search_path = pizza_runner;

/*				A. Pizza Metrics			*/

--1. How many pizzas were ordered?
-- select count(1) from customer_orders;

--2. How many unique customer orders were made?
-- select count(distinct order_id) from customer_orders;

--3. How many successful orders were delivered by each runner?
-- select count(1) from runner_orders where coalesce(cancellation, 'null') = 'null';

--4.How many of each type of pizza was delivered?
-- select count(1), pizza_name
-- from customer_orders
-- join pizza_names using (pizza_id)
-- group by 2;

--5. How many Vegetarian and Meatlovers were ordered by each customer?
-- select count(1), customer_id, pizza_name
-- from customer_orders
-- join pizza_names using (pizza_id)
-- group by 2,3
--;

-- 6. What was the maximum number of pizzas delivered in a single order?
-- select count(1), order_id
-- from customer_orders
-- group by 2
-- order by 1 desc
-- limit 1 ;

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select 
sum(case when replace(exclusions, 'null', '') = '' or coalesce(extras,'') = '' then 1 else 0 end) count_nochanges,
sum(case when not(replace(exclusions, 'null', '') = '' or coalesce(extras,'') = '') then 1 else 0 end) count_changes,
customer_id
from customer_orders
group by 3;
