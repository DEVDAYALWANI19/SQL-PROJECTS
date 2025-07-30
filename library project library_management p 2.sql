-- Library Management System project 2

-- create table branch
drop table if exists branch;
create table branch(
	branch_id	varchar(10) primary key ,
	manager_id	varchar(10),
	branch_address	varchar(50),
	contact_no varchar(10)
);
alter table branch
alter column contact_no type varchar(20);


select * from branch;


drop table if exists employees;
create table employees(
	emp_id	varchar(10) primary key ,
	emp_name varchar (25),
	Position	varchar(15),
	salary	numeric (10,2),
	branch_id varchar(10)
);
select * from employees;

create table books(
	isbn varchar(20) primary key ,
	book_title varchar(20),
	category varchar(10),	
	rental_price float,
	status	 varchar(10),
	author varchar(25),
	publisher varchar(20)
);
alter table books
alter column book_title type varchar(75),
alter column publisher  type varchar(50),
alter column category type varchar(50);

select * from books;

create  table members(
	member_id varchar(10) primary key ,
	member_name varchar(20),
	member_address varchar(50),
	reg_date date

);

select * from members;

create table return_status(
	return_id varchar(10) primary key ,
	issued_id varchar(10),
	return_book_name varchar(10),
	return_date date ,
	return_book_isbn varchar(10)
);
select * from return_status;

create table issue_status(
	issued_id varchar(15) primary key ,
	issued_member_id varchar(15),
	issued_book_name varchar(25),
	issued_date date ,
	issued_book_isbn  varchar(25),
	issued_emp_id varchar(10)
);

alter table issue_status
alter column issued_book_name type varchar (75);  

select * from issue_status;


-- foreign key
alter table issue_status
add constraint fk_members
foreign key (issued_member_id)
references members(member_id);

alter table issue_status
add constraint fk_books
foreign key (issued_book_isbn)
references books(isbn);

alter table issue_status
add constraint fk_employees
foreign key (issued_emp_id)
references employees(emp_id);

alter table employees
add constraint fk_branch
foreign key (branch_id)
references branch(branch_id);

alter table return_status
add constraint fk_issue_status
foreign key (issued_id)
references issue_status(issued_id);


-- Project Task

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

insert into books(isbn , book_title , category, rental_price ,  status , author, publisher)
values ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books;

-- Task 2: Update an Existing Member's Address

update members
set member_address = '125 MAIN ST'
where member_id = 'C101';
select * from members order by member_id asc;

-- Task 3: Delete a Record from the Issue Status Table 
-- Objective: Delete the record with issued_id = 'IS121' from the issue_status table.

delete from issue_status
where issued_id = 'IS121';
select * from issue_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

select *from issue_status where issued_emp_id like 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.

select i.issued_id , e.emp_name from issue_status i
join employees e on i.issued_emp_id = e.emp_id
group by 1,2 having count(i.issued_id)>=1;

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
create table book_cnt
as 
  
	select b.isbn, b.book_title, count(i.issued_id) as no_issued
	from books b 
	join issue_status i on
	b.isbn = i.issued_book_isbn
	group by 1,2;

select * from book_cnt;

-- Task 7. Retrieve All Books in a Specific Category:

select * from books where category like 'Classic'; 

-- Task 8: Find Total Rental Income by Category:
select b.category , count(*), sum(b.rental_price) as total_income
from books b 
join issue_status i 
on  b.isbn = i.issued_book_isbn
group by 1;

-- List Members Who Registered in the Last 180 Days:
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C112', 'sam', '145 Main St', '2025-06-01'),
('C121', 'john', '133 Main St', '2025-05-01');

select * from members
where reg_date >=current_date  -interval '180 days';

-- task 10 List Employees with Their Branch Manager's Name and their branch details:

select e1.* , b.manager_id, e2.emp_name as manager 
from branch b 
join employees e1
on b.branch_id = e1.branch_id
join employees e2 
on b.manager_id = e2.emp_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 7USD:
 create table books_price_greater_than_seven
 as
select * from books
where rental_price >=7;
select * from books_price_greater_than_seven;

-- Task 12: Retrieve the List of Books  Returned
select  distinct i.issued_book_name
from return_status r
left join issue_status i 
on r.issued_id = i.issued_id
where r.return_id is  not null;

/*
Task 13: 
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

-- issued_status == members == books == return_status
-- filter books which is return
-- overdue > 30 

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

-- 
/*    
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
*/
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

/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

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

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

 create table active_members
 as
 select * from members
 where member_id in (select distinct(issued_member_id )
					 from issue_status 
					 where issued_date >= current_date - interval '18 month') ;
									
 select * from active_members;


