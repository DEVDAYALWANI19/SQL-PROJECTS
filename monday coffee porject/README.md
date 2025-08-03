# #Monday Coffee Expension SQL Project

![Company Logo](https://github.com/DEVDAYALWANI19/SQL-PROJECTS/blob/b10045652e9922c91ba24eb1fa2442eef6e55930/monday%20coffee%20porject/1.png)

## Project Overview

**Project Title**: Monday coffee expansion sql project
**Project level **:Advance
**Database**: `Monday_coffee_db `

## Objectives
The goal of this project is to analyze the sales data of Monday Coffee, a company that has been selling its products online since January 2023, and to recommend the top three major cities in India for opening new coffee shop locations based on consumer demand and sales performance.

## Project Structure

### 1. Database Setup


- **Database Creation**: Created a database named `Monday_coffee_db
- **Table Creation**: Created tables for city ,customers ,sales ,products.

```sql

DROP TABLE IF EXISTS city;

CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
);


DROP TABLE IF EXISTS customers;

CREATE TABLE customers
(
	customer_id INT PRIMARY KEY,	
	customer_name VARCHAR(25),	
	city_id INT,
	CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);


dROP TABLE IF EXISTS products;

CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
);

DROP TABLE IF EXISTS sales;

CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
	
);

SELECT * FROM city;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM sales;
```
## Key Questions
1. **Coffee Consumers Count**  
   How many people in each city are estimated to consume coffee, given that 25% of the population does?
```sql
select city_name,
round(population * 0.25/ 1000000,2)  as coffee_consumers, city_rank
from  city 
order by 2 DESC;
```
2. **Total Revenue from Coffee Sales**  
  -- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
```sql
SELECT sum(s.total) as total_revenue,
 ct.city_name 
	from sales s
	join customers c 
	on s.customer_id = c.customer_id
	JOIN city ct
	on ct.city_id = c.city_id
	where 
	extract (quarter from s.sale_date) = 4 and
	EXTRACT(year from s.sale_date) = 2023
    group by 2 
	order by 1 desc

```

3. **Sales Count for Each Product**  
   How many units of each coffee product have been sold?
```sql
SELECT p.product_name , 
count(s.sale_id) as total_orders
from products p
join sales s
on p.product_id=s.product_id
group by 1
order by 2 desc;
```
4. **Average Sales Amount per City**  
   What is the average sales amount per customer in each city?
```sql
SELECT ct.city_name,
sum(s.total) as total_sales,
count(distinct(c.customer_id)) as customers,
round( sum(s.total):: numeric/ count(distinct(c.customer_id)::numeric),2) as avg_sales_pr_cst
from sales s
join customers c
on c.customer_id = s.customer_id
join city ct
on ct.city_id = c.city_id
group by 1
order by 4 desc
```

5. **City Population and Coffee Consumers**  
   Provide a list of cities along with their populations and estimated coffee consumers.
```sql
with city_table as
(
	SELECT city_name , 
	round(population *0.25 /1000000,2) as coffee_consumers 
	from city 

),

customer_table AS
(
	select city_name , 
		 count(distinct c.customer_id) as unique_customers
	
	from sales s
	join customers c
	on s.customer_id = c.customer_id
	join city ct
	on ct.city_id = c.city_id
	group by 1

)
select 
customer_table.city_name,
city_table.coffee_consumers,
customer_table.unique_customers
from city_table 
join 
customer_table 
on customer_table.city_name = city_table.city_name
```

6. **Top Selling Products by City**  
   What are the top 3 selling products in each city based on sales volume?
```sql
select * 
from  
(
select 
	ct.city_name ,	
	p.product_name,
	count(s.sale_id) as total_orders,
	dense_rank() over(partition by ct.city_name order by count(s.sale_id) DESC) as rank
			from sales s
			join products p
			on s.product_id = p.product_id
			join customers c
			on c.customer_id = s.customer_id
			join city ct
			on ct.city_id = c.city_id
			group by 1,2) 
		as t1
