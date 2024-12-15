-- 1. Functions
-- Function to Check Employee Qualifications
CREATE OR REPLACE FUNCTION check_qualifications(p_emp_id INT, p_position_name TEXT)
RETURNS BOOLEAN AS $$
DECLARE
    employee_position_name TEXT;
BEGIN
    -- Retrieve the position name for the given employee
    SELECT pos.name INTO employee_position_name
    FROM position pos
    JOIN employee e ON e.pos_id = pos.pos_id
    WHERE e.emp_id = p_emp_id;

    -- If the employee's position matches the given position name, return TRUE
    IF employee_position_name = p_position_name THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to get unmarried, available, and experienced employees (both unmarried and married)
CREATE OR REPLACE FUNCTION get_experienced_available_employees()
RETURNS TABLE (
    emp_id INT,
    employee_name VARCHAR,
    employee_surname VARCHAR,
    availability_status VARCHAR,
    missions_count INT,
    is_married BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.emp_id,
        e.name AS employee_name,
        e.surname AS employee_surname,
        CASE
            WHEN COUNT(m.miss_id) = 0 THEN 'Available'  -- If no missions or all missions ended, employee is available
            ELSE 'Not Available'
        END::VARCHAR AS availability_status,  -- Explicit cast to VARCHAR
        COUNT(m.miss_id)::INTEGER AS missions_count,  -- Cast COUNT to INTEGER to match return type
        e.is_married  -- Add marital status to the result
    FROM employee e
    LEFT JOIN missions_emp me ON e.emp_id = me.emp_id
    LEFT JOIN mission m ON me.miss_id = m.miss_id AND (m.end_date_and_time <= CURRENT_TIMESTAMP OR m.miss_id IS NULL)  -- Ensure the mission has ended or employee has no mission
    GROUP BY e.emp_id, e.name, e.surname, e.is_married  -- Group by employee details (no need to group by mission details)
    HAVING COUNT(m.miss_id) = 0 OR MAX(m.end_date_and_time) <= CURRENT_TIMESTAMP  -- Ensure the employee is available (either no missions or all missions have ended)
    ORDER BY e.is_married,        -- Unmarried employees first
             missions_count DESC, -- Experienced (mission-count) employees first
             availability_status DESC;  -- Available employees first
END;
$$ LANGUAGE plpgsql;
