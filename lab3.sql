-- Создание временной таблицы high_sales_products
CREATE TEMP TABLE high_sales_products AS
SELECT product_id, SUM(quantity) AS total_quantity
FROM sales
WHERE sale_date >= NOW() - INTERVAL '7 days'
GROUP BY product_id
HAVING SUM(quantity) > 10;

-- Вывод данных из временной таблицы
SELECT * FROM high_sales_products;

-- CTE для подсчета общего и среднего количества продаж для каждого сотрудника за последние 30 дней
WITH employee_sales_stats AS (
    SELECT employee_id,
           COUNT(*) AS total_sales,
           AVG(quantity) AS avg_sales
    FROM sales
    WHERE sale_date >= NOW() - INTERVAL '30 days'
    GROUP BY employee_id
)
SELECT employee_id, total_sales
FROM employee_sales_stats
WHERE total_sales > (SELECT AVG(total_sales) FROM employee_sales_stats);

-- Замените <specific_manager_id> на идентификатор менеджера, для которого вы хотите показать подчиненных
WITH RECURSIVE employee_hierarchy AS (
    SELECT employee_id, name, manager_id
    FROM employees
    WHERE manager_id = 1

    UNION ALL

    SELECT e.employee_id, e.name, e.manager_id
    FROM employees e
    INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
SELECT * FROM employee_hierarchy;

WITH monthly_sales AS (
    SELECT product_id,
           SUM(quantity) AS total_sales,
           DATE_TRUNC('month', sale_date) AS sales_month
    FROM sales
    WHERE sale_date >= DATE_TRUNC('month', NOW()) - INTERVAL '1 month'
    GROUP BY product_id, sales_month
)
SELECT product_id, total_sales, sales_month
FROM (
    SELECT product_id, total_sales, sales_month,
           ROW_NUMBER() OVER (PARTITION BY sales_month ORDER BY total_sales DESC) AS rank
    FROM monthly_sales
) ranked_sales
WHERE rank <= 3;


-- Создание индекса для таблицы sales по полям employee_id и sale_date
CREATE INDEX idx_employee_sale_date ON sales(employee_id, sale_date);

-- Анализ запроса для нахождения общего количества проданных единиц каждого продукта
EXPLAIN ANALYZE
SELECT product_id, SUM(quantity) AS total_units
FROM sales
GROUP BY product_id;

