create database answers
use answers

--Set-01
#### Schemas

```sql
CREATE TABLE artists (
    artist_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    birth_year INT NOT NULL
);

CREATE TABLE artworks (
    artwork_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    artist_id INT NOT NULL,
    genre VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    artwork_id INT NOT NULL,
    sale_date DATE NOT NULL,
    quantity INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (artwork_id) REFERENCES artworks(artwork_id)
);

INSERT INTO artists (artist_id, name, country, birth_year) VALUES
(1, 'Vincent van Gogh', 'Netherlands', 1853),
(2, 'Pablo Picasso', 'Spain', 1881),
(3, 'Leonardo da Vinci', 'Italy', 1452),
(4, 'Claude Monet', 'France', 1840),
(5, 'Salvador Dalí', 'Spain', 1904);

INSERT INTO artworks (artwork_id, title, artist_id, genre, price) VALUES
(1, 'Starry Night', 1, 'Post-Impressionism', 1000000.00),
(2, 'Guernica', 2, 'Cubism', 2000000.00),
(3, 'Mona Lisa', 3, 'Renaissance', 3000000.00),
(4, 'Water Lilies', 4, 'Impressionism', 500000.00),
(5, 'The Persistence of Memory', 5, 'Surrealism', 1500000.00);

INSERT INTO sales (sale_id, artwork_id, sale_date, quantity, total_amount) VALUES
(1, 1, '2024-01-15', 1, 1000000.00),
(2, 2, '2024-02-10', 1, 2000000.00),
(3, 3, '2024-03-05', 1, 3000000.00),
(4, 4, '2024-04-20', 2, 1000000.00);




### Section 1: 1 mark each

1. Write a query to display the artist names in uppercase.

select upper(name) as names from artists

2. Write a query to find the total amount of sales for the artwork 'Mona Lisa'.

select total_amount from sales s
inner join artworks a on a.artwork_id=s.artwork_id
where title='Mona Lisa'

3. Write a query to calculate the price of 'Starry Starry' plus 10% tax.

select (price+0.1*price)as priceAfterTax from artworks 
where title='Starry Night'

4. Write a query to extract the year from the sale date of 'Guernica'.

select year(sale_date) as [year] from sales s
inner join artworks a on a.artwork_id=s.artwork_id
where title='Guernica'



### Section 2: 2 marks each

5. Write a query to display artists who have artworks in multiple genres.
with cte_art
as
(
select name,genre from artists a
inner join artworks ar on a.artist_id=ar.artist_id
group by genre,name
having count(*)>=2
)
select * from cte_art
6. Write a query to find the artworks that have the highest sale total for each genre.

select top 1 title from artworks a
inner join sales s on a.artwork_id=s.artwork_id
group by genre,total_amount,title
order by total_amount desc


7. Write a query to find the average price of artworks for each artist.
select name,avg(a.price) as average from artworks a
inner join artists ar on  a.artist_id=ar.artist_id
group by name 

8. Write a query to find the top 2 highest-priced artworks and the total quantity sold for each.
select top 2 title ,quantity from artworks ar
inner join artists a on a.artist_id=ar.artist_id
inner join sales s on ar.artwork_id=s.artwork_id

9. Write a query to find the artists who have sold more artworks than the average number of artworks sold per artist.

with cte_inavg
as
(
select avg(quantity) as qua,name,quantity
from sales s
inner join artworks ar on ar.artwork_id=s.artwork_id
inner join artists a on a.artist_id=ar.artist_id
group by s.artwork_id,name,quantity
)
select * from cte_inavg 
where cte_inavg.quantity<qua


10. Write a query to display artists whose birth year is earlier than the average birth year of artists from their country.

with cte
as
(
select avg(birth_year) as ear,name
from artists
group by name
)
select * from cte
where ear>all(select birth_year from artists)



11. Write a query to find the artists who have created artworks in both 'Cubism' and 'Surrealism' genres.
select name from artists a
inner join artworks ar on a.artist_id=ar.artist_id
where genre in('Cubism','Surrealism')
group by genre,name
having count(*)>=2


12. Write a query to find the artworks that have been sold in both January and February 2024.
select title from artworks a
inner join sales s on a.artwork_id=s.artwork_id
where s.sales_date between '2024-01-01' and '2024-02-01'
13. Write a query to display the artists whose average artwork price is higher than every artwork price in the 'Renaissance' genre.
with cte
as
(
select avg(ar.price) as avge,name
from artworks ar
inner join artists a on a.artist_id=ar.artist_id
where genre='Renaissance'
)
select * from cte where avge<all(select ar.price from artworks)
14. Write a query to rank artists by their total sales amount and display the top 3 artists.
with cte 
as
(
select rank() over(order by total_amount  desc) as ranks,name
from sales s
inner join artworks ar on ar.artwork_id=s.artwork_id
inner join artists a on a.artist_id=ar.artist_id


)
select * from cte 
where ranks<=3

15. Write a query to create a non-clustered index on the `sales` table to improve query performance for queries filtering by `artwork_id`.

 create clustered index artwork_id
on sales
### Section 3: 3 Marks Questions

16.  Write a query to find the average price of artworks for each artist and only include artists whose average artwork price is higher than the overall average artwork price.
with cte
as
(
select name,avg(price) as inavg from artworks ar
inner join artists a on a.artist_id=ar.artist_id
group by name
)
select * from cte
where inavg>(select avg(price) from artworks)
17.  Write a query to create a view that shows artists who have created artworks in multiple genres.

create view multiple
as
(
select name,genre from artists a
inner join artworks ar on a.artist_id=ar.artist_id
group by genre,name
having count(*)>=2
)
select * from multiple
18.  Write a query to find artworks that have a higher price than the average price of artworks by the same artist.
with cte as(
select title,avg(price) as inavg,artist_id from artworks
group by artist_id
)
select * from cte where inavg<all(select price from artworks)

### Section 4: 4 Marks Questions

19.  Write a query to convert the artists and their artworks into JSON format.


GO
SELECT
json_query((
SELECT
a.name AS [name],
a.country AS [country],
a.birth_year AS [birth_year],
(
SELECT
b.title,
b.genre,
b.price
FROM books b
WHERE a.artist_id = b.artist_id
FOR JSON PATH
) AS [genre]
FROM authors a
FOR JSON PATH
))
GO

20.  Write a query to export the artists and their artworks into XML format.


GO
SELECT
a.name AS [@name],
a.country AS [@country],
a.birth_year AS [@birth_year],
(
SELECT
b.title,
b.genre,
b.price
FROM books b
WHERE a.artist_id = b.artist_id
FOR XML PATH('artist')
)
FROM authors a
FOR XML PATH('artwork'), ROOT('artist');
GO


select * from artists
--select * from artworks
--select * from Sales

#### Section 5: 5 Marks Questions

21. Create a stored procedure to add a new sale and update the total sales for the artwork. Ensure the quantity is positive, and use transactions to maintain data integrity.
create procedure new
@totalsales int
@id
as
begin
begin transaction
declare @newsal int
declare @sales_id int

set @newsal=@totalsales
set @sales_id=@id
update artworks
set total_amount=@newsal where sale_id=@sales_id
commit transaction
end
22. Create a multi-statement table-valued function (MTVF) to return the total quantity sold for each genre and use it in a query to display the results.
create function multi_valued()
returns table
begin
create table gen(@a_id int,@genre nvarchar(50),@quantity int)
insert into gen
select artwork_id,genre,sum(quantity) from artworks a
inner join sales s on s.artwork_id=a.artwork_id
group by genre
end
select dbo.multi_valued();
23. Create a scalar function to calculate the average sales amount for artworks in a given genre and write a query to use this function for 'Impressionism'.
create function avg_sales(@nam varchar(50))
returns int
as
begin
select avg(total_amount) as average from sales
inner join artworks a on a.artwork_id=s.artwork_id
where genre='@nam'
return average
end
select * from dbo.avg_sales('Impressionism')
24. Create a trigger to log changes to the `artworks` table into an `artworks_log` table, capturing the `artwork_id`, `title`, and a change description.
create trigger up on artworks
after insert
as
begin
(
create table artworks(@artwork_id int,@title varchar(50),@description varchar(50))
insert into artworks values(1,mona lisa,beforechange)
update artworks set description='after changes'
)
end

25. Write a query to create an NTILE distribution of artists based on their total sales, divided into 4 tiles.


### Normalization (5 Marks)

26. **Question:**
    Given the denormalized table `ecommerce_data` with sample data:

| id  | customer_name | customer_email      | product_name | product_category | product_price | order_date | order_quantity | order_total_amount |
| --- | ------------- | ------------------- | ------------ | ---------------- | ------------- | ---------- | -------------- | ------------------ |
| 1   | Alice Johnson | alice@example.com   | Laptop       | Electronics      | 1200.00       | 2023-01-10 | 1              | 1200.00            |
| 2   | Bob Smith     | bob@example.com     | Smartphone   | Electronics      | 800.00        | 2023-01-15 | 2              | 1600.00            |
| 3   | Alice Johnson | alice@example.com   | Headphones   | Accessories      | 150.00        | 2023-01-20 | 2              | 300.00             |
| 4   | Charlie Brown | charlie@example.com | Desk Chair   | Furniture        | 200.00        | 2023-02-10 | 1              | 200.00             |

Normalize this table into 3NF (Third Normal Form). Specify all primary keys, foreign key constraints, unique constraints, not null constraints, and check constraints.

### ER Diagram (5 Marks)
CREATE TABLE `orders` (
  `id` int,
  `order_date` date,
  `quantity` int,
  KEY `fk` (`id`)
);

CREATE TABLE `transaction ` (
  `T_id` int,
  `date` date,
  `order_total_amount` int,
  KEY `pk` (`T_id`),
  KEY `fk` (`date`, `order_total_amount`)
);

CREATE TABLE `product` (
  `id` int,
  `product_name` varchar(30),
  `category` varchar(30),
  `price` int,
  KEY `fk` (`id`)
);

CREATE TABLE `customer` (
  `id` int,
  `name` varchar(50),
  `email` nvarchar(50),
  FOREIGN KEY (`name`) REFERENCES `orders`(`id`),
  FOREIGN KEY (`email`) REFERENCES `product`(`id`),
  FOREIGN KEY (`id`) REFERENCES `transaction `(`T_id`),
  KEY `pk` (`id`)
);



27. Using the normalized tables from Question 27, create an ER diagram. Include the entities, relationships, primary keys, foreign keys, unique constraints, not null constraints, and check constraints. Indicate the associations using proper ER diagram notation.
