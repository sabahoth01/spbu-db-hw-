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

SELECT check_qualifications(1, 'Security'); -- Returns TRUE or FALSE based on employee qualifications.

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

-- 2. Triggers
--Trigger Function to check medical eligibility for all tasks
CREATE OR REPLACE FUNCTION check_employee_medical_eligibility()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure employee has no medical diseases
    IF EXISTS (
        SELECT 1
        FROM medical_card m
        WHERE m.emp_id = NEW.emp_id
          AND (m.diseases IS DISTINCT FROM 'none' AND m.diseases IS NOT NULL) -- Check diseases
    ) THEN
        RAISE EXCEPTION 'Employee does not meet the medical requirements for being sent to any mission';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Trigger to enforce medical eligibility check when assigning to any task
CREATE TRIGGER employee_medical_check
BEFORE INSERT ON missions_emp
FOR EACH ROW
EXECUTE FUNCTION check_employee_medical_eligibility();

INSERT INTO missions_emp(miss_id, emp_id) VALUES
(16,2);

----

--  close base if it has no employees
CREATE OR REPLACE FUNCTION close_base_if_empty()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if any employee is still assigned to the base
    IF NOT EXISTS (
        SELECT 1
        FROM employee_base eb
        WHERE eb.base_id = OLD.base_id  -- Use OLD.base_id since the row is deleted
    ) THEN
        -- If no employees are assigned, close the base
        UPDATE base
        SET status = 'CLOSED'
        WHERE base_id = OLD.base_id;
    END IF;
    RETURN OLD;  -- Return OLD because it's an AFTER DELETE trigger
END;
$$ LANGUAGE plpgsql;

-- Trigger to check and close the base when an employee is removed from it
CREATE TRIGGER close_base_trigger
AFTER DELETE ON employee_base
FOR EACH ROW
EXECUTE FUNCTION close_base_if_empty();

CREATE TRIGGER close_base_trigger
AFTER DELETE ON employee_base
FOR EACH ROW
-----
-- Trigger for campaigns to automatically refresh materialized view
CREATE OR REPLACE FUNCTION refresh_campaign_profit()
RETURNS TRIGGER AS $$
BEGIN
    -- Refresh the materialized view whenever a campaign is inserted, updated, or deleted
    REFRESH MATERIALIZED VIEW campaign_profit;
    RETURN NULL;  -- No need to modify the inserted/updated/deleted row
END;
$$ LANGUAGE plpgsql;

-- Create the trigger for INSERT, UPDATE, DELETE events on the campaign table
CREATE TRIGGER campaign_change_trigger
AFTER INSERT OR UPDATE OR DELETE
ON campaign
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_campaign_profit();

---
CREATE OR REPLACE FUNCTION check_periods_of_emp_missions() RETURNS trigger AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Retrieve the start and end times for the mission being assigned to the employee
    SELECT start_date_and_time, end_date_and_time INTO start_time, end_time
    FROM mission
    WHERE miss_id = NEW.miss_id;

    -- Check if the employee is already assigned to a mission that overlaps with the new one
    IF EXISTS (
        SELECT 1
        FROM mission m
        JOIN missions_emp me ON m.miss_id = me.miss_id
        WHERE me.emp_id = NEW.emp_id
          AND (m.start_date_and_time, m.end_date_and_time) OVERLAPS (start_time, end_time)
    ) THEN
        RAISE EXCEPTION 'This worker cannot be assigned to a mission as they were on another mission at the time';
    END IF;

    -- Allow the insert if no overlap is found
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_emp_mission_period
BEFORE INSERT ON missions_emp
FOR EACH ROW
EXECUTE FUNCTION check_periods_of_emp_missions();
-------------------
-- Function to update the transport status after an inspection
CREATE OR REPLACE FUNCTION update_transport_status_after_inspection() RETURNS trigger AS $$
BEGIN
    -- Check if the remarks column contains keywords indicating serious damage or accidents
    IF NEW.remarks ILIKE '%damage%' OR NEW.remarks ILIKE '%serious%' OR NEW.remarks ILIKE '%accident%' THEN
        -- If any of these keywords are found, set transport status to OUT_OF_USE
        UPDATE transport
        SET status = 'OUT_OF_USE'  -- Mark the transport as out of use
        WHERE trans_id = NEW.trans_id;
    ELSIF NEW.result = 'PASS' THEN
        -- If inspection passed, mark transport as MAINTAINED
        UPDATE transport
        SET status = 'MAINTAINED'
        WHERE trans_id = NEW.trans_id;
    ELSIF NEW.result = 'FAILED' THEN
        -- If inspection failed, mark transport as NOT_MAINTAINED
        UPDATE transport
        SET status = 'NOT_MAINTAINED'
        WHERE trans_id = NEW.trans_id;
    ELSIF NEW.result = 'PENDING' THEN
        -- If inspection is pending, mark transport as NEED_VERIFICATION
        UPDATE transport
        SET status = 'NEED_VERIFICATION'
        WHERE trans_id = NEW.trans_id;
    END IF;

    -- Return the new inspection record (mandatory for AFTER INSERT trigger)
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Trigger to call the function after an inspection is inserted
CREATE TRIGGER transport_status_after_inspection
AFTER INSERT ON inspection
FOR EACH ROW
EXECUTE FUNCTION update_transport_status_after_inspection();

