
-- Ordernar na tabela film_actor para ter uma noção dos atores que fizeram os respectivos filmes
SELECT * FROM film_actor
ORDER BY film_id;

SELECT * FROM inventory


--
--
-- Adicionar para essa tabela o nome dos atores e o nome dos filmes para facilitar a vizualização
-- Primeiro passo criar as colunas para isso
--Coluna nome
ALTER TABLE film_actor
ADD nome VARCHAR(45);
--Coluna sobrenome
ALTER TABLE film_actor
ADD sobrenome VARCHAR(45);
--Coluna titulo
ALTER TABLE film_actor
ADD title VARCHAR(255);
--Colocar os nomes dos atores
UPDATE film_actor
SET nome = actor.first_name
FROM actor
where  film_actor.actor_id = actor.actor_id;
--Colocar os sobrenomes
UPDATE film_actor
SET sobrenome = actor.last_name
FROM actor
where  film_actor.actor_id = actor.actor_id;
--Colocar os titulos
UPDATE film_actor
SET title = film.title
FROM film
WHERE film_actor.film_id = film.film_id

--
--
--Identificar o top 5 atores que mais fizeram filmes de duas formas diferentes
--Primeiro pela tabela criada
SELECT nome, sobrenome, COUNT(film_id) as total_filmes
FROM film_actor
GROUP BY nome, sobrenome
ORDER BY total_filmes DESC
LIMIT 5;
--Segundo modo buscando as informações entre as tabelas
SELECT actor.first_name, actor.last_name, COUNT(film_actor.actor_id) AS total_filmes
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
GROUP BY actor.first_name, actor.last_name
ORDER BY total_filmes DESC
LIMIT 5;
--Identificar os filmes que tiveram menos atores participando
--Primeiro pela tabela criada e apenas buscar filmes com mais de um ator
SELECT title, COUNT(actor_id) as total_atores
FROM film_actor
GROUP BY title
HAVING COUNT(actor_id) > 1
ORDER BY total_atores
LIMIT 5;
--Segundo modo buscando as informações entre as tabelas mas dessa vez todos os casos que tiveram apenas um ator
SELECT film.title,COUNT(film_actor.actor_id) AS total_atores
FROM film
JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title
HAVING COUNT(film_actor.actor_id) = 1;

--
--Agora algumas interações entre as tabelas de categorias atores e filmes
--Primeiro organizar os tipos de categoria pela quantidade de filmes produzidos
SELECT category.name, COUNT(film_category.category_id) AS total_categoria
FROM category
JOIN film_category ON category.category_id = film_category.category_id
GROUP BY category.name
ORDER BY total_categoria DESC;
--Identificar os atores que mais fizeram filmes de esportes TOP 10
SELECT film_actor.nome, film_actor.sobrenome, COUNT(film_category.category_id) AS total_filmes_esporte
FROM film_category
JOIN category ON film_category.category_id = category.category_id
JOIN film_actor ON film_category.film_id = film_actor.film_id
JOIN actor ON film_actor.actor_id = actor.actor_id
WHERE category.name = 'Sports'
GROUP BY film_actor.nome, film_actor.sobrenome
ORDER BY total_filmes_esporte DESC
LIMIT 10;

--
--Passa para os filmes e realizar algumas analises
--Primeiro a o TOP 10 Filmes mais caros para repor e os com a taxa de aluguel mais barato
SELECT title, replacement_cost
FROM film
ORDER BY replacement_cost DESC
Limit 10;

SELECT title, rental_rate
FROM film
ORDER BY rental_rate
Limit 10;

--Media da taxa de reposição por categoria
SELECT category.name, ROUND(AVG(film.replacement_cost), 2)	AS custo_reposição
FROM film
JOIN film_category ON film.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY custo_reposição DESC;


--
-- Em inventory identificar a quantidade de filmes por nome
SELECT film.title, COUNT(inventory.film_id) AS quantidade
FROM film
JOIN inventory ON film.film_id = inventory.film_id
GROUP BY film.title
ORDER BY quantidade DESC;

--
--Identificar qual funcionario gerou mais lucro e qual o cliente que tambem mais gastou e alem disso qual o cliente que mais vezes vem a loja
--Identificar o funcionario
SELECT staff.username, SUM(payment.amount) AS valor
FROM payment
JOIN staff ON payment.staff_id = staff.staff_id
GROUP BY staff.username;

