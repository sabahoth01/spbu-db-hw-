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

-- VIEWS
CREATE VIEW employee_details AS
SELECT
    e.emp_id,
    e.name AS employee_name,
    e.surname,
    e.date_of_birth,
    e.education,
    e.hiring_date,
    p.name AS position_name,
    p.salary_rub,
    p.rank
FROM employee e
JOIN position p ON e.pos_id = p.pos_id;
SELECT * FROM employee_details
         WHERE salary_rub > 80000
         LIMIT 5;

CREATE VIEW mission_summary AS
SELECT
    m.miss_id,
    m.start_date_and_time,
    m.end_date_and_time,
    c.name AS campaign_name,
    c.customer,
    t.name AS transport_name
FROM
    mission m
JOIN
    campaign c ON m.camp_id = c.camp_id
LEFT JOIN
    missions_transport mt ON m.miss_id = mt.miss_id
LEFT JOIN
    transport t ON mt.trans_id = t.trans_id;

SELECT * FROM mission_summary;

