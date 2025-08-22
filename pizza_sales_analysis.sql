create database pizzahut;
use pizzahut;

CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    order_time TIME
);

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(50),
    name VARCHAR(100),
    category VARCHAR(30),
    ingredients VARCHAR(200)
);

CREATE TABLE pizzas (
    pizza_id VARCHAR(30),
    pizza_type_id VARCHAR(30),
    size VARCHAR(3),
    price FLOAT
);

SELECT 
    *
FROM
    order_details;
SELECT 
    *
FROM
    orders;
SELECT 
    *
FROM
    pizza_types;
SELECT 
    *
FROM
    pizzas;


-- 1. Retrieve the total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- 2. Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;

-- 3.  Identify the highest-priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY 2 DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered 
SELECT 
    pizzas.size, COUNT(order_details.order_details_id) as order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- 7. Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY 1;

-- 8. Join relevant tables to find the category-wise distribution of pizzas
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY 1;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY 1) AS order_quantity;

-- 10. Determine the top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pt.category,
    ROUND(SUM(od.quantity * p.price) / (
        SELECT SUM(od2.quantity * p2.price)
        FROM order_details od2
        JOIN pizzas p2 ON p2.pizza_id = od2.pizza_id
    ) * 100, 2) AS revenue_percentage
FROM pizza_types pt
JOIN pizzas p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue_percentage DESC;

-- 12. Analyze the cumulative revenue generated over time
SELECT 
	order_date,
	round(sum(revenue) OVER(ORDER BY order_date), 2) AS cum_revenue
FROM(
	SELECT 
		orders.order_date,
		ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
	FROM order_details 
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
	JOIN orders ON orders.order_id = order_details.order_id
	GROUP BY 1
) AS sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category
select name,revenue
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by 1, 2) as a) as b
where rn <= 3;