--------------------
-- sex_f_media 
-- Trial period  
-- Number of female adult patients with incident otitis media during trial period
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
    AND Sex = 'F'
    AND snomed.ConceptID IN (
'194290005',
'7271000119107',
'194288009',
'52353000',
'1088061000119105',
'1090681000119105',
'359609001',
'194240006',
'270490007',
'194289001',
'77478005',
'194281003',
'14948001',
'86279000',
'194282005',
'49252004',
'194286008',
'267756004',
'29350000',
'129127001',
'270491006',
'78868004',
'275481002',
'194237006',
'164236006',
'65363002',
'81564005',
'13420004',
'39288006',
'194287004',
'80327007'
)
),
adult_patients AS (
  SELECT DISTINCT PK_Patient_ID,prac_code,prac_name,region
  FROM patient_ages
  WHERE age >= 18
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,sex_f_media)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(PK_Patient_ID) AS sex_f_media
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
