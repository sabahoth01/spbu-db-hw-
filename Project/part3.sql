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

