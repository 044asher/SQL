-- Составить SQL запросы, которые используют:
-- JOIN (LEFT, RIGHT, INNER, OUTER):

SELECT users.user_name, shopping_cart.products
FROM users INNER JOIN shopping_cart ON users.user_name = shopping_cart.user_name;

    SELECT * FROM users
LEFT JOIN orders ON users.user_id = orders.user_id;

    SELECT users.user_name, users.surname, user_details.address, user_details.phone_number FROM users
RIGHT JOIN user_details ON users.user_id = user_details.user_id;

SELECT * FROM users
LEFT JOIN orders ON users.user_id = orders.user_id
UNION
SELECT * FROM users RIGHT JOIN orders ON users.user_id = orders.user_id;

-- Подзапросы - позволяют выполнять сложные операции, используя результаты одного запроса как часть другого.

SELECT *
FROM users
WHERE user_id IN (SELECT user_id FROM orders);

SELECT users.*, (SELECT COUNT(*) FROM orders WHERE orders.user_id = users.user_id) AS order_count
FROM users;

SELECT *
FROM users
WHERE EXISTS (SELECT 1 FROM orders WHERE orders.user_id = users.user_id);

SELECT users.*, latest_order.*
FROM users
         LEFT JOIN orders latest_order ON users.user_id = latest_order.user_id
    AND latest_order.order_id = (SELECT MAX(order_id) FROM orders WHERE user_id = users.user_id);

-- Кореляционные подзапросы - это подзапрос, который ссылается на столбцы из внешнего запроса.

SELECT user_id, user_name,
       (SELECT SUM(total_amount) FROM orders WHERE orders.user_id = users.user_id) AS total_order_amount
FROM users;

-- Агрегационные функции - предназначены для выполнения операций над набором значений и возвращения единственного результата.

SELECT AVG(age) AS average_age
FROM users;

SELECT MIN(age) AS youngest_user_age
FROM users;

SELECT MAX(total_amount) AS highest_order_amount
FROM orders;


-- Вывести все записи из таблицы Users.
    SELECT * FROM users;

-- Вывести список пользователей, у которых username содержит букву "A".
SELECT * FROM Users WHERE user_name LIKE '%а%';
SELECT * FROM Users WHERE user_name LIKE '%а%' OR user_name LIKE 'А%';

-- Вывести информацию о продуктах с ценой выше 100.
    SELECT * FROM products WHERE price > 100;

-- Вывести пользователей, у которых отсутствуют дополнительные данные (User_Details).
SELECT * FROM users
                  LEFT JOIN user_details ON users.user_id = user_details.user_id
WHERE user_details.user_id IS null;

-- Вывести список продуктов и количество пользователей, добавивших их в корзину.
SELECT products.product_id,
       products.product_name,
       COUNT(shopping_cart.user_name) AS count
FROM
    Products
    LEFT JOIN
    Shopping_Cart ON CONCAT(',', shopping_cart.products, ',') LIKE CONCAT('%, ', products.product_name, ',%')
    OR CONCAT(',', shopping_cart.products, ',') LIKE CONCAT('%,', products.product_name, ',%')
GROUP BY
    products.product_id, products.product_name;

-- Найдите общую сумму заказов для каждого пользователя.
SELECT users.user_id,
       users.user_name,
       SUM(orders.total_amount) AS total_orders_amount
FROM
    Users
        LEFT JOIN
    Orders ON users.user_id = orders.user_id
GROUP BY
    users.user_id;

-- Вывести список продуктов, которые имеются в корзине пользователя (по id).
SELECT
    users.user_name,
    shopping_cart.products
FROM
    Users
        LEFT JOIN
    Shopping_Cart ON users.user_name = shopping_cart.user_name
WHERE
    users.user_name = 'Коля';

-- Вывести список пользователей, у которых есть заказы на сумму более 500.
SELECT DISTINCT
    users.user_id,
    users.user_name
FROM
    Users
        JOIN
    Orders ON users.user_id = orders.user_id
WHERE
    orders.total_amount > 500;

-- Вывести пользователя, который купил больше всего товаров.
SELECT
    users.user_id,
    users.user_name,
    COUNT(DISTINCT SUBSTRING_INDEX(SUBSTRING_INDEX(orders.product_names, ', ', numbers.n), ', ', -1)) AS total_products_bought
FROM
    Users
        JOIN
    Orders ON users.user_id = orders.user_id
        JOIN (
        SELECT 1 n UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5
    ) numbers ON CHAR_LENGTH(orders.product_names) - CHAR_LENGTH(REPLACE(orders.product_names, ', ', '')) >= n - 1
GROUP BY
    users.user_id, users.user_name
ORDER BY
    total_products_bought DESC
    LIMIT 1;

-- Вывести список 10-ти самых дорогих товаров.
SELECT *
FROM products
ORDER BY
    price DESC
    LIMIT 5;

-- Вывести список товаров с ценой выше средней.
SELECT
    *
FROM
    Products
WHERE
    price > (SELECT AVG(price)
             FROM Products);

