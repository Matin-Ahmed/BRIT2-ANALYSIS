------------
-- smoke_unk  
-- Most recent record 
-- Number of adult patients where smoking status is unknown using the most recent record.
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
      INNER JOIN BRIT.GP_Events med  
      ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
      INNER JOIN BRIT.Reference_SnomedCT snomed
      ON snomed.PK_Reference_SnomedCT_ID = med.FK_Reference_SnomedCT_ID
  WHERE
    snomed.ConceptID IN ('1098881000000100',
'266927001',
'711563001',
'375911000000102',
'160614008')
),
adult_patients AS (
  SELECT *
  FROM patient_ages
  WHERE age >= 18
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,smoke_unk)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(DISTINCT PK_Patient_ID) AS smoke_unk
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