where 
rank <=3
```

7. **Customer Segmentation by City**  
   How many unique customers are there in each city who have purchased coffee products?
```sql
select ct.city_name ,
count(distinct s.customer_id) as unique_customers
 from city ct 
left join customers c
 on c.city_id = ct.city_id
 join sales s
 on s.customer_id =c.customer_id 

 where
    	s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
		 group by 1
```

8. **Average Sale vs Rent**  
   Find each city and their average sale per customer and avg rent per customer?
```sql
with city_table
AS
(

	SELECT ct.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_unique_customers,
	round(sum(s.total)::numeric  / count( distinct s.customer_id)::numeric ,2) as avg_sales_per_customers
	from sales s
	join customers c 
	on s.customer_id = c.customer_id
	join city ct
	on ct.city_id = c.city_id 
	GROUP by 1
	) ,


city_rent 

AS
(
	select city_name ,
	estimated_rent
from city )

SELECT ct.city_name,
		cr.estimated_rent,
		total_revenue,
		ct.total_unique_customers,
		ct.avg_sales_per_customers,
		round(cr.estimated_rent::numeric/ct.total_unique_customers::numeric,2) as avg_rent_per_customers
from city_table ct
join city_rent cr
on cr.city_name = ct.city_name
order by 4 desc
```

9. **Monthly Sales Growth**  
   Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
```sql
with monthly_sales
AS(
	select  ct.city_name,
		EXTRACT(month from s.sale_date) as months,
		EXTRACT(year from s.sale_date) as year,
		sum(s.total) as total_sales
	
	from sales as s
	join customers as c
	on c.customer_id = s.customer_id
	join city ct
	on c.city_id = ct.city_id
	group by 1,2,3
	order by 1,3,2
 ) ,
 growth_ratio
 AS
	(select
		city_name,
		 months,
		 year,
		 total_sales as cur_monthly_sales,
		 lag(total_sales,1) over(partition by city_name order by year,months) as last_month_sales
		from monthly_sales 
)
	select 
		city_name,
		 months,
		 year,
		 cur_monthly_sales,
		 last_month_sales,
		round(
			(cur_monthly_sales - last_month_sales) :: numeric / last_month_sales ::numeric *100,2)  as growth_ratio
		from growth_ratio
		where growth_ratio is not null;
```

10. **Market Potential Analysis**  
    Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer?
```sql
with city_table
AS
(

	SELECT ct.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_unique_customers,
	round(sum(s.total)::numeric  / count( distinct s.customer_id)::numeric ,2) as avg_sales_per_customers
	from sales s
	join customers c 
	on s.customer_id = c.customer_id
	join city ct
	on ct.city_id = c.city_id 
	GROUP by 1
	) ,


city_rent 

AS
(
	select city_name ,
	round((population *0.25)/1000000,2) as estimated_coffee_consumer,
	estimated_rent
from city )

SELECT ct.city_name,
		cr.estimated_rent,
		total_revenue,
		ct.total_unique_customers,
		estimated_coffee_consumer,
		ct.avg_sales_per_customers,
		round(cr.estimated_rent::numeric/ct.total_unique_customers::numeric,2) as avg_rent_per_customers
from city_table ct
join city_rent cr
on cr.city_name = ct.city_name
order by 3 desc

```
## RECOMMENDATIONS
--After analyzing the data, the recommended top three cities for new store openings are:

**City 1: Pune**  
1. Average rent per customer is very low.  
2. Highest total revenue.  
3. Average sales per customer is also high.

**City 2: Delhi**  
1. Highest estimated coffee consumers at 7.7 million.  
2. Highest total number of customers, which is 68.  
3. Average rent per customer is 330 (still under 500).

**City 3: Jaipur**  
1. Highest number of customers, which is 69.  
2. Average rent per customer is very low at 156.  
3. Average sales per customer is better at 11.6k.

## Author - Dev Dayalwani


Thank you for your interest in this project!
If you like it don’t forget to give the ratings. 

