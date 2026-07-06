select * from messy_employees;


-- Trim spaces + standardize case
SET SQL_SAFE_UPDATES = 0;

UPDATE messy_employees SET
full_name = TRIM(full_name),
email = LOWER(TRIM(email)),
department = CONCAT(UPPER(LEFT(TRIM(department),1)), LOWER(SUBSTRING(TRIM(department),2))),
job_title = CONCAT(UPPER(LEFT(job_title, 1)), LOWER(SUBSTRING(job_title, 2))),
status = CONCAT(UPPER(LEFT(TRIM(status),1)), LOWER(SUBSTRING(TRIM(status),2)));

-- Standardize phone to +2348XXXXXXXXXX format
UPDATE messy_employees SET phone = REGEXP_REPLACE(phone, '[^0-9]', '');
UPDATE messy_employees SET phone = CONCAT('+234', SUBSTRING(phone, 2)) WHERE phone LIKE '0%';
UPDATE messy_employees SET phone = CONCAT('+', SUBSTRING(phone, 1)) WHERE phone LIKE '2%';
UPDATE messy_employees SET phone = CONCAT('+234', SUBSTRING(phone, 1)) WHERE phone LIKE '8%';
UPDATE messy_employees SET phone = '+234' WHERE staff_code  = 'STF014';
UPDATE messy_employees SET phone = NULL WHERE LENGTH(phone) != 14;


-- Clean salary - remove N, ₦, commas
UPDATE messy_employees SET salary = REGEXP_REPLACE(salary, '[^0-9.]', '');
UPDATE messy_employees SET salary = NULL WHERE salary = '' OR salary = 'N/A';

-- Convert salary to DECIMAL
ALTER TABLE messy_employees MODIFY salary DECIMAL(12,2);

-- Fix hire_date formats
UPDATE messy_employees SET hire_date = STR_TO_DATE(hire_date, '%Y-%m-%d') WHERE hire_date REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';
UPDATE messy_employees SET hire_date = STR_TO_DATE(hire_date, '%d/%m/%Y') WHERE hire_date REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';
UPDATE messy_employees SET hire_date = STR_TO_DATE(hire_date, '%d-%m-%Y') WHERE hire_date REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';
UPDATE messy_employees SET hire_date = STR_TO_DATE(hire_date, '%Y.%m.%d') WHERE hire_date REGEXP '^[0-9]{4}\\.[0-9]{2}\\.[0-9]{2}$';
UPDATE messy_employees SET hire_date = NULL WHERE hire_date = 'bad date';

-- Remove rows with missing critical data
DELETE FROM messy_employees 
WHERE full_name = '' OR full_name IS NULL
   OR email NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'
   OR salary IS NULL
   OR hire_date IS NULL;

-- Remove duplicate employees by email, keep first emp_id
DELETE e1 FROM messy_employees e1
INNER JOIN messy_employees e2 
ON e1.email = e2.email AND e1.emp_id > e2.emp_id;

-- Move to clean table
DROP TABLE IF EXISTS clean_employees;
CREATE TABLE clean_employees LIKE messy_employees;
ALTER TABLE clean_employees MODIFY hire_date DATE;
INSERT INTO clean_employees SELECT * FROM messy_employees;
SELECT * FROM clean_employees;

SET SQL_SAFE_UPDATES = 1;


