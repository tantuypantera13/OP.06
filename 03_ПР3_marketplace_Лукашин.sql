-- ============================================================
-- Практическая работа № 3. ОП.06 Основы проектирования баз данных
-- Студент: Лукашин Елисей Андреевич, группа ИСП-211
-- Предметная область: маркетплейс товаров для дома и сада «ДомСад»
-- СУБД: PostgreSQL 16
-- ============================================================

CREATE TABLE sellers (
    id           SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    inn          VARCHAR(12),
    rating       DECIMAL(3,2)
);

CREATE TABLE products (
    id           SERIAL PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    seller_id    INT,
    price        DECIMAL(10,2),
    stock        INT
);

CREATE TABLE customers (
    id        SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email     VARCHAR(100),
    phone     VARCHAR(20)
);

CREATE TABLE orders (
    id          SERIAL PRIMARY KEY,
    customer_id INT,
    product_id  INT,
    quantity    INT,
    total       DECIMAL(10,2),
    order_date  DATE
);

-- Заполнение с нарушениями ссылочной целостности
INSERT INTO sellers (company_name, inn, rating) VALUES
    ('ООО «ДомСад»', '771234567890', 4.6),
    ('ИП Соколова М.В.', '771987654322', 4.4),
    ('ООО «МебельГрад»', '771555444334', 4.1),
    ('ООО «Садовый Мир»', '771111222334', 3.9),
    ('ООО «Дачный сезон»', '771777888999', 0.0);

INSERT INTO products (product_name, seller_id, price, stock) VALUES
    ('Кресло офисное Comfort', 1, 12900, 40),
    ('Стол письменный Nord', 1, 18900, 12),
    ('Газонокосилка GreenCut', 2, 24900, 9),
    ('Триммер GrassLine', 2, 6900, 25),
    ('Шкаф-купе 2-дверный', 3, 34900, 7),
    ('Комплект садовой мебели', 4, 21900, 11),
    ('Светильник-торшер без продавца', 888, 3400, 6);

INSERT INTO customers (full_name, email, phone) VALUES
    ('Абрамов Кирилл Юрьевич', 'abramov@mail.ru', '+7-999-101-20-30'),
    ('Мельникова Елена Павловна', 'melnikova@mail.ru', '+7-999-202-30-40'),
    ('Костина Наталья Владимировна', 'kostina@mail.ru', '+7-999-303-40-50'),
    ('Титов Дмитрий Олегович', 'titov@mail.ru', '+7-999-404-50-60');

INSERT INTO orders (customer_id, product_id, quantity, total, order_date) VALUES
    (1, 1, 1, 12900, '2026-10-02'),
    (1, 3, 1, 24900, '2026-10-03'),
    (2, 2, 1, 18900, '2026-10-04'),
    (3, 5, 1, 34900, '2026-10-05'),
    (3, 6, 2, 43800, '2026-10-06'),
    (4, 4, 2, 13800, '2026-10-07'),
    (888, 2, 1, 18900, '2026-10-08');

-- ============================================================
-- Задания 4-10
-- ============================================================

-- 4. LEFT JOIN: все товары с продавцами
SELECT p.id, p.product_name, p.price, s.company_name
FROM products AS p
LEFT JOIN sellers AS s ON s.id = p.seller_id
ORDER BY p.id;

-- 5. RIGHT JOIN: все продавцы с товарами
SELECT s.id, s.company_name, p.product_name, p.price
FROM products AS p
RIGHT JOIN sellers AS s ON s.id = p.seller_id
ORDER BY s.id;

-- 6.1. Товары без продавцов
SELECT p.id, p.product_name, p.seller_id
FROM products AS p
LEFT JOIN sellers AS s ON s.id = p.seller_id
WHERE s.id IS NULL;

-- 6.2. Продавцы без товаров
SELECT s.id, s.company_name
FROM products AS p
RIGHT JOIN sellers AS s ON s.id = p.seller_id
WHERE p.id IS NULL;

-- 6.3. Заказы без покупателей
SELECT o.id, o.customer_id, o.total
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
WHERE c.id IS NULL;

-- 6.4. Все несоответствия (FULL JOIN)
SELECT p.id AS product_id, p.product_name, p.seller_id,
       s.id AS seller_key, s.company_name
FROM products AS p
FULL JOIN sellers AS s ON s.id = p.seller_id
WHERE p.id IS NULL OR s.id IS NULL
ORDER BY p.id, s.id;

-- 7. Восстановление целостности
-- Способ 1: удаление
DELETE FROM products WHERE seller_id NOT IN (SELECT id FROM sellers);
-- Способ 2: исправление ссылки
UPDATE products SET seller_id = 1 WHERE seller_id = 888;
-- Способ 3: восстановление записи продавца
INSERT INTO sellers (id, company_name, inn, rating)
VALUES (888, 'Архивный продавец', '000000000000', 0.00);

-- 8. Аналитические запросы
SELECT p.product_name, p.price, s.company_name, s.rating
FROM products AS p
INNER JOIN sellers AS s ON s.id = p.seller_id
ORDER BY s.rating DESC, p.price;

SELECT s.company_name, COUNT(p.id) AS products_count
FROM sellers AS s
LEFT JOIN products AS p ON p.seller_id = s.id
GROUP BY s.id, s.company_name
ORDER BY products_count DESC;

SELECT c.full_name, COUNT(o.id) AS orders_count,
       COALESCE(SUM(o.total), 0) AS total_sum
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.full_name
ORDER BY total_sum DESC;

SELECT p.product_name, p.price
FROM products AS p
LEFT JOIN orders AS o ON o.product_id = p.id
WHERE o.id IS NULL;

SELECT c.full_name, c.email
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
WHERE o.id IS NULL;