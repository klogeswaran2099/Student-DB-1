# Part 1: Relational Database Design & SQL

## Task 1.1 — Normalization

### a. Dependencies in StudentRecords
* **Partial Dependencies:** * `student_id` → `student_name`, `department`, `advisor_name`
  * `course_code` → `course_name`, `instructor_name`, `instructor_email`
* **Transitive Dependencies:** * `advisor_name` → `advisor_email`
  * `instructor_name` → `instructor_email`

### b. BCNF Decomposition
1. **Advisors** (PK: `advisor_name`)
   * Resolves the transitive dependency for advisor emails (prevents update anomalies).
2. **Instructors** (PK: `instructor_name`)
   * Resolves the transitive dependency for instructor emails.
3. **Students** (PK: `student_id`, FK: `advisor_name`)
   * Resolves partial dependency on `student_id`. Prevents deletion anomalies (e.g., losing student info if they drop all classes).
4. **Courses** (PK: `course_code`, FK: `instructor_name`)
   * Resolves partial dependency on `course_code`. Prevents insertion anomalies (allows adding a course before anyone enrolls).
5. **Enrollments** (PK: `student_id`, `course_code`; FKs: `student_id`, `course_code`)
   * Base table holding attributes fully dependent on the composite key.

### c. Data Integrity Evaluation
* **Entity Integrity:** Satisfied. All tables have defined primary keys; no nulls allowed.
* **Referential Integrity:** Satisfied. All foreign keys correctly reference parent table PKs.
* **Domain Integrity:** Satisfied. Strict data types used (INT, VARCHAR, DECIMAL).
* **User-Defined Integrity:** Satisfied. Handled via the `DEFAULT 2024` constraint on `enrollment_year`.

---

## Task 1.5 — Transactions and Isolation

### b. Non-Repeatable Read
* **Anomaly:** Non-repeatable read.
* **Prevention:** The **Repeatable Read** isolation level prevents this by ensuring a read row cannot be modified by others until the transaction ends.

### c. Phantom Read / Write Skew
* **Anomaly:** Phantom Read (resulting in Write Skew).
* **Prevention:** The **Serializable** isolation level is required to prevent this.

### d. MVCC Read Behaviour
* **Result:** The reporting transaction sees the original, unmodified `marks_obtained` value.
* **Why:** MVCC uses row versioning. It provides a consistent point-in-time snapshot of the data from when the read transaction started.
* **Isolation Level:** **Repeatable Read** (Snapshot Isolation).
* **Trade-off:** Allows high read/write concurrency without locking, but leaves the system vulnerable to write skew.
