------------
-- season_aut 
-- One year follow-up 
-- Number of prescriptions for adult patients during Autumn 2024 (22 Sep 2024 to 20 Dec 2024).
------------

WITH patient_ages AS (
  SELECT
    PK_Patient_ID,
    med.FK_Patient_Link_ID,
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
      INNER JOIN #GP_Medications_Dedup med  
      ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
  WHERE
  med.MedicationDate BETWEEN CAST('2024-09-22 00:00:00' AS DATETIME) and CAST('2024-12-20 00:00:00' AS DATETIME) 
),
adult_patients AS (
  SELECT 
    prac_code,
    prac_name,
    region,
    COUNT(FK_Patient_Link_ID) AS PERS_COUNT
  FROM patient_ages
  WHERE age >= 18
  GROUP BY 
    prac_code,
    prac_name,
    region
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,season_aut)
  SELECT
    prac_code,
    prac_name,
    region,
    PERS_COUNT AS season_aut
  FROM adult_patients
;