-- Function to check transport status before adding to mission
CREATE OR REPLACE FUNCTION check_transport_status_before_mission() RETURNS trigger AS $$
BEGIN
    -- Check if the transport status is either VERIFIED or MAINTAINED
    IF NOT EXISTS (
        SELECT 1
        FROM transport
        WHERE trans_id = NEW.trans_id
          AND status IN ('VERIFIED', 'MAINTAINED')  -- Only allow VERIFIED or MAINTAINED status
    ) THEN
        RAISE EXCEPTION 'Transport cannot be added to the mission because its status is not VERIFIED or MAINTAINED.';
    END IF;

    -- If the status is correct, allow the insert
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call the function before adding transport to a mission
CREATE TRIGGER check_transport_status_before_addition
BEFORE INSERT ON missions_transport
FOR EACH ROW
EXECUTE FUNCTION check_transport_status_before_mission();

-- 3. transaction
BEGIN;

-- Step 1: Check if the employee is qualified for the mission
DO $$
DECLARE
    emp_qualified BOOLEAN;
BEGIN
    -- Check qualifications using the function, which returns a boolean

    -- If the result is FALSE, raise an exception
    IF NOT emp_qualified THEN
        RAISE EXCEPTION 'Employee is not qualified for the position.';
    END IF;
END $$;


-- Step 3: Check if the employee is available for the mission (overlap check handled by trigger 'check_emp_mission_period')
-- No action needed here since it's enforced by the trigger.

-- Step 4: Check if the transport assigned to the mission is in a suitable status (MAINTAINED or VERIFIED)
DO $$
DECLARE
    transport_valid BOOLEAN;
BEGIN
    -- Check transport status before assignment

    -- If the result is FALSE, raise an exception
    IF NOT transport_valid THEN
        RAISE EXCEPTION 'Transport is not in an acceptable status.';
    END IF;
END $$;

-- Step 5: Assign the employee to the mission
INSERT INTO missions_emp(miss_id, emp_id)

-- Step 6: Assign transport to the mission (if the status is appropriate)
INSERT INTO missions_transport(miss_id, trans_id)



--updates
-- Creating or updating the temporary table to include unmarried, available, experienced employees, and their mission count and marital status
CREATE TEMPORARY TABLE temp_employee_availability AS
SELECT
    emp_id,
    employee_name,
    employee_surname,
    availability_status,
    missions_count,  -- Include the mission count in the temporary table
    is_married       -- Include the marital status in the temporary table
FROM get_experienced_available_employees()  -- Use the function to fetch the data
ORDER BY is_married,               -- Sort unmarried employees first
         missions_count DESC,      -- Sort by mission count (most experienced first)
         availability_status DESC, -- Sort by availability (Available first)
         emp_id;  -- Final sorting by emp_id for consistency (if needed)

