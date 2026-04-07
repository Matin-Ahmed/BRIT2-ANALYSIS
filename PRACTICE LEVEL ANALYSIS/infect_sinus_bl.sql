------------
-- infect_sinus_bl  Baseline  Number of sinusitis-coded GP event rows from adult patients during baseline year.
------------

WITH patient_ages AS (
    SELECT
        A.PK_Patient_ID,
        med.FK_Patient_Link_ID,
        B.OrganisationCode AS prac_code,
        B.Name AS prac_name,
        B.Region AS region,
        DATEDIFF(YEAR, A.dob, '2024-05-01')
          - CASE
                WHEN MONTH(A.dob) > 5 OR (MONTH(A.dob) = 5 AND DAY(A.dob) > 1) THEN 1
                ELSE 0
            END AS age
    FROM [BRIT].[Patient] A
    INNER JOIN [BRIT].[Reference_GP_Practice] B
        ON B.PK_Reference_GP_Practice_ID = A.FK_Reference_GP_Practice_ID
    INNER JOIN [BRIT].[patient_link] pl
        ON A.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.GP_Events med
        ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.Reference_SnomedCT snomed
        ON snomed.PK_Reference_SnomedCT_ID = med.FK_Reference_SnomedCT_ID
    WHERE med.EventDate >= CAST('2023-02-01 00:00:00' AS DATETIME)
      AND med.EventDate <  CAST('2024-02-01 00:00:00' AS DATETIME)
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
    SELECT *
    FROM patient_ages
    WHERE age >= 18
)
INSERT INTO PerPracticeData (prac_code, prac_name, region, infect_sinus_bl)
SELECT
    prac_code,
    prac_name,
    region,
    COUNT(*) AS infect_sinus_bl
FROM adult_patients
GROUP BY
    prac_code,
    prac_name,
    region
ORDER BY
    prac_code,
    prac_name,
    region;
