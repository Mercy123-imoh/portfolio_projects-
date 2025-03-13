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
where  rep_ordernumber = 2

























