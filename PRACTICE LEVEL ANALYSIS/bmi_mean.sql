----------------------
-- bmi_mean
-- Most recent record Mean BMI score of adult patients using the most recent record.
----------------------

  WITH patient_ages AS (
    SELECT
      PK_Patient_ID,
      OrganisationCode AS prac_code,
      B.Name AS prac_name,
      Region AS region,
      CONVERT(FLOAT,CONVERT(VARCHAR(20),BMI_TABLE.BMI)) AS BMI,
      EventDate,
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
        INNER JOIN 
  (
  SELECT [FK_Patient_Link_ID]
        ,[EventDate]
        ,[Value] AS BMI
    FROM [BRIT].[GP_Events] E
      INNER JOIN [BRIT].[Reference_SnomedCT] R
          ON E.FK_Reference_SnomedCT_ID = R.PK_Reference_SnomedCT_ID
    WHERE R.ConceptID IN (
       '60621009'
      ,'140075008'
      ,'162859006'
      ,'363807006')
      ) AS BMI_TABLE ON BMI_TABLE.FK_Patient_Link_ID = pl.PK_Patient_Link_ID

  ),
  adult_patients AS (
    SELECT 
      PK_Patient_ID,
      prac_code,
      prac_name,
      region,
      EventDate,
      MAX(BMI) AS BMI
    FROM patient_ages
    WHERE age >= 18  AND BMI >= 10 AND BMI <= 70
  GROUP BY 
      PK_Patient_ID,
      prac_code,
      prac_name,
      region,
      EventDate
  )
  INSERT INTO PerPracticeData(prac_code,prac_name,region,bmi_mean)
    SELECT
      prac_code,
      prac_name,
      region,
      AVG(CAST(BMI AS FLOAT)) AS bmi_mean
    FROM adult_patients
    GROUP BY prac_code,prac_name,region
    ORDER BY prac_code,prac_name,region
  ;
