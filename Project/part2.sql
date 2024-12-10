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

-- MATERIALIZED VIEW
CREATE MATERIALIZED VIEW campaign_profit AS
SELECT
    camp_id,
    name,
    customer,
    earning,
    spending,
    earning - spending AS profit
FROM campaign;
REFRESH MATERIALIZED VIEW campaign_profit;
SELECT * FROM campaign_profit;

-- CTE
WITH employee_health_summary AS (
    SELECT
        e.emp_id,
        e.name,
        e.surname,
        m.height_cm,
        m.weight_kg,
        m.blood
    FROM employee e
    JOIN medical_card m ON e.emp_id = m.emp_id
)
SELECT
    name,
    surname,
    height_cm,
    weight_kg,
    blood,
    CASE
        WHEN height_cm < 160 THEN 'Short'
        WHEN height_cm BETWEEN 160 AND 180 THEN 'Average'
        WHEN height_cm > 180 THEN 'Tall'
    END AS height_category,
    CASE
        WHEN weight_kg < 60 THEN 'Underweight'
        WHEN weight_kg BETWEEN 60 AND 80 THEN 'Normal weight'
        WHEN weight_kg > 80 THEN 'Overweight'
    END AS weight_category
FROM employee_health_summary;

WITH transport_availability AS (
    SELECT
        t.trans_id,
        t.name AS transport_name,
        t.status,
        m.start_date_and_time,
        CURRENT_TIMESTAMP AS current_time
    FROM transport t
    LEFT JOIN missions_transport mt ON t.trans_id = mt.trans_id
    LEFT JOIN mission m ON mt.miss_id = m.miss_id
)
SELECT
    transport_name,
    CASE
        WHEN status = 'OUT_OF_USE' OR status = 'NOT_MAINTAINED' THEN 'Not Available'
        WHEN start_date_and_time > CURRENT_TIMESTAMP THEN 'Available'
        ELSE 'In Use'
    END AS availability_status
FROM transport_availability;
select * from equipment;

-- TEMP_TABLE
CREATE TEMPORARY TABLE temp_emp_missions AS
SELECT
    e.emp_id,
    e.name AS employee_name,
    m.miss_id,
    m.start_date_and_time,
    m.end_date_and_time
FROM employee e
JOIN missions_emp me ON e.emp_id = me.emp_id
JOIN mission m ON me.miss_id = m.miss_id;
SELECT * FROM temp_emp_missions;

-- RECURSIVE
WITH RECURSIVE employee_mission_hierarchy AS (
    -- Base case: Start from a specific employee
    SELECT
        e.emp_id,
        e.name AS employee_name,
        e.surname AS employee_surname,
        m.miss_id,
        m.start_date_and_time,
        m.end_date_and_time
    FROM employee e
    JOIN missions_emp me ON e.emp_id = me.emp_id
    JOIN mission m ON me.miss_id = m.miss_id
    WHERE e.emp_id = 1  -- Start with an employee (e.g., employee_id = 1)

    UNION ALL

    -- Recursive case: Find all missions this employee was assigned to
    SELECT
        e.emp_id,
        e.name AS employee_name,
        e.surname AS employee_surname,
        m.miss_id,
        m.start_date_and_time,
        m.end_date_and_time
    FROM employee e
    JOIN missions_emp me ON e.emp_id = me.emp_id
    JOIN mission m ON me.miss_id = m.miss_id
    JOIN employee_mission_hierarchy emh ON m.miss_id = emh.miss_id  -- Recursively find missions
)
SELECT
    employee_name,
    employee_surname,
    miss_id,
    start_date_and_time,
    end_date_and_time
FROM employee_mission_hierarchy;

WITH RECURSIVE weapon_mission_path AS (
    -- Base case: Start from a specific weapon
    SELECT
        w.weapon_id,
        w.name AS weapon_name,
        m.miss_id,
        m.start_date_and_time,
        m.end_date_and_time
    FROM weapon w
    JOIN equip_weapon ew ON w.weapon_id = ew.weapon_id
    JOIN missions_emp me ON ew.equip_id = me.emp_id
    JOIN mission m ON me.miss_id = m.miss_id
    WHERE w.weapon_id = 1  -- For example, start from a specific weapon

    UNION ALL

    -- Recursive case: Find the next mission where this weapon is used
    SELECT
        w.weapon_id,
        w.name AS weapon_name,
        m.miss_id,
        m.start_date_and_time,
        m.end_date_and_time
    FROM weapon w
    JOIN equip_weapon ew ON w.weapon_id = ew.weapon_id
    JOIN missions_emp me ON ew.equip_id = me.emp_id
    JOIN mission m ON me.miss_id = m.miss_id
    JOIN weapon_mission_path wmp ON m.miss_id = wmp.miss_id  -- Recursively find related missions
)
SELECT
    weapon_name,
    miss_id,
    start_date_and_time,
    end_date_and_time
FROM weapon_mission_path;
