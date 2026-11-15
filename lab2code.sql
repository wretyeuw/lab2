
-- Лабораторная работа №2
-- Вариант 16
-- Создание запросов
-- PostgreSQL

BEGIN;

-- Подготовка данных для выполнения заданий
-- Добавление курса и формы обучения

ALTER TABLE public.study_groups
ADD COLUMN IF NOT EXISTS course_number INTEGER;

ALTER TABLE public.study_groups
ADD COLUMN IF NOT EXISTS education_type VARCHAR(20);

UPDATE public.study_groups
SET
    course_number = CASE
        WHEN group_number IN (101, 102) THEN 1
        WHEN group_number IN (103, 104) THEN 2
        WHEN group_number IN (105, 106) THEN 3
        WHEN group_number IN (107, 108) THEN 4
        WHEN group_number IN (109, 110) THEN 5
        ELSE course_number
    END,
    education_type = CASE
        WHEN group_number BETWEEN 101 AND 110
        THEN CASE
            WHEN MOD(group_number, 2) = 1
                THEN 'paid'
            ELSE 'budget'
        END
        ELSE education_type
    END;

-- Подготовка тестовых значений
UPDATE public.students
SET phone = NULL
WHERE student_id = 3;

UPDATE public.students
SET address = 'Химки, ул. Гагарина, 12'
WHERE student_id = 5;

UPDATE public.students
SET address = NULL
WHERE student_id = 1;

-- Задание 1
-- Выбрать всех студентов старше 18 лет,
-- обучающихся в платных группах

SELECT
    s.student_id,
    s.last_name,
    s.first_name,
    s.middle_name,
    s.birth_date,
    s.group_number,
    g.education_type
FROM public.students s
JOIN public.study_groups g
    ON s.group_number = g.group_number
WHERE s.birth_date < CURRENT_DATE - INTERVAL '18 years'
  AND g.education_type = 'paid'
ORDER BY s.last_name;

-- Задание 2
-- Выбрать телефонные номера всех студентов
-- бюджетных групп 1 курса

SELECT
    s.last_name,
    s.first_name,
    s.phone,
    s.group_number
FROM public.students s
JOIN public.study_groups g
    ON s.group_number = g.group_number
WHERE g.education_type = 'budget'
  AND g.course_number = 1
ORDER BY s.last_name;

-- Задание 3
-- Создать таблицу с данными первого запроса,
-- включая номера телефонов и адреса

DROP TABLE IF EXISTS public.lab2_result_16;

CREATE TABLE public.lab2_result_16 AS
SELECT
    s.student_id,
    s.last_name,
    s.first_name,
    s.middle_name,
    s.birth_date,
    s.address,
    s.phone,
    s.group_number,
    g.course_number,
    g.education_type
FROM public.students s
JOIN public.study_groups g
    ON s.group_number = g.group_number
WHERE s.birth_date < CURRENT_DATE - INTERVAL '18 years'
  AND g.education_type = 'paid';

ALTER TABLE public.lab2_result_16
ADD CONSTRAINT lab2_result_16_pkey
PRIMARY KEY (student_id);

SELECT * FROM public.lab2_result_16;

-- Задание 4
-- Добавить в созданную таблицу студентов,
-- у которых отсутствует номер телефона

INSERT INTO public.lab2_result_16 (
    student_id,
    last_name,
    first_name,
    middle_name,
    birth_date,
    address,
    phone,
    group_number,
    course_number,
    education_type
)
SELECT
    s.student_id,
    s.last_name,
    s.first_name,
    s.middle_name,
    s.birth_date,
    s.address,
    s.phone,
    s.group_number,
    g.course_number,
    g.education_type
FROM public.students s
JOIN public.study_groups g
    ON s.group_number = g.group_number
WHERE s.phone IS NULL
ON CONFLICT (student_id) DO NOTHING;

SELECT * FROM public.lab2_result_16;

-- Задание 5
-- Для всех студентов не из Москвы
-- добавить к адресу "Московская область"

UPDATE public.lab2_result_16
SET address = 'Московская область, ' || address
WHERE address IS NOT NULL
  AND address NOT ILIKE '%Москва%'
  AND address NOT ILIKE '%Московская область%';

SELECT * FROM public.lab2_result_16;

-- Задание 6
-- Удалить записи студентов без адреса

DELETE FROM public.lab2_result_16
WHERE address IS NULL
   OR BTRIM(address) = '';

SELECT * FROM public.lab2_result_16;

-- Задание 7
-- Посчитать количество студентов на каждом курсе

SELECT
    g.course_number,
    COUNT(s.student_id) AS students_count
FROM public.study_groups g
LEFT JOIN public.students s
    ON g.group_number = s.group_number
GROUP BY g.course_number
ORDER BY g.course_number;

COMMIT;

-- Проверка итоговой таблицы
SELECT * FROM public.lab2_result_16
ORDER BY student_id;
