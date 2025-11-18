------------
-- frail_fitmild  
-- Most recent record 
-- Number of patients at least 65 yrs old with frailty score <= 0.24 using the most recent record.
------------

WITH patient_ages AS (
  SELECT
    PK_Patient_ID,
    OrganisationCode AS prac_code,
    B.Name AS prac_name,
    Region AS region,
    FrailtyScore,
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
),
adult_patients AS (
  SELECT 
    PK_Patient_ID,
    prac_code,
    prac_name,
    region,
    MAX(FrailtyScore) AS FrailtyScore
  FROM patient_ages
  WHERE age >= 65 and FrailtyScore <= 0.24
GROUP BY 
    PK_Patient_ID,
    prac_code,
    prac_name,
    region
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,frail_fitmild)
  SELECT
    prac_code,
    prac_name,
    region,
    Count(PK_Patient_ID) AS frail_fitmild
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
