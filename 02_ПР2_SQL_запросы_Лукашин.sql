-- ============================================================
-- Практическая работа № 8. Анализ данных с помощью SQL-запросов
-- Студент: Лукашин Елисей Андреевич, группа ИСП-211
-- База данных: lukashin_bd (скрипт ПР № 7)
-- ============================================================

USE `lukashin_bd`;

-- ------------------------------------------------------------
-- 1. Список всех студентов с названиями их групп
-- ------------------------------------------------------------
SELECT s.last_name, s.first_name, g.group_name
FROM students AS s
INNER JOIN `groups` AS g ON g.group_id = s.group_id
ORDER BY g.group_name, s.last_name;


-- ------------------------------------------------------------
-- 2. Количество студентов в каждой группе
-- ------------------------------------------------------------
SELECT g.group_name, COUNT(s.student_id) AS students_count
FROM `groups` AS g
LEFT JOIN students AS s ON s.group_id = g.group_id
GROUP BY g.group_id, g.group_name
ORDER BY students_count DESC, g.group_name;


-- ------------------------------------------------------------
-- 3. Расписание занятий с полной информацией
-- ------------------------------------------------------------
SELECT l.lesson_date, g.group_name, d.discipline_name,
       t.last_name, t.first_name, l.lesson_type
FROM lessons AS l
INNER JOIN `groups` AS g     ON g.group_id = l.group_id
INNER JOIN disciplines AS d  ON d.discipline_id = l.discipline_id
INNER JOIN teachers AS t     ON t.teacher_id = l.teacher_id
ORDER BY l.lesson_date, g.group_name;


-- ------------------------------------------------------------
-- 4. Нагрузка преподавателей (количество занятий)
-- ------------------------------------------------------------
SELECT t.last_name, t.first_name, COUNT(l.lesson_id) AS lessons_count
FROM teachers AS t
LEFT JOIN lessons AS l ON l.teacher_id = t.teacher_id
GROUP BY t.teacher_id, t.last_name, t.first_name
ORDER BY lessons_count DESC;


-- ------------------------------------------------------------
-- 5. Студенты, родившиеся после 2005 года
-- ------------------------------------------------------------
SELECT last_name, first_name, birth_date
FROM students
WHERE birth_date > '2005-12-31'
ORDER BY birth_date;


-- ------------------------------------------------------------
-- 6. Дисциплины с количеством часов больше порога
-- ------------------------------------------------------------
SELECT discipline_name, hours
FROM disciplines
WHERE hours > 100
ORDER BY hours DESC;


-- ------------------------------------------------------------
-- 7. Группы, в которых больше одного студента
-- ------------------------------------------------------------
SELECT g.group_name, COUNT(s.student_id) AS students_count
FROM `groups` AS g
INNER JOIN students AS s ON s.group_id = g.group_id
GROUP BY g.group_id, g.group_name
HAVING COUNT(s.student_id) > 1
ORDER BY students_count DESC;


-- ------------------------------------------------------------
-- 8. Средняя нагрузка на преподавателя
-- ------------------------------------------------------------
SELECT ROUND(AVG(cnt), 2) AS avg_lessons
FROM (SELECT teacher_id, COUNT(*) AS cnt
      FROM lessons
      GROUP BY teacher_id) AS t;


-- ------------------------------------------------------------
-- 9. Список специальностей групп (без дубликатов)
-- ------------------------------------------------------------
SELECT DISTINCT specialty
FROM `groups`
ORDER BY specialty;


-- ------------------------------------------------------------
-- 10. Студенты и их группы (с использованием подзапроса)
-- ------------------------------------------------------------
SELECT s.last_name, s.first_name,
       (SELECT g.group_name FROM `groups` AS g
        WHERE g.group_id = s.group_id) AS group_name
FROM students AS s
ORDER BY s.last_name;


-- ------------------------------------------------------------
-- 11. Группы, в которых нет ни одного студента
-- ------------------------------------------------------------
SELECT g.group_name
FROM `groups` AS g
WHERE NOT EXISTS (SELECT 1 FROM students AS s
                  WHERE s.group_id = g.group_id)
