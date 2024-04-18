// https://8weeksqlchallenge.com/case-study-2/
// Part A 
//Question 1 - how many pizzas were ordered
select
Count(*)
from customer_orders;
//Answer: 14

//Question 2 - How many unique customer orders were made
select 
 count(distinct order_id)
from customer_orders;
//Answer: 10

//Question 3 - How many successful orders were delivered by each runner?
select
runner_id,
count(order_id)
from runner_orders
where duration!='null'
group by runner_id;
/*
Answer:
RUNNER_ID	COUNT(ORDER_ID)
1	4
2	3
3	1
*/

//Question 4 - How many of each type of pizza was delivered?
select 
    pizza_id,
    count(pizza_id)
from runner_orders as ro
join customer_orders as co
    on co.order_id = ro.order_id
where duration!='null'
group by pizza_id;
/*
Answer:
PIZZA_ID	COUNT(PIZZA_ID)
1	9
2	3
*/

//Question 5 - How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
    CUSTOMER_ID,
    PIZZA_NAME,
    COUNT(PO.PIZZA_ID)
FROM CUSTOMER_ORDERS CO
    JOIN PIZZA_NAMES PO
        ON CO.PIZZA_ID=PO.PIZZA_ID
group by customer_id, PIZZA_NAME;
/* Answer:
CUSTOMER_ID	PIZZA_NAME	COUNT(PO.PIZZA_ID)
101	Meatlovers	2
102	Meatlovers	2
102	Vegetarian	1
103	Meatlovers	3
103	Vegetarian	1
104	Meatlovers	3
101	Vegetarian	1
105	Vegetarian	1
*/

//Question 6 - What was the maximum number of pizzas delivered in a single order?
WITH CTE AS (
SELECT 
 ORDER_ID,
 COUNT(PIZZA_ID) AS COUNT
FROM CUSTOMER_ORDERS
GROUP BY ORDER_ID)

SELECT
MAX(COUNT)
FROM CTE;
// ANSWER: 3

//Question 7 - For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

WITH CTE1 AS (
SELECT
    CO.order_id, CUSTOMER_ID, COUNT(PIZZA_ID) AS AMOUNT, EXCLUSIONS, EXTRAS,
    (CASE WHEN EXCLUSIONS<>'' AND EXCLUSIONS<>'null' THEN 1 ELSE 0 END) AS EXCLUSION,
    (CASE WHEN extras<>'' AND extras<>'null' THEN 1 ELSE 0 END) AS EXTRA
FROM CUSTOMER_ORDERS CO
JOIN runner_orders RO
    on co.order_id = ro.order_id
    where duration!='null'
    group by CO.order_id,customer_id, pizza_id, EXCLUSIONS,EXTRAS),

CTE2 AS (
SELECT
    ORDER_ID, CUSTOMER_ID, AMOUNT, EXCLUSIONS, EXTRAS, EXCLUSION, EXTRA,
    (CASE WHEN EXCLUSION=0 AND EXTRA=0 THEN 0 ELSE 1 END) AS CHANGES
FROM CTE1
group by order_id,customer_id, AMOUNT, EXCLUSIONS,EXTRAS,EXCLUSION, EXTRA)


SELECT
CUSTOMER_ID,
SUM(AMOUNT) AS TOTAL_PIZZAS_DELIVERED,
SUM(AMOUNT*CHANGES) AS PIZZAS_WITH_CHANGES
FROM CTE2
group by CTE2.CUSTOMER_ID
ORDER BY CUSTOMER_ID;

/*Answer =
CUSTOMER_ID	TOTAL_PIZZAS_DELIVERED	PIZZAS_WITH_CHANGES
101	2	0
102	3	0
103	3	3
104	3	2
105	1	1
*/

//Question 8 - How many pizzas were delivered that had both exclusions and extras?
WITH CTE AS (
SELECT
    CO.order_id, CUSTOMER_ID, COUNT(PIZZA_ID) AS AMOUNT, EXCLUSIONS, EXTRAS,
    (CASE WHEN EXCLUSIONS<>'' AND EXCLUSIONS<>'null' THEN 1 ELSE 0 END) AS EXCLUSION,
    (CASE WHEN extras<>'' AND extras<>'null' THEN 1 ELSE 0 END) AS EXTRA
FROM CUSTOMER_ORDERS CO
JOIN runner_orders RO
    on co.order_id = ro.order_id
    where duration!='null'
    group by CO.order_id,customer_id, pizza_id, EXCLUSIONS,EXTRAS)
,
CTE2 AS (
SELECT
    ORDER_ID, CUSTOMER_ID, AMOUNT, EXCLUSIONS, EXTRAS, EXCLUSION, EXTRA,
    (CASE WHEN EXCLUSION=1 AND EXTRA=1 THEN 1 ELSE 0 END) AS CHANGES
FROM CTE
group by order_id,customer_id, AMOUNT, EXCLUSIONS,EXTRAS,EXCLUSION, EXTRA)

SELECT
SUM(CHANGES)
FROM CTE2;
// Answer= 1

//Question 9 - What was the total volume of pizzas ordered for each hour of the day?
SELECT
DATE_PART('HOUR', ORDER_TIME) AS HOUR,
COUNT(*)
FROM CUSTOMER_ORDERS
GROUP BY HOUR
ORDER BY HOUR;
/*Answer:
HOUR	COUNT(*)
11	1
13	3
18	3
19	1
21	3
23	3 */

//Question 10 - What was the volume of orders for each day of the week?
SELECT
DATE_PART('weekday', ORDER_TIME) AS day,
COUNT(*)
FROM CUSTOMER_ORDERS
GROUP BY day
ORDER BY day
/*DAY	COUNT(*)
3	5
4	3
5	1
6	5*/
