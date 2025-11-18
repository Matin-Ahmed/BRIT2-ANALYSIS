--------------------
-- age_mean  
-- Baseline  
-- Mean age (years) of adult patients from GP practice at start of trial period (i.e. 1st May 2024).
--------------------

WITH patient_ages AS (
  SELECT
    PK_Patient_ID,
    OrganisationCode AS prac_code,
    B.Name AS prac_name,
    Region AS region,
    DATEDIFF(YEAR, dob, '2024-05-01') 
      - CASE 
          WHEN MONTH(dob) > 5 OR (MONTH(dob) = 5 AND DAY(dob) > 1) THEN 1 
          ELSE 0 
        END AS age
  FROM [BRIT].[Patient] A INNER JOIN [BRIT].[Reference_GP_Practice] B ON B.PK_Reference_GP_Practice_ID=A.FK_Reference_GP_Practice_ID
),
adult_patients AS (
  SELECT PK_Patient_ID,prac_code,prac_name,region,MAX(age) AS age
  FROM patient_ages
  WHERE age >= 18
  GROUP BY PK_Patient_ID,prac_code,prac_name,region
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,age_mean)
  SELECT
    prac_code,
    prac_name,
    region,
    AVG(CAST(age AS FLOAT)) AS age_mean
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
