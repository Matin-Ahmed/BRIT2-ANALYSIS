--------------------
-- age_subgrp  
-- Baseline  
-- Number of adult patients who are at least 65yrs old.
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
  WHERE age >= 65
  group by PK_Patient_ID,prac_code,prac_name,region
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,age_subgrp)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(PK_Patient_ID) AS age_subgrp
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