ORDER BY g.group_name;


-- ------------------------------------------------------------
-- 12. Средний балл каждого студента
-- ------------------------------------------------------------
SELECT s.last_name, s.first_name,
       COUNT(gr.grade_id) AS grades_count,
       ROUND(AVG(gr.grade), 2) AS avg_grade
FROM students AS s
INNER JOIN grades AS gr ON gr.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
ORDER BY avg_grade DESC, s.last_name;


-- ------------------------------------------------------------
-- 13. Средний балл по дисциплинам
-- ------------------------------------------------------------
SELECT d.discipline_name,
       COUNT(gr.grade_id) AS grades_count,
       ROUND(AVG(gr.grade), 2) AS avg_grade
FROM disciplines AS d
INNER JOIN grades AS gr ON gr.discipline_id = d.discipline_id
GROUP BY d.discipline_id, d.discipline_name
ORDER BY avg_grade DESC;


-- ------------------------------------------------------------
-- 14. Лучшие студенты (средний балл выше 4,5)
-- ------------------------------------------------------------
SELECT s.last_name, s.first_name, ROUND(AVG(gr.grade), 2) AS avg_grade
FROM students AS s
INNER JOIN grades AS gr ON gr.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
HAVING AVG(gr.grade) > 4.5
ORDER BY avg_grade DESC;


-- ------------------------------------------------------------
-- 15. Распределение студентов по уровню успеваемости
-- ------------------------------------------------------------
SELECT s.last_name, s.first_name, ROUND(AVG(gr.grade), 2) AS avg_grade,
       CASE
           WHEN AVG(gr.grade) >= 4.5 THEN 'отлично'
           WHEN AVG(gr.grade) >= 3.5 THEN 'хорошо'
           ELSE 'удовлетворительно'
       END AS level
FROM students AS s
INNER JOIN grades AS gr ON gr.student_id = s.student_id
GROUP BY s.student_id, s.last_name, s.first_name
ORDER BY avg_grade DESC;


-- ------------------------------------------------------------
-- 16. Транзакции (TCL)
-- ------------------------------------------------------------
START TRANSACTION;
INSERT INTO grades (student_id, discipline_id, grade_date, grade)
VALUES (1, 1, '2025-10-01', 5);
ROLLBACK;

-- ------------------------------------------------------------
-- 17. Представление (VIEW)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_student_groups AS
SELECT s.student_id, s.last_name, s.first_name, g.group_name, g.specialty
FROM students AS s
INNER JOIN `groups` AS g ON g.group_id = s.group_id;

SELECT * FROM v_student_groups;

-- ------------------------------------------------------------
-- 18. Индексы
-- ------------------------------------------------------------
CREATE INDEX idx_students_group  ON students (group_id);
CREATE INDEX idx_lessons_date    ON lessons (lesson_date);
CREATE INDEX idx_grades_student  ON grades (student_id);

EXPLAIN SELECT * FROM students WHERE group_id = 1;

-- ------------------------------------------------------------
-- 19. Триггеры
-- ------------------------------------------------------------
DELIMITER $$
CREATE TRIGGER trg_grades_check
BEFORE INSERT ON grades
FOR EACH ROW
BEGIN
    IF NEW.grade < 2 OR NEW.grade > 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Оценка должна быть в диапазоне от 2 до 5';
    END IF;
END$$
DELIMITER ;

-- ------------------------------------------------------------
-- 20. Права доступа (DCL)
-- ------------------------------------------------------------
CREATE ROLE 'teacher_role';
CREATE USER 'teacher1'@'localhost' IDENTIFIED BY 'Teacher#2025';
GRANT SELECT ON lukashin_bd.v_student_groups TO 'teacher_role';
GRANT 'teacher_role' TO 'teacher1'@'localhost';
SHOW GRANTS FOR 'teacher1'@'localhost';
