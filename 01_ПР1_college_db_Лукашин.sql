-- ============================================================
-- Практическая работа № 7. База данных «Колледж»
-- Студент: Лукашин Елисей Андреевич, группа ИСП-211
-- СУБД: MySQL 8.0 (InnoDB, utf8mb4)
-- ============================================================

DROP DATABASE IF EXISTS `lukashin_bd`;
CREATE DATABASE `lukashin_bd`
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE `lukashin_bd`;

-- ------------------------------------------------------------
-- Таблица «Группы»
-- ------------------------------------------------------------
CREATE TABLE `groups` (
    group_id       INT           NOT NULL AUTO_INCREMENT,
    group_name     VARCHAR(20)   NOT NULL,
    specialty      VARCHAR(100)  NOT NULL,
    admission_year YEAR          NOT NULL,
    PRIMARY KEY (group_id),
    UNIQUE KEY uq_groups_name (group_name),
    CONSTRAINT chk_groups_year CHECK (admission_year BETWEEN 2000 AND 2100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Таблица «Студенты»
-- ------------------------------------------------------------
CREATE TABLE students (
    student_id  INT         NOT NULL AUTO_INCREMENT,
    last_name   VARCHAR(50) NOT NULL,
    first_name  VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NULL,
    birth_date  DATE        NOT NULL,
    group_id    INT         NOT NULL,
    PRIMARY KEY (student_id),
    CONSTRAINT fk_students_group FOREIGN KEY (group_id)
        REFERENCES `groups` (group_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Таблица «Преподаватели»
-- ------------------------------------------------------------
CREATE TABLE teachers (
    teacher_id INT          NOT NULL AUTO_INCREMENT,
    last_name  VARCHAR(50)  NOT NULL,
    first_name VARCHAR(50)  NOT NULL,
    department VARCHAR(100) NOT NULL,
    PRIMARY KEY (teacher_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Таблица «Дисциплины»
-- ------------------------------------------------------------
CREATE TABLE disciplines (
    discipline_id   INT          NOT NULL AUTO_INCREMENT,
    discipline_name VARCHAR(100) NOT NULL,
    hours           INT          NOT NULL,
    PRIMARY KEY (discipline_id),
    UNIQUE KEY uq_disciplines_name (discipline_name),
    CONSTRAINT chk_disciplines_hours CHECK (hours > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Таблица «Занятия»
-- ------------------------------------------------------------
CREATE TABLE lessons (
    lesson_id     INT         NOT NULL AUTO_INCREMENT,
    group_id      INT         NOT NULL,
    discipline_id INT         NOT NULL,
    teacher_id    INT         NOT NULL,
    lesson_date   DATE        NOT NULL,
    lesson_type   VARCHAR(30) NOT NULL,
    PRIMARY KEY (lesson_id),
    CONSTRAINT fk_lessons_group FOREIGN KEY (group_id)
        REFERENCES `groups` (group_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_lessons_discipline FOREIGN KEY (discipline_id)
        REFERENCES disciplines (discipline_id) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_lessons_teacher FOREIGN KEY (teacher_id)
        REFERENCES teachers (teacher_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Таблица «Оценки» (домашнее задание)
-- ------------------------------------------------------------
CREATE TABLE grades (
    grade_id      INT  NOT NULL AUTO_INCREMENT,
    student_id    INT  NOT NULL,
    discipline_id INT  NOT NULL,
    grade_date    DATE NOT NULL,
    grade         TINYINT NOT NULL,
    PRIMARY KEY (grade_id),
    CONSTRAINT fk_grades_student FOREIGN KEY (student_id)
        REFERENCES students (student_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_grades_discipline FOREIGN KEY (discipline_id)
        REFERENCES disciplines (discipline_id) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT chk_grades_value CHECK (grade BETWEEN 2 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

USE `lukashin_bd`;

-- Заполнение таблицы «Группы»
INSERT INTO `groups` (group_name, specialty, admission_year) VALUES
    ('ИСП-211', 'Информационные системы и программирование', 2021),
    ('ИСП-212', 'Информационные системы и программирование', 2021),
    ('СА-211', 'Системное администрирование', 2021),
    ('СА-212', 'Системное администрирование', 2022);

-- Заполнение таблицы «Студенты»
INSERT INTO students (last_name, first_name, middle_name, birth_date, group_id) VALUES
    ('Лукашин', 'Елисей', 'Андреевич', '2005-05-21', 1),
    ('Антонов', 'Кирилл', 'Дмитриевич', '2005-08-11', 1),
    ('Богданова', 'Мария', 'Ильинична', '2006-02-27', 1),
    ('Власов', 'Егор', 'Сергеевич', '2005-10-09', 1),
    ('Гордеева', 'Софья', 'Максимовна', '2006-03-30', 1),
    ('Данилов', 'Илья', 'Андреевич', '2005-07-16', 2),
    ('Егорова', 'Дарья', 'Павловна', '2006-05-04', 2),
    ('Капустин', 'Роман', 'Олегович', '2005-11-18', 3);

-- Заполнение таблицы «Преподаватели»
INSERT INTO teachers (last_name, first_name, department) VALUES
    ('Волков', 'Дмитрий', 'Сергеевич'),
    ('Панова', 'Елена', 'Игоревна'),
    ('Романов', 'Артём', 'Владимирович'),
    ('Семёнова', 'Наталья', 'Юрьевна');

-- Заполнение таблицы «Дисциплины»
INSERT INTO disciplines (discipline_name, hours) VALUES
    ('Информатика', 102),
    ('Алгоритмы и структуры данных', 120),
    ('Проектирование баз данных', 96),
    ('Объектно-ориентированное программирование', 132),
    ('Компьютерные сети', 78);

-- Заполнение таблицы «Занятия»
INSERT INTO lessons (group_id, discipline_id, teacher_id, lesson_date, lesson_type) VALUES
    (1, 1, 1, '2025-09-01', 'Лекция'),
    (1, 1, 1, '2025-09-03', 'Практика'),
    (1, 2, 2, '2025-09-05', 'Лекция'),
    (2, 2, 2, '2025-09-08', 'Практика'),
    (2, 3, 3, '2025-09-10', 'Лекция'),
    (3, 3, 3, '2025-09-12', 'Практика'),
    (3, 4, 4, '2025-09-15', 'Лекция'),
    (1, 4, 4, '2025-09-17', 'Лабораторная'),
    (2, 5, 1, '2025-09-19', 'Лекция'),
    (3, 5, 2, '2025-09-22', 'Практика');

-- Заполнение таблицы «Оценки» (не менее 10 записей)
INSERT INTO grades (student_id, discipline_id, grade_date, grade) VALUES
    (1, 1, '2025-09-11', 4),
    (1, 2, '2025-09-15', 5),
    (1, 3, '2025-09-19', 5),
    (2, 1, '2025-09-11', 3),
    (2, 2, '2025-09-15', 4),
    (3, 1, '2025-09-11', 5),
    (3, 5, '2025-09-21', 5),
    (4, 2, '2025-09-15', 4),
    (4, 3, '2025-09-19', 4),
    (5, 1, '2025-09-11', 4),
    (6, 2, '2025-09-15', 5),
    (7, 3, '2025-09-19', 3),
    (8, 4, '2025-09-17', 4),
    (2, 4, '2025-09-17', 4),
    (3, 4, '2025-09-17', 5);

-- ------------------------------------------------------------
-- Проверка структуры и данных
-- ------------------------------------------------------------
SELECT * FROM `groups`;
SELECT * FROM students;
SELECT * FROM teachers;
SELECT * FROM disciplines;
SELECT * FROM lessons;
SELECT * FROM grades;

-- Количество записей в каждой таблице
SELECT 'groups' AS table_name, COUNT(*) AS rows_count FROM `groups`
UNION ALL SELECT 'students', COUNT(*) FROM students
UNION ALL SELECT 'teachers', COUNT(*) FROM teachers
UNION ALL SELECT 'disciplines', COUNT(*) FROM disciplines
UNION ALL SELECT 'lessons', COUNT(*) FROM lessons
UNION ALL SELECT 'grades', COUNT(*) FROM grades;

-- ------------------------------------------------------------
-- Демонстрация ссылочной целостности: студент в несуществующей группе
-- Раскомментируйте три строки ниже, чтобы увидеть ошибку внешнего ключа.
-- ------------------------------------------------------------
-- INSERT INTO students (last_name, first_name, birth_date, group_id)
-- VALUES ('Тестов', 'Тест', '2006-01-01', 999);
-- Ожидаемая ошибка MySQL:
-- ERROR 1452 (23000): Cannot add or update a child row: a foreign key
-- constraint fails (`students`, CONSTRAINT `fk_students_group` ...)

-- ------------------------------------------------------------
-- Демонстрация каскадного обновления (ON UPDATE CASCADE)
-- ------------------------------------------------------------
UPDATE `groups` SET group_id = 91 WHERE group_id = 1;
SELECT group_id, group_name FROM `groups`;
SELECT student_id, last_name, group_id FROM students;
UPDATE `groups` SET group_id = 1 WHERE group_id = 91;

-- ------------------------------------------------------------
-- Демонстрация каскадного удаления (ON DELETE CASCADE)
-- ------------------------------------------------------------
INSERT INTO `groups` (group_name, specialty, admission_year)
VALUES ('ТЕСТ-1', 'Тестовая специальность', 2025);
INSERT INTO students (last_name, first_name, birth_date, group_id)
VALUES ('Тестов', 'Тест', '2006-01-01', LAST_INSERT_ID());
SELECT * FROM students WHERE last_name = 'Тестов';
DELETE FROM `groups` WHERE group_name = 'ТЕСТ-1';
SELECT * FROM students WHERE last_name = 'Тестов';
-- Запись студента удалена автоматически вместе с группой.
