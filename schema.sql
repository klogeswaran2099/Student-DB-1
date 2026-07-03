-- Creating tables for BCNF decomposition
-- Task 1.2 Schema Implementation

CREATE TABLE Advisors (
    advisor_name VARCHAR(100) PRIMARY KEY,
    advisor_email VARCHAR(100) NOT NULL
);

CREATE TABLE Instructors (
    instructor_name VARCHAR(100) PRIMARY KEY,
    instructor_email VARCHAR(100) NOT NULL
);

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    advisor_name VARCHAR(100),
    CONSTRAINT fk_student_advisor FOREIGN KEY (advisor_name) REFERENCES Advisors(advisor_name)
);

CREATE TABLE Courses (
    course_code VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_name VARCHAR(100),
    CONSTRAINT fk_course_instructor FOREIGN KEY (instructor_name) REFERENCES Instructors(instructor_name)
);

CREATE TABLE Enrollments (
    student_id INT,
    course_code VARCHAR(10),
    enrollment_year INT DEFAULT 2024,
    marks_obtained DECIMAL(5, 2),
    PRIMARY KEY (student_id, course_code),
    CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_enroll_course FOREIGN KEY (course_code) REFERENCES Courses(course_code) ON DELETE CASCADE
);
