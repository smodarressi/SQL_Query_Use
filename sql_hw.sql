-- use sakila database command
USE sakila;

-- 1a. get first name and last name co0lumns from actor
SELECT first_name, last_name from actor;

-- 1b. Use 1a in a single column in upper case letters. Name the column `Actor Name`.
-- values are already upper case, but added upper function anyway
SELECT upper(concat(first_name, ' ', last_name)) as 'Actor Name' from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT actor_id, first_name, last_name from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`
-- by default mysql is case-insensitive
SELECT * from actor where last_name like '%gen%';

-- 2c. Find all actors whose last names contain the letters `LI`. Order the rows by last name and first name, in that order
-- acscending in this case is default, example is order by last_name asc, first_name asc
SELECT * from actor where last_name like '%li%' order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the countries: Afghanistan, Bangladesh, and China
SELECT country_id, country from country where country IN ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor add description blob;
SELECT * from actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor drop column description;
SELECT * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, count(last_name) from actor group by last_name having count(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
SELECT * from actor where first_name = 'Groucho' and last_name='Williams';
update actor set first_name = 'HARPO' where first_name = 'Groucho' and last_name='Williams';
SELECT * from actor where first_name = 'Harpo' and last_name='Williams';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
SELECT * from actor where first_name = 'Harpo';
update actor set first_name = 'GROUCHO' where first_name = 'Harpo' and last_name='Williams';
SELECT * from actor where first_name = 'Groucho' and last_name='Williams';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address; 

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`

-- select count(*) from staff;
-- I use the above if I want the count to make sure I got every staff listed
SELECT staff.first_name, staff.last_name, address.address 
from staff join address where address.address_id = staff.address_id;


-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.

-- check on this to make sure this is correct

SELECT payment.staff_id, SUM(payment.amount) AS 'total transactions sum', payment.payment_date 
FROM payment JOIN staff ON payment.staff_id = staff.staff_id
WHERE (MONTH(payment.payment_date) = 8 AND YEAR(payment.payment_date) = 2005)
GROUP BY payment.staff_id, payment.payment_date;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

SELECT film.film_id, film.title, COUNT(film_actor.actor_id) AS 'Number of Actors'
FROM film INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id, film.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT film.film_id, film.title, COUNT(inventory_id) AS 'Existing Inventory'
FROM film JOIN inventory ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible'
GROUP BY film.film_id, film.title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. List the customers alphabetically by last name
SELECT customer.first_name, customer.last_name, SUM(payment.amount) As 'Total Paid'
FROM customer JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY customer.last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title 
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
    AND language_id = (SELECT language_id 
                        FROM language  
                        WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name
FROM actor
WHERE actor_id IN (SELECT actor_id 
                    FROM film_actor 
                    WHERE film_id = (SELECT film_id 
                                    FROM film 
                                    WHERE title = 'Alone Trip'));

--7c. You want to run an email marketing campaign in Canada, 
--for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT customer_id, first_name, last_name, email, country.country
FROM customer JOIN address ON address.address_id = customer.address_id
			JOIN city ON city.city_id = address.city_id
            JOIN country ON country.country_id = city.country_id
WHERE country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

select film.film_id, film.title, category.name from film
	join film_category on film.film_id = film_category.film_id
    join category on film_category.category_id = category.category_id
WHERE category.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT film.title, COUNT(rental.inventory_id) AS 'Number Rented' FROM rental
	join inventory on rental.inventory_id = inventory.inventory_id
    join film on film.film_id = inventory.film_id
GROUP BY film.title
ORDER BY COUNT(rental.inventory_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(payment.amount) as 'Total Brought (in Dollars)'
FROM store JOIN staff ON store.store_id = staff.store_id
			JOIN rental ON staff.staff_id = rental.staff_id
            JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country 
FROM store JOIN address ON store.address_id = address.address_id
			JOIN city ON city.city_id = address.city_id
            JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name, SUM(payment.amount)
FROM category JOIN film_category ON category.category_id = film_category.category_id
			JOIN inventory ON film_category.film_id = inventory.film_id
            JOIN rental ON inventory.inventory_id = rental.inventory_id
            JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.name
ORDER BY sum(payment.amount) ASC 
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_genre_rentals AS
	SELECT category.name, SUM(payment.amount)
	FROM category JOIN film_category ON category.category_id = film_category.category_id
			JOIN inventory ON film_category.film_id = inventory.film_id
            JOIN rental ON inventory.inventory_id = rental.inventory_id
            JOIN payment ON rental.rental_id = payment.rental_id
	GROUP BY category.name
	ORDER BY sum(payment.amount) ASC 
	LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_genre_rentals;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_genre_rentals;
