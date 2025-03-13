/* SUBQUERY */

select *
from
		(select store_name, sum(price) as total_sales 
		from sales
		group by store_name) sales 
join 
	(select avg(total_sales):: numeric (10,2) as avg_sales
	from 
		(select store_name, sum(price) as total_sales 
		from sales
		group by store_name)x
		) avg_sales
on sales.total_sales > avg_sales.avg_sales;

/* CTE */

with sales as 
	(select store_name, sum(price) as total_sales 
	from sales
	group by store_name) 
select *
from sales 
join (select avg(total_sales) as avg_sales from sales) avg_sales
on  sales.total_sales > avg_sales.avg_sales;






