select * 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'hr_data'


select * from hr_data

-- How many employees in the table
select 
	count(distinct EmployeeNumber) as total_emp
from hr_data

-- How many left and how many stayed

select 
	Attrition,
	count(distinct EmployeeNumber) as NumberofEmp
from hr_data
group by Attrition

-- Overall % Attrition rate

Alter table hr_data
alter column Attrition Varchar(20)

UPDATE hr_data
SET Attrition = CASE WHEN Attrition = '1' THEN 'Yes'
                     WHEN Attrition = '0' THEN 'No'
                END;


update hr_data
set Attrition = 'yes'
where Attrition = '1'




select 
	round(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END)/ count(*),2) as pct
from hr_data


-- How many employees are in each department?

select Department,count(*) as NumberofEmp
from hr_data
group by Department

-- What are the minimum, maximum, and average monthly income?

select 
	min(MonthlyIncome) as Minimum,
	max(MonthlyIncome) as Maximum,
	avg(MonthlyIncome) as Avgerage

from hr_data

-- What is the attrition rate by department?

select 
	count(*) as Totalemp,
	sum(case when Attrition = 'Yes' then 1 else 0 end) as Leaver,
	round((sum(case when Attrition = 'Yes' then 1 else 0 end) * 100) /count(*),2) as Attrition_rate
from hr_data
group by Department;


-- What is the attrition rate for overtime vs. no overtime?
with cte as (
select 
	OverTime,
	count(*) as Total_emp,
	sum(case when Attrition = 'Yes' then 1 else 0 end) as leaver
from hr_data
group by OverTime
)

select
	OverTime,
	total_emp,
	leaver,
	round((leaver * 100)/Total_emp,2) as attrition_rate
from cte

-- What is the average monthly income by job role? Sort from highest to lowest.

select 
	JobRole,
	avg(MonthlyIncome) as Average_Income
from hr_data
group by JobRole
order by Average_Income desc

-- What is the gender split (count and %)

SELECT Gender,
       COUNT(*) AS employee_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct
FROM hr_data
GROUP BY Gender
ORDER BY employee_count DESC;

-- What is the average years at company for employees who left vs. stayed?

select 
	attrition,
	avg(YearsAtCompany) as AvgYearAtCompany
from hr_data
group by Attrition

-- Which job roles have an attrition rate above the company average?


select 
	JobRole,
	count(Attrition) as Total_Emp,
	sum(case when Attrition = 'Yes' then 1 else 0 end) as leaver,
	round(sum(case when Attrition = 'Yes' then 1 else 0 end) * 100 / count(Attrition), 2 ) as attrition_rate

from hr_data
group by JobRole

-- What is the average income by job level and gender? Is there a gap?

select
	JobRole,
	Gender,
	avg(MonthlyIncome) as Avg_Income
from hr_data
group by JobRole,gender
order by JobRole,gender

-- Gap

select 
	jobrole,
	AVG(case when gender = 'Male' then MonthlyIncome end) as Male_AVG,
	avg(case when gender = 'Female' then MonthlyIncome end) as Female_AVG,
	ABS(AVG(case when gender = 'Male' then MonthlyIncome end) - avg(case when gender = 'Female' then MonthlyIncome end)) as Gap
from hr_data
group by JobRole


-- What is the attrition rate by overtime and marital status together?
select
	OverTime,
	MaritalStatus,
	count(attrition) as total,
	sum(case when Attrition = 'Yes' then 1 else 0 end) as leaver,
	round((sum(case when Attrition = 'Yes' then 1 else 0 end) * 100) / count(attrition),2) as Attrition_Rate
from hr_data
group by OverTime,MaritalStatus;


-- Which job roles have an attrition rate above the company average?

select 
	JobRole,
	COUNT(Attrition) as Total_Attrition,
	sum(case when Attrition = 'Yes' then 1 else 0 end) as Leaver,
	ROUND(100 *sum(case when Attrition = 'Yes' then 1 else 0 end) / COUNT(Attrition),2) as Attrition_Rate
from hr_data
group by JobRole
having 
ROUND(100 *sum(case when Attrition = 'Yes' then 1 else 0 end) / COUNT(Attrition),2) > (
		select
			ROUND(100 *sum(case when Attrition = 'Yes' then 1 else 0 end) / COUNT(Attrition),2)
		from hr_data
		)

-- Use CASE WHEN to create income bands (<3K, 3K-6K, 6K-10K, 10K+) and find the attrition rate for each.
select 
	MonthlyIncome_Band,
	COUNT(Attrition) as Total_Attrition,
	sum(case when Attrition = 'Yes' then 1 else 0 end) as Leaver,
	ROUND(100 *sum(case when Attrition = 'Yes' then 1 else 0 end) / COUNT(Attrition),2) as Attrition_Rate
from hr_data
group by MonthlyIncome_Band

-- Which departments have more than 100 employees and an attrition rate above 15%?

select 
Department,
count(EmployeeNumber) as TotalEmployees,
round(100 *sum(case when Attrition = 'Yes' then 1 else 0 end)/count(Attrition),2) as Attrition_rate
from hr_data
group by Department
having 
	count(EmployeeNumber) > 100
	and
	round(100 *sum(case when Attrition = 'Yes' then 1 else 0 end)/count(Attrition),2) > 15
	-- Sales have attrition rate greater than 15 and have employees greater than 100



-- Which employees earn less than the average income of their own job role?

select 
	MonthlyIncome,
	EmployeeNumber,
	JobRole
from hr_data
where MonthlyIncome < (
select avg(MonthlyIncome)
from hr_data
)

-- Rank job roles by attrition rate within each department.

with cte as(select
	Department,
	jobrole,
	COUNT(Attrition) as total_attrition,
	SUM(case when Attrition = 'Yes' then 1 else 0 end) as Leaver,
	ROUND(100 * SUM(case when Attrition = 'Yes' then 1 else 0 end) / COUNT(Attrition),2) as Attrition_Rate
from hr_data
group by Department,JobRole)

select *,
	RANK() over (partition by department order by Attrition_Rate desc ) rnk
from cte
order by Department, rnk
