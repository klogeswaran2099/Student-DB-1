-- ==========================================
-- Task 1.3: Data Manipulation
-- ==========================================

-- a. Inserting some dummy data to test the schema
INSERT INTO Advisors (advisor_name, advisor_email) VALUES 
('Dr. Robert Ford', 'r.ford@university.edu'),
('Dr. Sarah Lewis', 's.lewis@university.edu');

INSERT INTO Instructors (instructor_name, instructor_email) VALUES 
('Prof. James Miller', 'j.miller@university.edu'),
('Prof. Emily Chen', 'e.chen@university.edu');

INSERT INTO Students (student_id, student_name, department, advisor_name) VALUES 
(101, 'Mark Evans', 'Computer Science', 'Dr. Robert Ford'),
(102, 'Lucy Chen', 'Mathematics', 'Dr. Sarah Lewis'),
(103, 'David Kim', 'Computer Science', 'Dr. Robert Ford');

INSERT INTO Courses (course_code, course_name, instructor_name) VALUES 
('CS101', 'Intro to Programming', 'Prof. James Miller'),
('CS404', 'Advanced Databases', 'Prof. James Miller'),
('MA201', 'Linear Algebra', 'Prof. Emily Chen');

INSERT INTO Enrollments (student_id, course_code, enrollment_year, marks_obtained) VALUES 
(101, 'CS101', 2024, 82.50),
(102, 'MA201', 2024, 30.00),
(103, 'CS101', 2024, 91.00);

-- b. Update targetting exactly one row via PK
UPDATE Instructors 
SET instructor_email = 'james.miller.new@university.edu' 
WHERE instructor_name = 'Prof. James Miller';

-- c. Deleting poor grades without dropping the student entirely
DELETE FROM Enrollments 
WHERE marks_obtained < 35;

-- d. Wiping the old legacy table safely
DELETE FROM StudentRecords;
/* Note on why DELETE is safer than TRUNCATE for transactions:
I used DELETE here because it's a DML command that respects BEGIN and ROLLBACK blocks across basically all SQL databases. TRUNCATE is risky—depending on the engine (like MySQL), it acts as a DDL statement and will implicitly commit whatever transaction you have open, meaning you can't roll it back if something goes wrong. PostgreSQL allows TRUNCATE rollbacks, but DELETE is the safest bet for cross-platform reliability.
*/


-- ==========================================
-- Task 1.4: Advanced Querying
-- ==========================================

-- a. IN operator 
SELECT s.student_name, c.course_name 
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_code = c.course_code
WHERE e.course_code IN ('CS101', 'CS202', 'CS303');

-- b. BETWEEN and IS NOT NULL
SELECT s.* FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Advisors a ON s.advisor_name = a.advisor_name
WHERE e.marks_obtained BETWEEN 60 AND 85 
  AND a.advisor_email IS NOT NULL;

-- c. GROUP BY and HAVING for averages
SELECT 
    s.department, 
    AVG(e.marks_obtained) AS avg_marks, 
    MIN(e.marks_obtained) AS min_marks, 
    MAX(e.marks_obtained) AS max_marks
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
GROUP BY s.department
HAVING AVG(e.marks_obtained) > 55;

-- d. INNER vs LEFT JOIN comparison
-- This gets only the enrolled students
SELECT s.student_name, c.course_name, e.marks_obtained
FROM Students s
INNER JOIN Enrollments e ON s.student_id = e.student_id
INNER JOIN Courses c ON e.course_code = c.course_code;

-- This grabs everyone, leaving course_name as NULL for students with no classes
SELECT s.student_name, c.course_name, e.marks_obtained
FROM Students s
LEFT JOIN Enrollments e ON s.student_id = e.student_id
LEFT JOIN Courses c ON e.course_code = c.course_code;

-- e. Correlated subquery (above dept average)
SELECT s1.student_name, e1.marks_obtained
FROM Students s1
JOIN Enrollments e1 ON s1.student_id = e1.student_id
WHERE e1.marks_obtained > (
    SELECT AVG(e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2 ON s2.student_id = e2.student_id
    WHERE s2.department = s1.department
);

-- f. EXCEPT set operation
SELECT student_id FROM Enrollments WHERE enrollment_year = 2024
EXCEPT
SELECT student_id FROM Enrollments WHERE enrollment_year = 2025;

-- g. Correlated subquery for exactly the 2nd highest score
SELECT s1.student_name, e1.marks_obtained
FROM Students s1
JOIN Enrollments e1 ON s1.student_id = e1.student_id
WHERE (
    SELECT COUNT(DISTINCT e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2 ON s2.student_id = e2.student_id
    WHERE s2.department = s1.department 
      AND e2.marks_obtained > e1.marks_obtained
) = 1
AND (
    SELECT COUNT(DISTINCT s3.student_id)
    FROM Students s3
    WHERE s3.department = s1.department
) > 1;

-- h. Using window functions for ranks side-by-side
SELECT 
    s.student_name, 
    s.department, 
    e.marks_obtained,
    ROW_NUMBER() OVER (PARTITION BY s.department ORDER BY e.marks_obtained DESC) as row_num,
    RANK() OVER (PARTITION BY s.department ORDER BY e.marks_obtained DESC) as rank_val,
    DENSE_RANK() OVER (PARTITION BY s.department ORDER BY e.marks_obtained DESC) as dense_rank_val
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id;


-- ==========================================
-- Task 1.5a: Transactions 
-- ==========================================

BEGIN;

-- Drop the old class
DELETE FROM Enrollments 
WHERE student_id = 101 AND course_code = 'CS101';

-- Add the new class
-- If this fails (e.g., student_id 101 doesn't exist anymore), 
-- the app will trigger a ROLLBACK. Otherwise, it commits.
INSERT INTO Enrollments (student_id, course_code, enrollment_year, marks_obtained) 
VALUES (101, 'CS404', 2024, NULL);

COMMIT;
