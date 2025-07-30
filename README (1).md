# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System   
**Database**: `sql_library_project_2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.

## Project Structure

### 1. Database Setup


- **Database Creation**: Created a database named `sql_library_project_2`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE sql_library_project_2;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);

DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);


DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);


DROP TABLE IF EXISTS issue_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);


DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
insert into books(isbn , book_title , category, rental_price ,  status , author, publisher)
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;
```
**Task 2: Update an Existing Member's Address**

```sql
update members
set member_address = '125 MAIN ST'
where member_id = 'C101';
select * from members order by member_id asc;

```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
delete from issue_status
where issued_id = 'IS121';
select * from issue_status;

```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
select *from issue_status where issued_emp_id like 'E101';

```

**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select i.issued_id , e.emp_name from issue_status i
join employees e on i.issued_emp_id = e.emp_id
group by 1,2 having count(i.issued_id)>=1;

```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_cnt
as 
  
	select b.isbn, b.book_title, count(i.issued_id) as no_issued
	from books b 
	join issue_status i on
	b.isbn = i.issued_book_isbn
	group by 1,2;

select * from book_cnt;

```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

**Task 7. Retrieve All Books in a Specific Category**:

```sql
select * from books where category like 'Classic'; 
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select b.category , count(*), sum(b.rental_price) as total_income
from books b 
join issue_status i 
on  b.isbn = i.issued_book_isbn
group by 1;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C112', 'sam', '145 Main St', '2025-06-01'),
('C121', 'john', '133 Main St', '2025-05-01');

select * from members
where reg_date >=current_date  -interval '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select e1.* , b.manager_id, e2.emp_name as manager 
from branch b 
join employees e1
on b.branch_id = e1.branch_id
join employees e2 
on b.manager_id = e2.emp_id;
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
 create table books_price_greater_than_seven
 as
select * from books
where rental_price >=7;
select * from books_price_greater_than_seven;

```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select  distinct i.issued_book_name
from return_status r
left join issue_status i 
on r.issued_id = i.issued_id
where r.return_id is  not null;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT  iss.issued_member_id,
    m.member_name,
    b.book_title,
    iss.issued_date,
    -- rs.return_date,
    CURRENT_DATE - iss.issued_date as over_dues_days
FROM issue_status as iss
JOIN 
members as m
    ON m.member_id = iss.issued_member_id 
JOIN 
books as b
ON b.isbn = iss.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = iss.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - iss.issued_date) > 30
ORDER BY 1

```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

select * from issue_status
where  issued_book_isbn ='978-0-553-29698-2'


select * from books where isbn ='978-0-553-29698-2'

update books
set status ='YES'
where isbn ='978-0-553-29698-2'
 
select * from return_status where issued_id ='IS119'


insert into  return_status(return_id ,issued_id , return_date)
values('RS119', 'IS119' ,  CURRENT_DATE)

-- Stored PROCEDURE

CREATE OR REPLACE PROCEDURE add_return_records(p_return_id  varchar(10) ,p_issued_id varchar(10))
LANGUAGE plpgsql
 as $$
 DECLARE
 v_isbn varchar(20);
 v_book_name varchar(75);
 begin 
        	 
		insert into  return_status(return_id  ,issued_id  , return_date)
		values(p_return_id ,p_issued_id, CURRENT_DATE);

		select issued_book_isbn,
		issued_book_name
		into  v_isbn,
		v_book_name
		from issue_status
		where issued_id =p_issued_id;
		 update books
			set status ='YES'
			where isbn =v_isbn;
			raise notice ' thank you for returning the book %', v_book_name;
 end;
 $$

 call add_return_records();


 -- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issue_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135');

select * from issue_status
-- calling function 
CALL add_return_records('RS148', 'IS140');

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
 create TABLE branch_report
 as 
select bh.branch_id,
		bh.manager_id,
		sum(b.rental_price) as total_revenue,
		count(iss.issued_id ) as no_books_issued,
		count (rs.return_id) as no_books_returned
from issue_status iss
join employees e1 
on iss.issued_emp_id= e1.emp_id
join 
branch bh on bh.branch_id = e1.branch_id
left join return_status rs
on rs.issued_id = iss.issued_id
JOIN
books b on b.isbn = iss.issued_book_isbn
group by 1 order by total_revenue desc;

SELECT * from branch_report;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

 create table active_members
 as
 select * from members
 where member_id in (select distinct(issued_member_id )
             from issue_status 
             where issued_date >= current_date - interval '18 month') ;
                                                            
 select * from active_members;

```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **create Database**: create database 
2. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
3. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Dev Dayalwani


Thank you for your interest in this project!
