-- CREATE OR REPLACE FUNCTION archive_employee()
--     RETURNS TRIGGER AS $$
--     BEGIN
--         INSERT INTO employees_archive (employee_id, name, position, department, salary)
--         VALUES (OLD.employee_id, OLD.name, OLD.position, OLD.department, OLD.salary);
--         RETURN OLD;
--     END;
--     $$ LANGUAGE plpgsql;
-- CREATE TRIGGER trigger_archive_employee
--     BEFORE DELETE ON employees
--     FOR EACH ROW EXECUTE
--     FUNCTION archive_employee();
-- DELETE FROM employees WHERE employee_id = 120;
-- SELECT * FROM employees
--          WHERE employee_id = 120;
-- SELECT * FROM employees_archive
--          WHERE employee_id = 120;
--
select * from sales_log;
-- Создание таблицы для логирования
CREATE TABLE IF NOT EXISTS sales_log (
    log_id SERIAL PRIMARY KEY,
    operation VARCHAR(10),
    sale_id INT,
    employee_id INT,
    product_id INT,
    quantity INT,
    sale_date DATE,
    log_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Функция для триггера
CREATE OR REPLACE FUNCTION log_sales_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO sales_log (operation, sale_id, employee_id, product_id, quantity, sale_date)
        VALUES ('INSERT', NEW.sale_id, NEW.employee_id, NEW.product_id, NEW.quantity, NEW.sale_date);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO sales_log (operation, sale_id, employee_id, product_id, quantity, sale_date)
        VALUES ('UPDATE', OLD.sale_id, OLD.employee_id, OLD.product_id, OLD.quantity, OLD.sale_date);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO sales_log (operation, sale_id, employee_id, product_id, quantity, sale_date)
        VALUES ('DELETE', OLD.sale_id, OLD.employee_id, OLD.product_id, OLD.quantity, OLD.sale_date);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера
CREATE TRIGGER sales_changes_trigger
AFTER INSERT OR UPDATE OR DELETE ON sales
FOR EACH ROW EXECUTE FUNCTION log_sales_changes();

BEGIN;

INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES (3, 2, 6, '2024-11-22');

COMMIT;


BEGIN;

-- Попробуем вставить запись с несуществующим employee_id
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES (999, 1, 5, '2024-10-22');

-- Это приведет к ошибке, так как employee_id 999 не существует
COMMIT; -- Эта команда не выполнится, если предыдущая вызовет ошибку


CREATE OR REPLACE FUNCTION log_sales_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Inserted sale: %', NEW;
        INSERT INTO sales_log (operation, sale_id, employee_id, product_id, quantity, sale_date)
        VALUES ('INSERT', NEW.sale_id, NEW.employee_id, NEW.product_id, NEW.quantity, NEW.sale_date);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        RAISE NOTICE 'Updated sale: %', OLD;
        INSERT INTO sales_log (operation, sale_id, employee_id, product_id, quantity, sale_date)
        VALUES ('UPDATE', OLD.sale_id, OLD.employee_id, OLD.product_id, OLD.quantity, OLD.sale_date);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Deleted sale: %', OLD;
        INSERT INTO sales_log (operation, sale_id, employee_id, product_id, quantity, sale_date)
        VALUES ('DELETE', OLD.sale_id, OLD.employee_id, OLD.product_id, OLD.quantity, OLD.sale_date);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


-- Теперь давайте создадим операционные триггеры, которые будут выполнять определенные действия при изменении данных в таблице sales.
-- Например, мы можем создать триггер, который будет обновлять общую сумму продаж для каждого продукта при добавлении новой продажи.

-- Создание таблицы для хранения общей суммы продаж по продуктам
CREATE TABLE IF NOT EXISTS product_sales_summary (
    product_id INT PRIMARY KEY,
    total_sales INT DEFAULT 0
);

-- Функция для обновления суммы продаж
CREATE OR REPLACE FUNCTION update_product_sales_summary()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Увеличиваем сумму продаж для продукта
        INSERT INTO product_sales_summary (product_id, total_sales)
        VALUES (NEW.product_id, NEW.quantity)
        ON CONFLICT (product_id)
        DO UPDATE SET total_sales = product_sales_summary.total_sales + NEW.quantity;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Уменьшаем сумму продаж для продукта
        UPDATE product_sales_summary
        SET total_sales = total_sales - OLD.quantity
        WHERE product_id = OLD.product_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера для обновления суммы продаж
CREATE TRIGGER product_sales_summary_trigger
AFTER INSERT OR DELETE ON sales
FOR EACH ROW EXECUTE FUNCTION update_product_sales_summary();

INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES (2, 1, 10, '2024-10-23');

DELETE FROM sales
WHERE sale_id = 1;

-- Проверка итогов продаж

SELECT * FROM product_sales_summary;