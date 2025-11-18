--------------------
-- sex_m_externa 
-- Trial period  
-- Number of male adult patients with incident otitis externa during trial period
--------------------

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
      INNER JOIN BRIT.GP_Events med  
      ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
      INNER JOIN BRIT.Reference_SnomedCT snomed
      ON snomed.PK_Reference_SnomedCT_ID = med.FK_Reference_SnomedCT_ID
  WHERE
    med.EventDate BETWEEN CAST('2024-05-01 00:00:00' AS DATETIME) and CAST('2025-05-01 00:00:00' AS DATETIME) 
    AND Sex = 'M'
    AND snomed.ConceptID IN (
'232212002',
'54272002',
'56663002',
'267665002',
'30250000',
'45855004',
'232214001',
'402699002',
'76583009',
'403432008',
'403433003',
'232224009',
'45431004',
'95812002',
'194202008',
'194204009',
'33934002',
'194203003',
'402697000',
'86981007',
'111856000',
'21954000',
'3135009',
'575931000000108',
'34129005'
)
),
adult_patients AS (
  SELECT DISTINCT PK_Patient_ID,prac_code,prac_name,region
  FROM patient_ages
  WHERE age >= 18
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,sex_m_externa)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(PK_Patient_ID) AS sex_m_externa
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