ALTER TABLE payment
ADD mes VARCHAR(50)

SELECT * FROM payment

ALTER TABLE payment
DROP COLUMN mes

--Identificar o cliente que mais gastou
SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS valor
FROM payment
JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER BY valor DESC;

--Identificar qual cliente mais alugou filmes
SELECT customer.first_name, customer.last_name, COUNT(rental.rental_id) quantidade
from rental
JOIN customer ON rental.customer_id = customer.customer_id
GROUP BY customer.first_name, customer.last_name
ORDER BY quantidade DESC
LIMIT 1;

--
-- Identificar qual filme mais foi alugado e qual a categoria favorita dos clientes
--TOP 10 Filmes mais alugados
SELECT film.title, COUNT (rental.rental_id) as quantidade
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film ON inventory.film_id = film.film_id
GROUP BY film.title
ORDER BY quantidade DESC
LIMIT 10;

--TOP 1 Categoria
SELECT category.name, COUNT (rental.rental_id) as quantidade
FROM rental
JOIN inventory ON rental.inventory_id = inventory.inventory_id
JOIN film_category ON inventory.film_id = film_category.film_id
JOIN category ON film_category.category_id = category.category_id
GROUP BY category.name
ORDER BY quantidade DESC
LIMIT 1;

--
--Criar uma tabela para outras informações do clientes
CREATE TABLE customer_infos();
--Criar as colunas de id do cliente, nome e sobrenome, categoria favorita e taxa de retorno
ALTER TABLE customer_infos
ADD COLUMN customer_id INTEGER;

ALTER TABLE customer_infos
ADD COLUMN first_name VARCHAR(45);

ALTER TABLE customer_infos
ADD COLUMN last_name VARCHAR(45);

INSERT INTO customer_infos
SELECT customer_id, first_name, last_name FROM customer;

ALTER TABLE customer_infos
ADD COLUMN taxa_retorno NUMERIC(5,2);

ALTER TABLE customer_infos
ADD COLUMN total_locacoes INTEGER;

ALTER TABLE customer_infos
ADD COLUMN locacoes_atrasadas INTEGER;


--Identificar qual os clientes que mais tem locações pendentes
--Primeiro criar uma coluna na tabela rental para armazenar cada um dos retornos
ALTER TABLE rental
ADD COLUMN devolução VARCHAR(15);

--Agora criar a função para caso tenha sido devolvido identificar como OK e caso não estar Pendente
UPDATE rental
SET devolução = CASE
	WHEN rental_date IS NULL OR return_date IS NULL THEN 'Pendente'
	ELSE 'OK'
	END;
--Criar uma formula para identificar quais filmes foram entregues fora do prazo e qual cliente de retorno por cliente

ALTER TABLE rental
ADD COLUMN dias INTEGER;

ALTER TABLE rental
ADD COLUMN prazo INTEGER;

ALTER TABLE rental
ADD COLUMN atraso VARCHAR;


UPDATE rental
SET dias = EXTRACT(DAY FROM return_date -  rental_date);

SELECT rental_date , return_date, dias FROM rental

SELECT * FROM rental
ORDER BY inventory_id

UPDATE rental
SET prazo = film.rental_duration
FROM inventory
JOIN film ON inventory.film_id = film.film_id
WHERE inventory.inventory_id = rental.inventory_id;

UPDATE rental
SET atraso = CASE
    WHEN dias > prazo or devolução = 'Pendente' THEN 'sim'
    ELSE 'não'
END;

UPDATE customer_infos
SET total_locacoes = (
	SELECT COUNT(*)
	FROM rental
	WHERE rental.customer_id = customer_infos.customer_id)
	
UPDATE customer_infos
SET locacoes_atrasadas = (
	SELECT COUNT(*)
	FROM rental
	WHERE rental.customer_id = customer_infos.customer_id
	AND atraso = 'sim')
	

UPDATE customer_infos
SET taxa_retorno = ((total_locacoes - locacoes_atrasadas)*100)/total_locacoes;
	
SELECT * FROM customer_infos
ORDER BY customer_id;

DELETE FROM customer_infos
WHERE first_name IS NULL


