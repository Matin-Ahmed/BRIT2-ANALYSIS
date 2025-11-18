--------------------
-- sex_male  
-- Baseline  
-- Number of male adult patients.
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
  FROM 
      [BRIT].[Patient] A 
      INNER JOIN [BRIT].[Reference_GP_Practice] B 
      ON B.PK_Reference_GP_Practice_ID=A.FK_Reference_GP_Practice_ID 
      INNER JOIN [BRIT].[patient_link] pl 
      ON A.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
      INNER JOIN BRIT.GP_Medications med  
      ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
  WHERE 
      Sex = 'M'
),
adult_patients AS (
  SELECT DISTINCT PK_Patient_ID,prac_code,prac_name,region
  FROM patient_ages
  WHERE age >= 18
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,sex_male)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(PK_Patient_ID) AS sex_male
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
