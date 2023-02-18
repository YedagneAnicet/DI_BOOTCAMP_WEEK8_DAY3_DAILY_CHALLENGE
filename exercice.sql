--PART 1
--Create the Customer and Customer profile tables:
CREATE TABLE Customer (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);
CREATE TABLE Customer_Profile (
    id SERIAL PRIMARY KEY,
    isLoggedIn BOOLEAN DEFAULT false,
    customer_id INTEGER REFERENCES Customer(id)
);
--Insert the customers:
INSERT INTO Customer (first_name, last_name)
VALUES ('John', 'Doe');
INSERT INTO Customer (first_name, last_name)
VALUES ('Jerome', 'Lalu');
INSERT INTO Customer (first_name, last_name)
VALUES ('Lea', 'Rive');
--Insert the customer profiles:
INSERT INTO Customer_Profile (isLoggedIn, customer_id)
VALUES (
        true,
        (
            SELECT id
            FROM Customer
            WHERE first_name = 'John'
                AND last_name = 'Doe'
        )
    );
INSERT INTO Customer_Profile (isLoggedIn, customer_id)
VALUES (
        false,
        (
            SELECT id
            FROM Customer
            WHERE first_name = 'Jerome'
                AND last_name = 'Lalu'
        )
    );
-- The first_name of the LoggedIn customers
SELECT c.first_name
FROM Customer c
    JOIN Customer_Profile cp ON c.id = cp.customer_id
WHERE cp.isLoggedIn = true;
-- All the customers first_name and isLoggedIn columns - even the customers those who don’t have a profile.
SELECT c.first_name,
    COALESCE(cp.isLoggedIn, false) AS isLoggedIn
FROM Customer c
    LEFT JOIN Customer_Profile cp ON c.id = cp.customer_id;
-- The number of customers that are not LoggedIn
SELECT COUNT(*)
FROM Customer c
    LEFT JOIN Customer_Profile cp ON c.id = cp.customer_id
WHERE cp.isLoggedIn = false
    OR cp.isLoggedIn IS NULL;
--PART 2
--Create the Book, Student tables:
CREATE TABLE Book (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL
);
CREATE TABLE Student (
    student_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    age INTEGER NOT NULL CHECK (age <= 15)
);
--Insert the books:
INSERT INTO Book (title, author)
VALUES ('Alice In Wonderland', 'Lewis Carroll');
INSERT INTO Book (title, author)
VALUES ('Harry Potter', 'J.K Rowling');
INSERT INTO Book (title, author)
VALUES ('To kill a mockingbird', 'Harper Lee');
--Insert the students:
INSERT INTO Student (name, age)
VALUES ('John', 12);
INSERT INTO Student (name, age)
VALUES ('Lera', 11);
INSERT INTO Student (name, age)
VALUES ('Patrick', 10);
INSERT INTO Student (name, age)
VALUES ('Bob', 14);
-- Create the library table
CREATE TABLE Library (
    book_fk_id INTEGER REFERENCES Book(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
    student_fk_id INTEGER REFERENCES Student(student_id) ON DELETE CASCADE ON UPDATE CASCADE,
    borrowed_date DATE,
    PRIMARY KEY (book_fk_id, student_fk_id)
);
-- Insert the record for John and Alice in Wonderland
INSERT INTO Library (book_fk_id, student_id, borrowed_date)
VALUES (
        (
            SELECT book_id
            FROM Book
            WHERE title = 'Alice In Wonderland'
        ),
        (
            SELECT student_id
            FROM Student
            WHERE name = 'John'
        ),
        '2022-02-15'
    );
-- Insert the record for Bob and To kill a mockingbird
INSERT INTO Library (book_fk_id, student_id, borrowed_date)
VALUES (
        (
            SELECT book_id
            FROM Book
            WHERE title = 'To kill a mockingbird'
        ),
        (
            SELECT student_id
            FROM Student
            WHERE name = 'Bob'
        ),
        '2021-03-03'
    );
-- Insert the record for Lera and Alice in Wonderland
INSERT INTO Library (book_fk_id, student_id, borrowed_date)
VALUES (
        (
            SELECT book_id
            FROM Book
            WHERE title = 'Alice In Wonderland'
        ),
        (
            SELECT student_id
            FROM Student
            WHERE name = 'Lera'
        ),
        '2021-05-23'
    );
-- Insert the record for Bob and Harry Potter
INSERT INTO Library (book_fk_id, student_id, borrowed_date)
VALUES (
        (
            SELECT book_id
            FROM Book
            WHERE title = 'Harry Potter'
        ),
        (
            SELECT student_id
            FROM Student
            WHERE name = 'Bob'
        ),
        '2021-08-12'
    );
-- Select all columns from the junction table
SELECT *
FROM Library;
-- Select the name of the student and the title of the borrowed books
SELECT s.name AS student_name,
    b.title AS book_title
FROM Library l
    JOIN Student s ON l.student_id = s.student_id
    JOIN Book b ON l.book_fk_id = b.book_id;
-- Select the average age of the children that borrowed the book Alice in Wonderland
SELECT AVG(s.age) AS avg_age
FROM Library l
    JOIN Student s ON l.student_id = s.student_id
    JOIN Book b ON l.book_fk_id = b.book_id
WHERE b.title = 'Alice In Wonderland';
-- To delete a student from the Student table, you can use the following SQL statement
DELETE FROM Student
WHERE name = 'John';