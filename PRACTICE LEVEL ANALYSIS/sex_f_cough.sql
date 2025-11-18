--------------------
-- sex_f_cough 
-- trial period  
-- Number of female adult patients with incident cough during trial period
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
    med.EventDate BETWEEN CAST('2023-02-01 00:00:00' AS DATETIME) and CAST('2024-02-01 00:00:00' AS DATETIME) 
    AND Sex = 'F'
    AND snomed.ConceptID IN (
'161929000',
'28743005',
'272039006',
'49727002',
'961781000006103',
'135883003',
'11833005',
'284523002',
'161923004',
'161924005',
'161925006',
'27836007'
)
),
adult_patients AS (
  SELECT DISTINCT PK_Patient_ID,prac_code,prac_name,region
  FROM patient_ages
  WHERE age >= 18
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,sex_f_cough)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(PK_Patient_ID) AS sex_f_cough
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
