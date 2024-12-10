-- Data normalization
-- Step 1: `employee_base`
CREATE TABLE employee_base (
    emp_id INTEGER NOT NULL REFERENCES employee ON DELETE CASCADE,
    base_id INTEGER NOT NULL REFERENCES base ON DELETE SET NULL,
    PRIMARY KEY (emp_id, base_id)
);

-- Step 2: Migrate existing data (if `base_id` column in `employee` is populated).. миграция данных из employee
INSERT INTO employee_base (emp_id, base_id)
SELECT emp_id, base_id
FROM employee
WHERE base_id IS NOT NULL;

-- Step 3: Remove the `base_id` column from the `employee` table
ALTER TABLE employee
DROP COLUMN base_id;

SELECT * FROM employee
LIMIT 2;-- проверка если миграция успешна пошла

