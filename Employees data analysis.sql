--İsçinin işlədiyi departamenti, əmək haqqısı və işlədiyi vəzifəsi

SELECT 
    e.employee_id,e.first_name||' '||e.last_name full_name,
    j.job_title,
    e.salary,d.department_name
FROM employees e
left join departments d
on e.department_id=d.department_id
left join jobs j
on e.job_id=j.job_id;

--------------------------------------------------------------------------------
--İsçinin işlədiyi departamentin minimum, maximum əmək haqqısı, işçinin aldığı əmək haqqı ümumi əmək haqqı büdcəsinin neçə faizini təşkil edir.

SELECT a.*,
    first_value(salary) over(partition by department_name order by salary ROWS UNBOUNDED PRECEDING) low_salary,
    nth_value(salary,1) over(partition by department_name order by salary desc RANGE BETWEEN UNBOUNDED PRECEDING
                                                                          AND UNBOUNDED FOLLOWING ) high_salary,
    round(salary/(sum(salary) over ()) *100,3) percent
FROM
(
    SELECT 
        e.employee_id,e.first_name||' '||e.last_name full_name,
        e.salary,d.department_name,
        j.job_title
    FROM employees e
    left join departments d
    on e.department_id=d.department_id
    left join jobs j
    on e.job_id=j.job_id
)a;

--------------------------------------------------------------------------------
--İşçinin ilk dəfə işə götürülmə tarixi ve işə götürüldüyü vəzifə

SELECT employee_id,full_name,job_title,department_name,first_job_date
FROM
( 
 SELECT 
        employee_id,full_name,job_title,department_id,department_name,start_date,
        first_value(start_date) over (partition by employee_id order by start_date) first_job_date       
    FROM
(     
       SELECT 
               e.employee_id,e.first_name||' '||e.last_name full_name,
               j.job_id,j.job_title,
               e.salary,d.department_name,d.department_id,
               jh.start_date, jh.end_date
        FROM job_history jh
        inner join jobs j
        on jh.job_id=j.job_id            
        inner join departments d
        on jh.department_id=d.department_id
        inner join employees e
        on e.employee_id=jh.employee_id            
)a
)
where start_date=first_job_date;
------------------------------------------------------------------
--İşçinin son dəfə vəzifəsinin dəyişilmə tarixi və vəzifəsi

SELECT employee_id,full_name,job_title,department_name,last_job_date  
FROM
( 
 SELECT 
        employee_id,full_name,job_title,department_id,department_name,start_date,
        first_value(start_date) over (partition by employee_id order by start_date desc) last_job_date       
    FROM
(     
       SELECT 
               e.employee_id,e.first_name||' '||e.last_name full_name,
               j.job_id,j.job_title,
               e.salary,d.department_name,d.department_id,
               jh.start_date, jh.end_date
        FROM job_history jh
        inner join jobs j
        on jh.job_id=j.job_id            
        inner join departments d
        on jh.department_id=d.department_id
        inner join employees e
        on e.employee_id=jh.employee_id            
)a
)
where start_date=last_job_date;
------------------------------------------------------------
--Yalnız nə vaxtsa vəzifəsi dəyişmiş işçilərin siyahısı ve İşçinin vəzifəsinin dəyişmə sayı

SELECT a.*,count(*)
FROM
(
SELECT
         e.employee_id,e.first_name||' '||e.last_name full_name,
        d.department_name
    FROM job_history jh
    inner join jobs j
    on jh.job_id=j.job_id            
    inner join departments d
    on jh.department_id=d.department_id
    inner join employees e
    on e.employee_id=jh.employee_id
)a
GROUP BY employee_id,full_name,department_name;
