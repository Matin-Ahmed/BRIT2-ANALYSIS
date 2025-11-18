------------
-- season_sum 
-- One year follow-up 
-- Number of prescriptions for adult patients during Summer 2024 (20 Jun 2024 to 21 Sep 2024).
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
      INNER JOIN BRIT.GP_Medications med  
      ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
  WHERE
    med.MedicationDate BETWEEN CAST('2024-06-20 00:00:00' AS DATETIME) and CAST('2024-09-21 00:00:00' AS DATETIME) 
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
INSERT INTO PerPracticeData(prac_code,prac_name,region,season_sum)
  SELECT
    prac_code,
    prac_name,
    region,
    PERS_COUNT AS season_sum
  FROM adult_patients
;
