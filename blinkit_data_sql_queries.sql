--Show all rows where DeliveryStatus = 'Delivered'.

Select *
from blinkit_data
where DeliveryStatus = 'Delivered'

--List all orders where Quantity = 0.

Select *
from blinkit_data
where Quantity = 0

--Find the total number of orders.

Select COUNT(orderID) as Total_orders
from blinkit_data

--Display unique ProductCategory values.

Select distinct(ProductCategory)
from blinkit_data

--Count how many times each ProductName was ordered.

Select ProductName, COUNT(ProductName) as count_of_orders_of_each_product
from blinkit_data
Group by ProductName

--Find the earliest and latest order dates.

Select cast(MIN(orderDate) as date) as first_order, cast(MAX(Orderdate) as date) as latest_order
from blinkit_data

--Show all orders paid via Cash.

Select *
from blinkit_data
where PaymentMethod = 'Cash'

--List all orders placed in February 2025. where OrderDate between 2025-2-01 and 2025-2-28

Select *
from blinkit_data 
where MONTH(cast(OrderDate as date)) = 2

--Count how many unique customers are in the dataset.

Select count(distinct(CustomerName)) as total_customers
from blinkit_data

--Show top 5 rows ordered by Price (descending).

Select top 5 *
from blinkit_data
order by TotalAmount desc 

										--B. Intermediate (Data Cleaning & Transformations)--

--Convert all CustomerEmail values to lowercase.
update blinkit_data
set CustomerEmail = Lower(CustomerEmail)

Select *
from blinkit_data

--Delete rows where Quantity = 0.
delete from blinkit_data
where Quantity = 0

--Add a new column Revenue = Quantity * Price.

Alter table blinkit_data
add Revenue float 

update blinkit_data
set Revenue = Quantity * Price

Select Revenue
from blinkit_data

--Update DeliveryStatus to ‘Delivered’ if OrderDate < '2025-04-01' but status is still pending.

Select DeliveryStatus, 
	case
	 when CAST(OrderDate as date) < '2025-04-01' and DeliveryStatus = 'Pending' then 'Delivered'
	 else DeliveryStatus
		End as updated_status
from blinkit_data


update blinkit_data
set DeliveryStatus = 	case
	 when CAST(OrderDate as date) < '2025-04-01' and DeliveryStatus = 'Pending' then 'Delivered'
	 else DeliveryStatus
		End 

--Replace UPI with Digital Wallet in PaymentMethod.

Select replace(PaymentMethod, 'UPI', 'Digital Wallet')
from blinkit_data

Update blinkit_data
set PaymentMethod = replace(PaymentMethod, 'UPI', 'Digital Wallet')

Select PaymentMethod
from blinkit_data

--Find the average Quantity of each product.

Select ProductName, cast(AVG(Quantity) as int)as avg_quantity
from blinkit_data
	group by ProductName

--Count orders for each DeliveryStatus by OrderMonth.

Select DeliveryStatus, month(CAST(OrderDate as date)) as month_number, COUNT(orderID) as count_via_delivery_status
from blinkit_data
group by DeliveryStatus, month(CAST(OrderDate as date))

--Find customers who bought from more than one ProductCategory.

Select CustomerName, COUNT(distinct ProductCategory) as different_product_category
from blinkit_data
group by CustomerName
having COUNT(distinct ProductCategory) > 1

--Show top 10 products by total revenue.

Select top 5 ProductName, SUM(Revenue) as total_revenue
from blinkit_data
group by ProductName
order by SUM(Revenue) desc

--Create a column OrderQuarter (1–4) from OrderDate.

Select month(CAST(orderDate as date)) as orderDate,
	CASE
		when month(CAST(orderDate as date)) between '1' and '4' then '1-4'
		when month(CAST(orderDate as date)) between '5' and '8' then '5-8'
		else '9-12'
	END as order_quarter
from blinkit_data

alter table blinkit_data
add OrderQuarter varchar(20)

update blinkit_data
set OrderQuarter = CASE
		when month(CAST(orderDate as date)) between '1' and '4' then '1-4'
		when month(CAST(orderDate as date)) between '5' and '8' then '5-8'
		else '9-12'
	END

Select orderquarter
from blinkit_data

												--C. Advanced (Analytics & Insights)

--Find the top 10 customers by total spending (SUM(TotalAmount)).

Select top 10 CustomerName, SUM(Revenue) as total_spending
from blinkit_data
group by CustomerName
order by SUM(Revenue) desc

--List customers who had at least 3 cancelled orders.

Select CustomerName, COUNT(*) as cancelled_orders
	from blinkit_data 
	where DeliveryStatus = 'Cancelled'
	group by customerName
Having COUNT(*) >= 3

--Show the monthly revenue trend in 2025.

Select MONTH(OrderDate) as month_num, datename(month, orderDate) as month_name, SUM(Revenue) as total_revenue_by_month
from blinkit_data
where YEAR(OrderDate) = '2025'
group by MONTH(OrderDate), datename(month, orderDate)
order by MONTH(OrderDate) 

--Find products ordered by more than 50 different customers.

Select ProductName, COUNT(DISTINCT CustomerName) as count_ordered_by_customers
from blinkit_data
group by ProductName
Having COUNT(DISTINCT CustomerName) > 50

--Show customers who ordered both ‘Milk’ and ‘Bread’.
Select CustomerName
from blinkit_data
where ProductName in ('Milk', 'Butter')
group by CustomerName
Having COUNT(distinct productName) = 2

--Rank customers by total spending within each PaymentMethod.

Select CustomerName, PaymentMethod, SUM(Revenue) as total_spent_by_each_payment_method,
		RANK() OVER (Partition by PaymentMethod order by sum(Revenue) desc ) as RankWithinPayment
