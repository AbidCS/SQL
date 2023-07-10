+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| salary      | int  |
+-------------+------+
id is the primary key column for this table.
Each row of this table contains information about the salary of an employee.
 

Find the second highest salary from the Employee table. If there is no second highest salary, return null.

The result format is in the following example.

 

Example 1:

Input: 
Employee table:
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+
Output: 
+---------------------+
| SecondHighestSalary |
+---------------------+
| 200                 |
+---------------------+
Example 2:

Input: 
Employee table:
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
+----+--------+
Output: 
+---------------------+
| SecondHighestSalary |
+---------------------+
| null                |
+---------------------+


drop table if exists employee;
Create table If Not Exists Employee (id int, salary int);
Truncate table Employee;
insert into Employee (id, salary) values ('1', '100');
insert into Employee (id, salary) values ('2', '200');
insert into Employee (id, salary) values ('3', '300');


--Solution 1
SELECT max(salary) as SecondHighestSalary
FROM (
   SELECT *, dense_Rank() OVER ( ORDER BY salary DESC) AS rnk
   FROM employee
) AS a
WHERE rnk = 2
LIMIT 1;

--Solution 2
select max(salary) as SecondHighestSalary from employee where salary <(select max(salary) from employee);


