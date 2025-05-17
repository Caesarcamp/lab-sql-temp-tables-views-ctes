-- Primero, cree una vista que resuma la información de alquiler de cada cliente. Esta vista debe incluir el ID, el nombre, el correo electrónico y el número total de alquileres (rental_count).
create or replace view customer_summary as 
select
	c.customer_id, 
    c.first_name,
    c.email,
    count(rental_id) as rental_count
from sakila.customer as c
left join sakila.rental as r 
	using (customer_id)
group by 
	c.customer_id,
    c.first_name,
    c.email ;
    
-- A continuación, cree una tabla temporal que calcule el importe total pagado por cada cliente (total_paid). Esta tabla temporal debe usar la vista de resumen de alquiler creada en el paso 1 para combinarse con la tabla de pagos y calcular el importe total pagado por cada cliente.
create temporary table payment_summary as 
select 
	cs.customer_id,
    cs.first_name,
    cs.email ,
    cs.rental_count,
    sum(p.amount) as total_paid
from sakila.customer_summary as cs
left join sakila.payment as p
	using (customer_id)
group by 
	cs.customer_id,
    cs.first_name,
    cs.email,
    cs.rental_count;
    
-- Create a CTE and the Customer Summary Report
with int_table as (
	select
		cs.* , ps.total_paid
	from customer_summary as cs
	inner join payment_summary as ps
		on cs.customer_id = ps.customer_id
)
select
	*,
    total_paid/rental_count as avg_rent
from int_table

    