from blinkit_data
group by CustomerName, PaymentMethod

--Find the most expensive order placed by each customer.

Select CustomerName, MAX(Revenue) as most_expensive_order
from blinkit_data
group by CustomerName

--Show the average order value (AOV) per PaymentMethod.

Select PaymentMethod, cast(AVG(revenue) as decimal(18,2))as average_order_value
	from blinkit_data
Group by PaymentMethod

--Create a summary by ProductCategory: total orders, total revenue, avg quantity.

Select ProductCategory, COUNT(distinct OrderID) as total_orders, SUM(Revenue) as sum_of_revenue, cast(AVG(quantity) as int) as average_quantity
from blinkit_data
group by ProductCategory
order by SUM(Revenue) desc

--Find the most common product pair ordered by the same customer.
								
with product_jodi as (

Select a.CustomerName, a.ProductName as Product1, b.ProductName as Product2
from blinkit_data a
	inner join blinkit_data b
on a.CustomerName = b.CustomerName
	and a.ProductName <> b.ProductName
)

Select top 1 Product1, Product2, COUNT(*) as pair_counting
from product_jodi
group by Product1, Product2
order by pair_counting desc
								--D. Very Advanced (Deep Analytics / Interview-style)

--Find the top 5% of customers by total revenue contribution.

With sum_of_all_revenue as (
Select SUM(revenue) as total_revenue
from blinkit_data
),

revenue_by_each_Customer as(
Select CustomerName, SUM(Revenue) as revenue_by_each_customer
from blinkit_data
group by CustomerName
)

Select TOP 5 PERCENT r.CustomerName, r.revenue_by_each_customer, 
		CAST(r.revenue_by_each_customer * 100 / s.total_revenue as decimal(10,2)) as revenue_by_percent_by_each_customer
from sum_of_all_revenue s
cross join revenue_by_each_Customer r
order by revenue_by_percent_by_each_customer desc

--Compute customer retention: how many customers ordered in Jan AND again in Feb.

create view jan_fab_repeat_orders as
Select COUNT(j.customerName) as jan_feb_repeat_custoemers
from
(
Select CustomerName
from blinkit_data
where OrderDate between '2025-01-01' and '2025-01-31'
) j
inner join (
Select CustomerName
from blinkit_data
where OrderDate between '2025-02-01' and '2025-02-28'
) f

on j.CustomerName = f.CustomerName

create view total_customers as
Select count(distinct CustomerName) as total_number_of_customers
from Blinkit_data;

select
    cast(j.jan_feb_repeat_customers * 100.0 / tc.total_number_of_customers as decimal(10,4)) as retention_percentage
from jan_feb_repeat_orders j
CROSS JOIN total_customers tc;

--For each customer, calculate the time difference (in days) between their first and last order.

Select f.customername, datediff(DAY, First_Order_date, Last_Order_date) as diff_between_first_and_last_order
from (
Select CustomerName, min(cast(orderDate as date)) as First_Order_date
from blinkit_data
group by CustomerName
) f
	inner join 
(Select CustomerName, max(cast(orderDate as date)) as Last_Order_date
from blinkit_data
group by CustomerName
) l
	on f.CustomerName = l.CustomerName
	order by diff_between_first_and_last_order desc


--Detect “VIP customers” → customers with spending above the 90th percentile.

With customer_revenue as (
Select CustomerName, SUM(Revenue) as Total_Revenue_per_customer
from blinkit_data
group by CustomerName
)

Select CustomerName, Total_Revenue_per_customer
from (
Select *, PERCENT_RANK() over (order by Total_Revenue_per_customer) as percentile_rank
from customer_revenue
) t

where percentile_rank >=0.9	
order by Total_Revenue_per_customer desc

Select *
from total_revenue_per_customer

--Find the day of the week with the highest average revenue.

Select top 1 datename(WEEKDAY,OrderDate) as day_name, cast(avg(Revenue) as decimal (10,2)) as average_of_revenue
from blinkit_data
group by datename(WEEKDAY,OrderDate)
order by average_of_revenue desc

--Create a moving average of revenue over 3 months.

select 
    year(orderdate) as year,
    month(orderdate) as month,
    sum(revenue) as revenue_per_month,
    cast(
        avg(sum(revenue)) over (
            order by year(orderdate), month(orderdate)
            rows between 2 preceding and current row
        ) as decimal(10,2)
    ) as revenue_3month_moving_avg
from blinkit_data
group by year(orderdate), month(orderdate)
order by year, month;


--Find the customer-product pair with the highest total revenue.

Select top 1 CustomerName, ProductName, SUM(revenue) as total_revenue_per_product
from blinkit_data
group by CustomerName, ProductName
order by sum(revenue) desc

--Detect payment method preference for repeat customers.


with count_of_payment_method as (
    select customername, 
           paymentmethod, 
           count(*) as payment_method_count
    from blinkit_data
    group by customername, paymentmethod
)
select customername, paymentmethod, payment_method_count as payment_method_preference
from (
    select *,
           row_number() over (partition by customername order by payment_method_count desc) as rn
    from count_of_payment_method
) t
where rn = 1;

--Build a customer order frequency distribution (how many customers ordered once, twice, 3+ times, etc.).

Select CustomerName, COUNT(distinct OrderID) as total_times_ordered,
	case
		when COUNT(distinct OrderID) = 1 then 'Ordered Once'
		when COUNT(distinct OrderID) = 2 then 'Ordered twice'
		else 'Ordered 3+ times'
	end as frequency_distribution
from blinkit_data
group by CustomerName
order by CustomerName