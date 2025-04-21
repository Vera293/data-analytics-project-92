WITH AgeCategories AS (
    SELECT
        CASE
            WHEN age BETWEEN 16 AND 25 THEN '16-25'
            WHEN age BETWEEN 26 AND 40 THEN '26-40'
            ELSE '40+'
        END AS age_category,-- Создаем новое поле "age_category" на основе возраста
        COUNT(*) AS age_count-- Считаем количество записей в каждой категории
    FROM customers
    GROUP BY age_category-- Группируем результаты по категориям возраста
    ORDER BY age_category-- Сортируем результаты по возрастанию категорий
)
SELECT
    age_category, -- Выбираем категорию возраста
    age_count-- Выбираем количество покупателей в каждой категории
FROM AgeCategories;-- Берем данные из CTE (Common Table Expression) "AgeCategories"

SELECT 
    TO_CHAR(sale_date, 'YYYY-MM') AS selling_month, -- Преобразует дату в формат YYYY-MM
    COUNT(DISTINCT customer_id) AS total_customers, -- Считает уникальных покупателей в каждом месяце
    SUM(quantity) AS income -- СУММИРУЕТ КОЛИЧЕСТВО ТОВАРОВ
FROM 
    sales
GROUP BY 
    selling_month-- Группируем по месяцам
ORDER BY 
    selling_month ASC;-- Сортируем по месяцам в возрастающем порядке

WITH FirstPurchase AS (
    SELECT
        customer_id,-- Выбираем ID покупателя
        MIN(sale_date) AS first_purchase_date-- Находим минимальную (самую раннюю) дату продажи для каждого покупателя
    FROM sales
    JOIN products ON sales.product_id = products.product_id -- Делаем JOIN с таблицей products, используя product_id
    WHERE price = 0-- Фильтруем продажи, где цена товара равна 0 (акционные товары)
    GROUP BY customer_id-- Группируем результаты по customer_id, чтобы найти минимальную дату для каждого покупателя
)
SELECT
    c.first_name || ' ' || c.last_name AS customer,-- Конкатенируем имя и фамилию покупателя из таблицы customers
    fp.first_purchase_date AS sale_date,-- Выбираем дату первой покупки из CTE FirstPurchase
    e.first_name || ' ' || e.last_name AS seller-- Конкатенируем имя и фамилию продавца из таблицы employees
FROM FirstPurchase fp
JOIN customers c ON fp.customer_id = c.customer_id -- Соединяем FirstPurchase с customers по customer_id
JOIN sales s ON fp.customer_id = s.customer_id AND fp.first_purchase_date = s.sale_date-- Соединяем с sales, используя customer_id и дату первой покупки
JOIN employees e ON s.sales_person_id = e.employee_id-- Соединяем с employees по sales_person_id
ORDER BY c.customer_id;-- Сортируем результат по customer_id


