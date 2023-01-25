 /* Query time analysis on OLTP vs OLAP tables. This proves that why such
  analysis needs to be done on DWH side. The time taken and amount of 
  complex join is fairly less as compared to OLTP tables.
  
  SEE a comparison below, this will fairly increase if the load of data is
  in peta/exa bytes.
 */
 /*
  Problem statement is Determine the city which records highest sale
  in which month and for which movie 
 */
 
 
 -- OLAP Tables (DWH)-- takes *** 202 msec ***
select dimmovie.title
, dimdate.month
,dimcustomer.city
, sum(sales_amount) as revenue
from factsales
join dimmovie on dimmovie.movie_key = factsales.movie_key
join dimdate on dimdate.date_key = factsales.date_key
join dimcustomer on dimcustomer.customer_key = factsales.customer_key
group by dimmovie.title, dimdate.month, dimcustomer.city
order by dimmovie.title, dimdate.month, revenue desc
 
 

 -- VS OLTP Tables (rental)-- takes *** 794msec ***
 
 select f.title
 ,extract (month from p.payment_date) as month
 ,c1.city 
 ,sum(amount) as revenue
 from payment p
 join rental  r   on r.rental_id = p.rental_id
 join inventory i on i.inventory_id = r.inventory_id
 join film f      on f.film_id = i.film_id
 join customer c  on c.customer_id = p.customer_id
 join address a   on a.address_id = c.address_id
 join city c1     on c1.city_id = a.city_id
 group by f.title, month, c1.city
 order by f.title, month,  revenue desc;