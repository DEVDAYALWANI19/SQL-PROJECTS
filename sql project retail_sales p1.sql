drop table if exists retail_sales;
create table public.retail_sales(
  transactions_id INT  primary key,
  sale_date	 DATE,
  sale_time TIME,
  customer_id INT,
  gender VARCHAR(15),
  age	INT,
  category VARCHAR(15),
  quantiy	INT,
  price_per_unit FLOAT,	
  cogs	FLOAT,
  total_sale FLOAT
);

alter table retail_sales
rename column quantiy to quantity;
--- data cleaninig
SELECT * FROM retail_sales
where transactions_id is null
     or
  sale_time is null 
    or 
  customer_id is null
    or
  gender is null
  	or
  age	is null
  	or
  category is null
  	or
  quantiy	is null
  	or
  price_per_unit is null
  	or
  cogs	is null
  	or
  total_sale is null;


 delete from retail_sales
 where transactions_id is null
     or
  sale_time is null 
    or 
  customer_id is null
    or
  gender is null
  	or
  age	is null
  	or
  category is null
  	or
  quantiy	is null
  	or
  price_per_unit is null
  	or
  cogs	is null
  	or
  total_sale is null;

  --data exploration
-- How many sales we have?
select count(total_sale) from retail_sales;

-- How many uniuque customers we have ?
select count( distinct(customer_id)) as no_of_customers from retail_sales;

-- how many category we have?
select distinct(category) as total_category from retail_sales;

-- Data Analysis & Business Key Problems & Answers

-- My Analysis & Findings
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
select * from retail_sales where sale_date ='2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

select *
from retail_sales 
where category = 'Clothing' and  Quantity >=4 
and sale_date between '2022-11-01' and  '2022-11-30' ;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
select category ,  sum(total_sale) as Total_Sales ,count(*) as total_orders
from retail_sales group by category order by Total_Sales;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
select category , round(avg(age),2) as AVG_AGE 
from retail_sales  where category like 'Beauty'  group by category;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
select *  from retail_sales where total_sale>=1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
select count(distinct(transactions_id)) as Total_transactions, gender, category
from retail_sales
group by category, gender ;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

select * from 
(

select 
	extract(year from sale_date ) as year,
	extract(month from sale_date ) as month,   
	
	avg(total_sale) as avg_sales, 
	rank() over(partition by extract(year from sale_date ) order by avg(total_sale) desc) as rank
	from retail_sales
	group by year , month ) as t1 
	where rank =1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select customer_id , sum(total_sale) as highest_total_sales
from retail_sales
group by 1 
order by 2 desc  limit 1;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
select  count(distinct(customer_id)) as customers , category
from retail_sales
group by 2
order by 1;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

with hourly_sales
as (

select *,
	case
	when extract( hour from sale_time)<=12 then 'Morning'
	when  extract( hour from sale_time) between 12 and 17 then 'Afternoon'
	else 'Evening'
	end  as shift 
from retail_sales 
)
select  shift, count(*) as total_orders
from hourly_sales
group by shift;









