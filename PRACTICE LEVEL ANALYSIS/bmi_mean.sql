----------------------
-- bmi_mean
-- Baseline
-- Mean BMI score of adult patients using the most recent BMI record.
----------------------

WITH patient_ages AS (
  SELECT
    A.PK_Patient_ID,
    B.OrganisationCode AS prac_code,
    B.Name AS prac_name,
    B.Region AS region,

    TRY_CONVERT(
        FLOAT,
        TRY_CONVERT(NVARCHAR(MAX), BMI_TABLE.BMI)
    ) AS BMI,

    BMI_TABLE.EventDate,

    DATEDIFF(YEAR, A.dob, '2024-05-01')
      - CASE 
          WHEN MONTH(A.dob) > 5 OR (MONTH(A.dob) = 5 AND DAY(A.dob) > 1) THEN 1
          ELSE 0
        END AS age

  FROM BRIT.Patient A
    INNER JOIN BRIT.Reference_GP_Practice B
      ON B.PK_Reference_GP_Practice_ID = A.FK_Reference_GP_Practice_ID
    INNER JOIN BRIT.patient_link pl
      ON A.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN (
        SELECT 
            E.FK_Patient_Link_ID,
            E.EventDate,
            E.Value AS BMI
        FROM BRIT.GP_Events E
        INNER JOIN BRIT.Reference_SnomedCT R
          ON E.FK_Reference_SnomedCT_ID = R.PK_Reference_SnomedCT_ID
        WHERE R.ConceptID IN (
            '60621009',
            '140075008',
            '162859006',
            '363807006'
        )
    ) AS BMI_TABLE
      ON BMI_TABLE.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
),

most_recent_bmi AS (
  SELECT
    PK_Patient_ID,
    prac_code,
    prac_name,
    region,
    MAX(EventDate) AS EventDate
  FROM patient_ages
  GROUP BY PK_Patient_ID, prac_code, prac_name, region
),

adult_patients AS (
  SELECT DISTINCT
    A.PK_Patient_ID,
    A.prac_code,
    A.prac_name,
    A.region,
    A.BMI
  FROM patient_ages A
    INNER JOIN most_recent_bmi B
      ON A.PK_Patient_ID = B.PK_Patient_ID
      AND A.prac_code   = B.prac_code
      AND A.prac_name   = B.prac_name
      AND A.region      = B.region
      AND A.EventDate   = B.EventDate
  WHERE 
    A.age >= 18
    AND A.BMI BETWEEN 10 AND 70
)

INSERT INTO PerPracticeData(prac_code, prac_name, region, bmi_mean)
SELECT
  prac_code,
  prac_name,
  region,
  AVG(BMI) AS bmi_mean
FROM adult_patients
GROUP BY prac_code, prac_name, region
;
