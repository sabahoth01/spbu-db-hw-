CREATE DATABASE "dbCourses"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LOCALE_PROVIDER = 'libc'
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    is_exam BOOLEAN NOT NULL,
    min_grade INT NOT NULL,
    max_grade INT NOT NULL
);

CREATE TABLE groups (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50) NOT NULL
);

CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    group_id INT,
    FOREIGN KEY (group_id) REFERENCES groups(id)
);

CREATE TABLE grades (
    student_id INT,
    course_id INT,
    grade INT,
    grade_str VARCHAR(1),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    PRIMARY KEY (student_id, course_id)
);

-- Заполнение таблицы courses
INSERT INTO courses (name, is_exam, min_grade, max_grade) VALUES
('Mathematics', TRUE, 0, 100),
('History', FALSE, 0, 100),
('Physics', TRUE, 0, 100);

-- Заполнение таблицы groups
INSERT INTO groups (full_name, short_name) VALUES
('Group A', 'GA'),
('Group B', 'GB');

-- Заполнение таблицы students
INSERT INTO students (first_name, last_name, group_id) VALUES
('Ivan', 'Ivanov', 1),
('Petr', 'Petrov', 1),
('Anna', 'Sidorova', 2),
('Maria', 'Smirnova', 2);

-- Заполнение таблицы grades
INSERT INTO grades (student_id, course_id, grade, grade_str) VALUES
(1, 1, 85, 'B'),
(1, 2, 90, 'A'),
(2, 1, 75, 'C'),
(3, 2, 60, 'E'),
(4, 1, 95, 'A'),
(4, 3, 70, 'C');

--- Фильтрация студентов по группе
SELECT * FROM students WHERE group_id = 1;

--- Агрегация оценок по курсу
SELECT course_id, AVG(grade) AS average_grade
FROM grades
GROUP BY course_id;

--- Фильтрация студентов с оценками выше 80 по курсу 'Mathematics'
SELECT s.first_name, s.last_name, g.grade
FROM students s
JOIN grades g ON s.id = g.student_id
JOIN courses c ON g.course_id = c.id
WHERE c.name = 'Mathematics' AND g.grade > 80;


--- Получение оценок студентов по группам
SELECT grp.full_name, s.first_name, s.last_name, g.grade
FROM grades g
JOIN students s ON g.student_id = s.id
JOIN groups grp ON s.group_id = grp.id
ORDER BY grp.full_name, s.last_name;
