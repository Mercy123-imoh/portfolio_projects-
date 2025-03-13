select paymentDate, round( sum(amount),1) as total_payments
from payments
group by paymentDate
having total_payments > 30000
order by paymentDate;

select *
from payments
order by paymentDate;

select productCode, count(orderNumber)
from orderdetails
group by productCode;

select orderDate, count( distinct orderNumber) as orders 
from orders
group by orderDate;

select paymentDate,
 max(amount) as highest_payment,
 min(amount) as lowest_payment
from payments
group by paymentDate
 having paymentDate = '2003-12-09'
order by paymentDate;

select paymentDate, round( avg(amount), 1) as average_payment
from payments
group by paymentDate
order by  paymentDate;

select  round(avg(amount),1) as average_payment
from payments
order by  paymentDate;

with main_cte as 

(select 
t1.ordernumber, 
orderdate, 
quantityordered, 
productname, 
productline, 

case when quantityordered > 40 and productline = 'motorcycles'
then 1 else 0 end as ordered_over_40_motorcycles 

from orders t1
join orderdetails t2 
on t1.ordernumber = t2.orderNumber
join products t3 on t2.productCode = t3.productCode)

select orderdate, sum(ordered_over_40_motorcycles)
from main_cte 
group by orderdate; 

select *, 
case when comments like '%negotiate%' then 1 else 0 end 
as negotiated 
from orders; 

select *,
 case when comments like '%negotiate%' then 'negotiated order' 
 when comments like '%dispute%' then 'disputed order'
 else 'no dispute or negotiate' end as status_1
from orders; 

select
 t1.customerName,
 t2.customerNumber, 
 t2.orderNumber,
 orderDate,
 productCode, 
 
 row_number () over (partition by t1.customerNumber
 order by orderDate) as purchase_number 
 
from customers t1 
join orders t2 
on t1.customerNumber = t2.customerNumber 
join orderdetails t3
 on t2.orderNumber = t3.orderNumber; 
 
 select customerNumber, paymentDate, amount, 
 
 lead(amount) over (partition by customerNumber order by paymentDate)
 as next_payment 
 
 from payments; 
 
 with main_cte as 
 (select customerNumber, paymentDate, amount, 
 
 lag (amount) over (partition by customerNumber order by paymentDate)
 as previous_payment 
 
 from payments)
 
 select *, amount - previous_payment as difference 
 from main_cte ;
  
with main_cte as 
 (select orderDate, t2.orderNumber,
 salesRepEmployeeNumber, jobTitle,
 
row_number () over (partition by t1.salesRepEmployeeNumber
order by orderDate) as rep_ordernumber

from customers t1 
join orders t2 
on t1.customerNumber = t2.customerNumber 
join employees t3 
on t1.salesRepEmployeeNumber = t3.employeeNumber)

select *  
from main_cte
where  rep_ordernumber = 2;

with main_cte as 
(
select 
t1.orderdate, 
t2.customerNumber, 
t1.ordernumber,
customerName, 
productCode,
creditLimit, 
quantityOrdered * priceEach as sales_value
from orders t1
inner join customers t2 
on t1.customerNumber = t2.customerNumber 
inner join orderdetails t4 
on t1.orderNumber = t4.orderNumber
),
running_total_sales_cte as 
(
select *, lead (orderdate) over (partition by customernumber order by orderdate) as next_order_date
from
(
select 
orderdate,
ordernumber, 
customerNumber, 
customerName, 
creditLimit,
sum(sales_value) as sales_value
from main_cte 
group by  orderdate,  
creditLimit,
customerName, 
customerNumber,
ordernumber
)subquery
),

payments_cte as 
(
select *
from payments
group by customerNumber, paymentDate, amount, checkNumber
),

main_one_cte as
(
select t1.*, 
row_number () over (partition by t1.customernumber order by orderdate) as purchase_num, 
sum(sales_value) over (partition by t1.customernumber order by orderdate) as running_total_sales,
sum(amount) over (partition by t1.customerNumber order by orderdate) as running_total_payments
from running_total_sales_cte t1
left join payments_cte t2 
on t1.customernumber = t2.customernumber and t2.paymentdate between t1.orderdate and 
case when t1.next_order_date is null then current_date else next_order_date end
) 

select *, running_total_sales - running_total_payments as money_owed, 
creditlimit - (running_total_sales - running_total_payments ) as difference
from main_one_cte; 

with sales as 
(
select t1.orderNumber,t1.customerNumber,productCode, quantityOrdered, priceEach, priceEach * quantityOrdered as sales_value, creditLimit
from orders t1 
inner join orderdetails t2 
on t1.orderNumber = t2.orderNumber
inner join customers t3 
on t1.customerNumber = t3.customerNumber
)
select ordernumber, customernumber, sum(sales_value) as sales_value, 
case when creditlimit < 75000 then 'a; less than $75k'
when creditlimit between 75000 and 100000 then 'b; $75k - $100k'
when creditlimit between 100000 and 150000 then 'c; $100k - $150k' 
when creditlimit > 150000 then 'd; above $150k'
else 'other' end as creditlimit_grp
from sales 
group by ordernumber, customernumber, creditlimit_grp;






























