------------
-- infect_throat_bl Baseline  Number of incident sore throats from adult patients during baseline year. 
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
    med.EventDate BETWEEN CAST('2023-02-01 00:00:00' AS DATETIME) and CAST('2024-02-01 00:00:00' AS DATETIME) 
    AND snomed.ConceptID IN ('195658003',
'195671000',
'195669000',
'195666007',
'195667003',
'399050001',
'363746003',
'195656004',
'195673002',
'17741008',
'195657008',
'195668008',
'195803003',
'41188003',
'162388002',
'195804009',
'164256007',
'162397003',
'15033003',
'405737000',
'195677001',
'267102003',
'538331000000101',
'43878008',
'85769006',
'186357007',
'41582007',
'90176007',
'300932000',
'186963008',
'232427004',
'173599005',
'232417005',
'195662009')
),
adult_patients AS (
  SELECT *
  FROM patient_ages
  WHERE age >= 18
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,infect_throat_bl)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(FK_Patient_Link_ID) AS infect_throat_bl
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
