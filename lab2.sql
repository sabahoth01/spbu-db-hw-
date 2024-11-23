CREATE TABLE student_courses (
    id SERIAL PRIMARY KEY,
    student_id INT,
    course_id INT,
    UNIQUE(student_id, course_id),  -- Обеспечиваем уникальность сочетания student_id и course_id
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

CREATE TABLE group_courses (
    id SERIAL PRIMARY KEY,
    group_id INT,
    course_id INT,
    UNIQUE(group_id, course_id),  -- Обеспечиваем уникальность сочетания group_id и course_id
    FOREIGN KEY (group_id) REFERENCES groups(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- Заполнение таблицы student_courses
INSERT INTO student_courses (student_id, course_id) VALUES
(1, 1),
(1, 2),
(2, 1),
(3, 2),
(4, 1),
(4, 3);

-- Заполнение таблицы group_courses
INSERT INTO group_courses (group_id, course_id) VALUES
(1, 1),
(1, 2),
(2, 2),
(2, 1),
(2, 3);


ALTER TABLE courses ADD CONSTRAINT unique_course_name UNIQUE (name);

CREATE INDEX idx_group_id ON students(group_id);  -- Создаем индекс на поле group_id

-- Индексация позволяет улучшить производительность запросов, которые фильтруют или сортируют данные по полю group_id.
-- При наличии индекса PostgreSQL может быстрее находить записи, соответствующие условиям запроса, вместо полного сканирования таблицы.

-- Запрос для получения списка всех студентов с их курсами и нахождения студентов с высокой средней оценкой
-- SELECT s.first_name, s.last_name, c.name AS course_name, AVG(g.grade) AS average_grade
-- FROM students s
-- JOIN student_courses sc ON s.id = sc.student_id
-- JOIN courses c ON sc.course_id = c.id
-- JOIN grades g ON s.id = g.student_id
-- GROUP BY s.id, c.id
-- HAVING AVG(g.grade) > (
--     SELECT AVG(g2.grade)
--     FROM students s2
--     JOIN student_courses sc2 ON s2.id = sc2.student_id
--     JOIN grades g2 ON s2.id = g2.student_id
--     WHERE s2.group_id = s.group_id
--     GROUP BY s2.id
-- );
-- List all students with their courses
SELECT s.first_name, s.last_name, c.name AS course_name
FROM students s
JOIN student_courses sc ON s.id = sc.student_id
JOIN courses c ON sc.course_id = c.id;

-- Find students with average grades higher than any other student in their group
SELECT s.first_name, s.last_name, AVG(g.grade) AS average_grade
FROM students s
JOIN grades g ON s.id = g.student_id
GROUP BY s.id
HAVING AVG(g.grade) > (
    SELECT MAX(avg_grade)
    FROM (
        SELECT AVG(g2.grade) AS avg_grade
        FROM students s2
        JOIN grades g2 ON s2.id = g2.student_id
        WHERE s2.group_id = s.group_id
        GROUP BY s2.id
    ) AS group_avg
);

--- Подсчет количества студентов на каждом курсе
SELECT c.name AS course_name, COUNT(sc.student_id) AS student_count
FROM courses c
LEFT JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.id;

---  Нахождение средней оценки на каждом курсе
SELECT c.name AS course_name, AVG(g.grade) AS average_grade
FROM courses c
JOIN student_courses sc ON c.id = sc.course_id
JOIN grades g ON sc.student_id = g.student_id
GROUP BY c.id;
