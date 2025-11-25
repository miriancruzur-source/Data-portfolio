CREATE database salary_insights;
use salary_insights;

SELECT * FROM salary
WHERE work_year < 2023;

#Creamos nueva tabla para trabajar sobre ella y limpiarla, esto sirve por si cometemo algun error que no afecte a la tabla original.
CREATE TABLE salary_clean
LIKE salary;

INSERT salary_clean
SELECT *
FROM salary;

#Tipos correctos, textos normalizados, filtros básicos de calidad (salarios positivos, años razonables, etc.), etiquetas “humanas” para experiencia y tipo de contrato
CREATE TABLE salary_insights.salary_clean2 AS
SELECT id, work_year,
    UPPER(TRIM(experience_level)) AS experience_level,
    CASE UPPER(TRIM(experience_level))
        WHEN 'EN' THEN 'Entry-level'
        WHEN 'MI' THEN 'Mid-level'
        WHEN 'SE' THEN 'Senior'
        WHEN 'EX' THEN 'Executive'
        ELSE 'Unknown'
    END AS experience_label,
    UPPER(TRIM(employment_type)) AS employment_type,
    CASE UPPER(TRIM(employment_type))
        WHEN 'FT' THEN 'Full-time'
        WHEN 'PT' THEN 'Part-time'
        WHEN 'CT' THEN 'Contract'
        WHEN 'FL' THEN 'Freelance'
        ELSE 'Other'
    END AS employment_label,
    TRIM(job_title) AS job_title,
    salary,
    UPPER(TRIM(salary_currency)) AS salary_currency,
    salary_in_usd,
    UPPER(TRIM(employee_residence)) AS employee_residence,
    remote_ratio,
    UPPER(TRIM(company_location)) AS company_location,
    UPPER(TRIM(company_size)) AS company_size
FROM salary_clean
WHERE salary_in_usd IS NOT NULL
  AND salary_in_usd > 0
  AND work_year BETWEEN 2020 AND 2024;
  
  #Rango de salarios y años
  SELECT
  MIN(work_year) AS min_year,
  MAX(work_year) AS max_year,
  MIN(salary_in_usd) AS min_salary_usd,
  AVG(salary_in_usd) AS avg_salary_usd,
  MAX(salary_in_usd) AS max_salary_usd
FROM salary_clean2;

#Valores nulos
SELECT
  'work_year' AS column_name,
  COUNT(*) AS nulls
FROM salary_clean2
WHERE work_year IS NULL

UNION ALL
SELECT 'job_title', COUNT(*) FROM salary_clean WHERE job_title IS NULL
UNION ALL
SELECT 'salary_in_usd', COUNT(*) FROM salary_clean WHERE salary_in_usd IS NULL;

#DATA ANALYSIS
#Panorama general del mercado (gráfica de evolución de salarios en el tiempo)
SELECT
  work_year,
  COUNT(*) AS n_roles,
  ROUND(AVG(salary_in_usd)) AS avg_salary_usd,
  ROUND(STDDEV_POP(salary_in_usd)) AS std_salary_usd
FROM salary_insights.salary_clean2
GROUP BY work_year
ORDER BY work_year;

#Top job titles mejor pagados (con tamaño de muestra decente) (Sirve para tabla/grafico mejor top 15 posiciones pagadas)
SELECT
  job_title,
  COUNT(*) AS n_roles,
  ROUND(AVG(salary_in_usd)) AS avg_salary_usd
FROM salary_insights.salary_clean2
GROUP BY job_title
ORDER BY avg_salary_usd DESC
LIMIT 20;

#Como he visto que hay roles que solo tienen 1 registro, lo que quiero es que tengan mas para ver un avg real.
SELECT
  job_title,
  COUNT(*) AS n_roles,
  ROUND(AVG(salary_in_usd)) AS avg_salary_usd
FROM salary_insights.salary_clean2
GROUP BY job_title
HAVING COUNT(*) >= 20
ORDER BY avg_salary_usd DESC
LIMIT 20;

#Salario por nivel de experiencia (Bar chart sencillo nivel experiencia)
SELECT
  experience_label,
  COUNT(*) AS n_roles,
  ROUND(AVG(salary_in_usd)) AS avg_salary_usd
FROM salary_insights.salary_clean2
GROUP BY experience_label
ORDER BY avg_salary_usd DESC;

#Diferencias remoto vs presencial
SELECT
  CASE
    WHEN remote_ratio = 0 THEN 'On-site'
    WHEN remote_ratio BETWEEN 1 AND 99 THEN 'Hybrid'
    WHEN remote_ratio = 100 THEN 'Fully remote'
    ELSE 'Unknown'
  END AS remote_type,
  COUNT(*) AS n_roles,
  ROUND(AVG(salary_in_usd)) AS avg_salary_usd
FROM salary_insights.salary_clean2
GROUP BY remote_type
ORDER BY avg_salary_usd DESC;

#Salarios por tamaño de empresa
SELECT
  company_size,
  COUNT(*) AS n_roles,
  ROUND(AVG(salary_in_usd)) AS avg_salary_usd
FROM salary_insights.salary_clean2
GROUP BY company_size
ORDER BY company_size;

#Exportar tabla clean
SELECT *
FROM salary_insights.salary_clean2;






