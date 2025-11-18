--------------------
-- imd_mid  
-- Baseline 
-- Number of adult patients from middle deprived areas  (Rankings from 13138 to 19706)
--------------------
WITH patient_ages AS (
  SELECT
    PK_Patient_ID,
    OrganisationCode AS prac_code,
    B.Name AS prac_name,
    Region AS region,
    IMD_Score,
    DATEDIFF(YEAR, dob, '2024-05-01')
      - CASE WHEN MONTH(dob) > 5 OR (MONTH(dob) = 5 AND DAY(dob) > 1) THEN 1 ELSE 0 END AS age
  FROM [BRIT].[Patient] A INNER JOIN [BRIT].[Reference_GP_Practice] B ON B.PK_Reference_GP_Practice_ID=A.FK_Reference_GP_Practice_ID
),
adult_patients AS (
  SELECT *
  FROM patient_ages P
  WHERE age >= 18 AND IMD_Score BETWEEN 13138 AND 19706
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,imd_mid)
  SELECT 
    prac_code,prac_name,region,
    COUNT(DISTINCT PK_Patient_ID) AS imd_mid
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
;