-- Вывести список пользователей, у которых суммарная стоимость продуктов в корзине превышает
-- среднюю стоимость продуктов в корзине всех пользователей.
SELECT Users.user_id, Users.user_name,
       SUM(Shopping_Cart.total_amount) AS total_cost
FROM Users
         JOIN Shopping_Cart ON Users.user_name = Shopping_Cart.user_name
GROUP BY Users.user_id, Users.user_name
HAVING total_cost > 0
   AND total_cost > (SELECT AVG(Shopping_Cart.total_amount)
                     FROM Shopping_Cart);

-- Вывести пользователей, у которых все продукты в корзине имеют цену выше 100.
CREATE TEMPORARY TABLE IF NOT EXISTS temp_products
SELECT user_name,
       SUBSTRING_INDEX(SUBSTRING_INDEX(products, ', ', numbers.n), ', ', -1) as product
FROM
    (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) as numbers JOIN shopping_cart
                                                                                          ON CHAR_LENGTH(products) - CHAR_LENGTH(REPLACE(products, ', ', '')) >= numbers.n - 1
ORDER BY
    user_name, n;
SELECT user_name
FROM temp_products JOIN products ON temp_products.product = products.product_name
GROUP BY user_name
HAVING MIN(products.price) > 100;

-- Вывести список продуктов, которые есть в корзине у всех пользователей.
SELECT products.product_id, products.product_name
FROM products
WHERE EXISTS(
    SELECT 1 from users
                      LEFT join shopping_cart on users.user_name = shopping_cart.user_name WHERE FIND_IN_SET(products.product_name, shopping_cart.products));

-- Вывести информацию о пользователях, у которых в корзине присутствуют продукты с общим количеством более 10 единиц.
SELECT user_id, users.user_name, shopping_cart.quantity
FROM Users
         JOIN Shopping_Cart ON users.user_name = shopping_cart.user_name AND quantity > 3;

-- Вывести пользователя, у которого сумма всех заказов превышает сумму заказов любого другого пользователя.
SELECT Users.user_id, Users.user_name
FROM Users
         JOIN (
    SELECT user_id, COUNT(DISTINCT order_id) AS total_orders
    FROM Orders
    GROUP BY user_id
) UserTotalOrders ON Users.user_id = UserTotalOrders.user_id
WHERE UserTotalOrders.total_orders > ALL (
    SELECT COUNT(DISTINCT order_id) AS other_user_orders
    FROM Orders
    WHERE Users.user_id <> Orders.user_id
    GROUP BY Orders.user_id
);

-- Вывести список пользователей, у которых количество продуктов в корзине превышает среднее количество продуктов в корзине всех пользователей.
SELECT Users.user_id, Users.user_name
FROM Users
         JOIN (
    SELECT user_name, SUM(quantity) AS total_quantity_in_cart
    FROM Shopping_Cart
    GROUP BY user_name
) UserCartTotal ON Users.user_name = UserCartTotal.user_name
WHERE UserCartTotal.total_quantity_in_cart > (
    SELECT AVG(total_quantity_in_cart)
    FROM (
             SELECT SUM(quantity) AS total_quantity_in_cart
             FROM Shopping_Cart
             GROUP BY user_name
         ) AS AvgUserCart
);

-- Вывести продукты, которые есть в корзине только одного пользователя.
CREATE TEMPORARY TABLE IF NOT EXISTS temp_products
SELECT user_name,
       SUBSTRING_INDEX(SUBSTRING_INDEX(products, ', ', numbers.n), ', ', -1) as product
FROM
    (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) as numbers JOIN shopping_cart
                                                                                          ON CHAR_LENGTH(products) - CHAR_LENGTH(REPLACE(products, ', ', '')) >= numbers.n - 1
ORDER BY
    user_name, n;
SELECT product
FROM temp_products
GROUP BY product
HAVING count(user_name) = 1;

-- Вывести информацию о продукте с наибольшей суммарной стоимостью в корзинах пользователей.
CREATE TEMPORARY TABLE IF NOT EXISTS temp_products
SELECT user_name,
       SUBSTRING_INDEX(SUBSTRING_INDEX(products, ', ', numbers.n), ', ', -1) as product
FROM
    (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4) as numbers JOIN shopping_cart
                                                                                          ON CHAR_LENGTH(products) - CHAR_LENGTH(REPLACE(products, ', ', '')) >= numbers.n - 1
ORDER BY
    user_name, n;
SELECT product, sum(products.price) as total_price FROM temp_products
                                                            join products on temp_products.product = products.product_name
GROUP by product
ORDER by total_price DESC
    LIMIT 1;

--Вывести пользователей, у которых суммарная стоимость заказов превышает 1000, и количество заказов более 3
SELECT users.user_id, users.user_name, sum(orders.total_amount) as total, count(orders.order_id) as counting
FROM users
         JOIN orders on users.user_id = orders.user_id
GROUP BY users.user_id, users.user_name
HAVING sum(orders.total_amount) > 1000 and count(orders.order_id) >= 3;
