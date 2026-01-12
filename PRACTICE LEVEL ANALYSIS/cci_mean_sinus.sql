--------------------
-- cci_mean_sinus
-- Most recent record
-- Mean Charlson Comorbidity Index of adult patients with incident sinusitis during trial period.
--------------------

WITH patient_sinus AS (
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
    AND snomed.ConceptID IN (
      '67832005',
      '91038008',
      '68272006',
      '431231008',
      '15805002',
      '77919000',
      '35923002',
      '73237007',
      '60130002',
      '88850006',
      '40055000',
      '897657000',
      '78737005',
      '88348008',
      '195790000',
      '195788001',
      '36971009'
    )
),
adult_patients AS (
  SELECT PK_Patient_ID, prac_code, prac_name, region, MAX(age) AS age
  FROM patient_sinus
  WHERE age >= 18
  GROUP BY PK_Patient_ID, prac_code, prac_name, region
),
adult_patients_with_cci AS (
  SELECT
    ap.PK_Patient_ID,
    ap.prac_code,
    ap.prac_name,
    ap.region,
    cci.CCI_Score
  FROM adult_patients ap
  INNER JOIN BRIT.PerPatientCCIScore cci
    ON cci.PK_Patient_ID = ap.PK_Patient_ID
)
INSERT INTO PerPracticeData(prac_code, prac_name, region, cci_mean_sinus)
SELECT
  prac_code,
  prac_name,
  region,
  AVG(CAST(CCI_Score AS FLOAT)) AS cci_mean_sinus
FROM adult_patients_with_cci
GROUP BY prac_code, prac_name, region
ORDER BY prac_code, prac_name, region
;
