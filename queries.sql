SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS seller,  -- Полное имя продавца
    COUNT(s.sales_id) AS operations,                   -- Количество операций (продаж)
    SUM(p.price * s.quantity) AS income                -- Общий доход (сумма стоимости всех продуктов)
FROM employees e                                      -- Таблица сотрудников
JOIN sales s ON e.employee_id = s.sales_person_id      -- Соединяем сотрудников с продажами по employee_id
JOIN products p ON s.product_id = p.product_id        -- Соединяем товары с продажами по product_id
GROUP BY e.employee_id, e.first_name, e.last_name     -- Группируем по сотрудникам
ORDER BY income DESC                                  -- Сортируем по доходу в обратном порядке (от большего к меньшему)
LIMIT 10;                                             -- Ограничиваемся первыми десятью результатами

WITH AverageSales AS (                                     -- Вспомогательное представление (CTE)
    SELECT
        s.sales_person_id,                                -- id продавца
        e.first_name || ' ' || e.last_name AS seller,     -- Полное имя продавца
        AVG(s.quantity * p.price) AS avg_sale             -- Средняя стоимость одной продажи
    FROM sales s                                          -- Таблица продаж
    JOIN employees e ON s.sales_person_id = e.employee_id -- Связываем сотрудников с продажами
    JOIN products p ON s.product_id = p.product_id       -- Связываем товары с продажами
    GROUP BY s.sales_person_id, e.first_name, e.last_name -- Группируем по продавцам
),
OverallAverage AS (                                        -- Второе вспомогательное представление
    SELECT AVG(avg_sale) AS overall_avg                   -- Общая средняя стоимость продажи
    FROM AverageSales                                      -- Берём среднее из предыдущей CTE
)
SELECT
    seller,                                               -- Имя продавца
    ROUND(avg_sale) AS average_income                      -- Округлённая средняя выручка
FROM AverageSales                                         -- База данных из предыдущего CTE
WHERE avg_sale < (SELECT overall_avg FROM OverallAverage)  -- Только продавцы с меньшей средней выручкой
ORDER BY average_income ASC;                               -- Сортируем по средней выручке (от наименьшей к наибольшей)


SELECT
    CONCAT(TRIM(e.first_name), ' ', TRIM(e.last_name)) AS seller,  -- Полное имя продавца
    CASE EXTRACT(isodow FROM s.sale_date)                       -- Определение дня недели
        WHEN 1 THEN 'monday'                                   -- Номер дня недели по стандартам ISO
        WHEN 2 THEN 'tuesday'
        WHEN 3 THEN 'wednesday'
        WHEN 4 THEN 'thursday'
        WHEN 5 THEN 'friday'
        WHEN 6 THEN 'saturday'
        ELSE 'sunday'
    END AS day_of_week,                                        -- Название дня недели
    FLOOR(SUM(p.price * s.quantity)) AS income                  -- Суммарный доход за день
FROM sales s                                                   -- Таблица продаж
JOIN employees e ON s.sales_person_id = e.employee_id          -- Соединяем сотрудников с продажами
JOIN products p ON s.product_id = p.product_id                -- Соединяем товары с продажами
GROUP BY e.first_name, e.last_name, EXTRACT(isodow FROM s.sale_date)  -- Группируем по продавцам и дням недели
ORDER BY EXTRACT(isodow FROM s.sale_date), seller;             -- Сортируем по дням недели и продавцам
