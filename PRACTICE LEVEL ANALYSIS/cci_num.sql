--------------------
-- cci_num
-- Most recent record
-- Number of adult patients with a Charlson Comorbidity Index score
--------------------

WITH patient_ages AS (
  SELECT
    A.PK_Patient_ID,
    B.OrganisationCode AS prac_code,
    B.Name AS prac_name,
    B.Region AS region,
    DATEDIFF(YEAR, A.dob, '2024-05-01')
      - CASE
          WHEN MONTH(A.dob) > 5 OR (MONTH(A.dob) = 5 AND DAY(A.dob) > 1) THEN 1
          ELSE 0
        END AS age
  FROM BRIT.Patient A
  INNER JOIN BRIT.Reference_GP_Practice B
    ON B.PK_Reference_GP_Practice_ID = A.FK_Reference_GP_Practice_ID
),
adult_patients AS (
  SELECT PK_Patient_ID, prac_code, prac_name, region, MAX(age) AS age
  FROM patient_ages
  WHERE age >= 18
  GROUP BY PK_Patient_ID, prac_code, prac_name, region
),
adult_with_cci AS (
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
INSERT INTO PerPracticeData (prac_code, prac_name, region, cci_num)
SELECT
  prac_code,
  prac_name,
  region,
  COUNT(DISTINCT PK_Patient_ID) AS cci_num
FROM adult_with_cci
GROUP BY prac_code, prac_name, region
ORDER BY prac_code, prac_name, region;
