CREATE DATABASE Rebrickable
GO
USE Rebrickable
GO
-- What  is the total number of part per theme?
Create View dbo.analystics_main as

Select s.set_num, s.name as set_name, s.year, s.theme_id,cast(s.num_parts as numeric) num_parts, t.name as theme_name, t.parent_id,
p.name as parent_theme_name
From sets as s left  join themes as t on s.theme_id = t.id
			   Left join themes as p on t.parent_id = p.id 


Select * From dbo.analystics_main

Select theme_name, sum(num_parts) as total_num_parts
From analystics_main
Where parent_theme_name is not null
Group by theme_name
ORDER BY SUM(num_parts) desc

--2. What is the total number of part per year?
Select year, sum(num_parts) as total_num_parts
From analystics_main
Where parent_theme_name is not null
Group by year
ORDER BY SUM(num_parts) desc

--3. How many sets where created in each Century in the Dataset?

ALTER VIEW dbo.analystics_main As
Select s.set_num, s.name as set_name, s.year, s.theme_id,cast(s.num_parts as numeric) num_parts, t.name as theme_name, t.parent_id,
p.name as parent_theme_name, 
CASE
	WHEN s.year Between 1901 and 2000 then '20th_Century'
	WHEN s.year Between 2001 and 2100 then '21st_Century'
END
As Century
From sets as s left  join themes as t on s.theme_id = t.id
			   Left join themes as p on t.parent_id = p.id 
GO

Select Century, Count(set_num) as Total_sets
From analystics_main
--Where parent_theme_name is not null
Group by Century

--4.What percentage of sets ever released in the 21st Century were Trains theme?
S

with t1 as (
Select Century, theme_name,  Count(set_num) as Total_sets_21Century
From analystics_main
Where Century = '21st_Century'
Group by Century, theme_name)

Select sum(Total_sets_21Century) as Total_set_num, Sum(Percentage) as Percentage
From (
	Select Century, theme_name, Total_sets_21Century, sum(Total_sets_21Century) OVER () as Total,
	cast(1.00*Total_sets_21Century/ sum(Total_sets_21Century) OVER () as decimal (5,4)) *100 as Percentage
	From t1
	--Where theme_name Like '%train%'
	--Order by 3 desc
) as m
Where theme_name like '%train%'

--5. What was the popular theme by year in term of ses released in 21st Century ?
With t as (
	Select year, theme_name, count(set_num) as total_set_num, Row_Number() Over (partition by year Order by count(set_num) Desc) as rank_no
	From analystics_main
	Where Century = '21st_Century'
	Group by year, theme_name
	--Order by year Desc
)
Select year, theme_name, total_set_num 
From t
Where rank_no = 1
order by year Desc

--6. What is the most produced color of logo ever in term of quantity of part?
Select *
From (
Select c.name as color_name, sum(Cast (i.quantity as numeric)) as Total_part
From colors as c 
Left join inventory_parts as i on c.id= i.color_id
Group by c.name
) as a
Order by total_part Desc
