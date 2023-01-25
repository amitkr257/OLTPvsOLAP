-- CREATE TABLE SCRIPT --

create table dimdate(
	
	date_key integer not NULL PRIMARY KEY,
	date date NOT NULL,
	year smallint NOT NULL,
	quarter smallint NOT NULL,
	month smallint not null,
	day smallint not null,
	week smallint not null,
	is_weekend boolean
)

create table dimcustomer(
 customer_key SERIAL PRIMARY KEY,
 customer_id smallint not null,
	first_name varchar(45) not null,
	last_name varchar(45) not null,
	email varchar(50),
	address varchar(50) not null,
	address2 varchar(50),
	district varchar(20) not null,
	city varchar(50) not null,
	country varchar(50) not null,
	postal_code varchar(10),
	phone varchar(20) not null,
	active smallint not null,
	create_date timestamp not null,
	start_date date not null,
	end_date date not null
);

create table dimmovie(
    movie_key serial PRIMARY KEY,
	film_id smallint not null,
	title varchar(255) not null,
	description text,
	release_year year,
	language varchar(20) not null,
	original_language varchar(20),
	rental_duration smallint not null,
	length smallint not null,
	rating varchar(5) not null,
	special_features varchar(60) not null
);

create table dimstore(

	store_key serial primary key,
	store_id smallint not null,
	address varchar(50) not null,
	address2 varchar(50),
	district varchar(20) not null,
	city varchar(50) not null,
	country varchar(50) not null,
	postal_code varchar(10),
	manager_first_name varchar(45) not null,
	manager_last_name varchar(45) not null,
	start_date date not null,
 	end_date date not null
	
	);

-- Fact TABLE
create table factsales (
    sales_key serial primary key,
	date_key integer references dimdate(date_key),
	customer_key integer references dimcustomer(customer_key),
	movie_key integer references dimmovie(movie_key),
	store_key integer references dimstore(store_key),
	sales_amount numeric

);

-- reference system table to identify information --
-- select
-- column_name, data_type 
-- from information_schema.columns
-- where table_name = 'dimdate';

-- INSERTION SCRIPT ----

--DIMENSION 

insert into dimdate
(date_key,date,year,quarter,month,day,week,is_weekend)
select 
distinct(TO_char(payment_date :: Date, 'yyyyMMDD')::integer) as date_key
,date(payment_date)
,extract(year from payment_date) as year
,extract(quarter from payment_date) as quarter
,extract(month from payment_date) as month
,extract(day from payment_date) as day
,extract(week from payment_date) as week
,case when extract(DOW from payment_date) in (6,7) then true else false END as is_weekend
from payment;

insert into dimcustomer 
(customer_key,customer_id,first_name,last_name,email,address,address2,
 district,city,country,postal_code,phone,active,create_date,
 start_date,end_date)
 select c.customer_id as customer_key,
 c.customer_id,
 c.first_name,
 c.last_name,
 c.email,
 a.address,
 a.address2,
 a.district,
 c1.city,
 c2.country,
 a.postal_code,
 a.phone,
 c.active,
 c.create_date,
 c.create_date as start_date,
 case when c.active = 1 then '9999-12-31' :: date else date(c.last_update) end as end_date
 from customer c
 join address  a  on a.address_id = c.address_id
 join city     c1 on a.city_id = c1.city_id
 join country  c2 on c1.country_id = c2.country_id;
 
insert into dimstore
 (store_key,store_id,address,address2,district,city,country,postal_code
 ,manager_first_name,manager_last_name,start_date,end_date)
 select
  s.store_id as store_key
 ,s.store_id
 ,a.address
 ,a.address2
 ,a.district
 ,c1.city
 ,c2.country
 ,a.postal_code
 ,st.first_name as manager_first_name
 ,st.last_name  as manager_last_name
 ,now() as start_date
 ,'9999-12-31' :: date as end_date
 from
    store s 
         join address a  on a.address_id = s.address_id
         join city    c1 on a.city_id = c1.city_id
		 join country c2 on c1.country_id = c2.country_id
		 join staff   st on s.manager_staff_id = st.staff_id;
		 
insert into dimmovie(
movie_key,film_id,title,description,release_year,language
,rental_duration,length,rating
,special_features)
select 
f.film_id as movie_key
,f.film_id
,f.title
,f.description
,f.release_year
,l.name
,f.rental_duration
,f.length
,f.rating
,f.special_features :: varchar(60) as special_features
from film f
join language l on f.language_id = l.language_id;

-- FACT

insert into factsales (date_key,customer_key,movie_key,
					   store_key,sales_amount
)
select 
TO_CHAR(p.payment_date :: date, 'yyyyMMDD'):: Integer as date_key
,p.customer_id as customer_key
,i.film_id  as movie_key
,i.store_id as store_key
,p.amount as sales_amount
from payment p
join rental    r on r.rental_id = p.rental_id
join inventory i on i.inventory_id = r.inventory_id;