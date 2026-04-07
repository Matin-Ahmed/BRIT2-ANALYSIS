------------
-- infect_externa_bl  Baseline  Number of otitis-externa-coded GP event rows from adult patients during baseline year.
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
            '232212002',
            '54272002',
            '56663002',
            '267665002',
            '30250000',
            '45855004',
            '232214001',
            '402699002',
            '76583009',
            '403432008',
            '403433003',
            '232224009',
            '45431004',
            '95812002',
            '194202008',
            '194204009',
            '33934002',
            '194203003',
            '402697000',
            '86981007',
            '111856000',
            '21954000',
            '3135009',
            '575931000000108',
            '34129005'
      )
),
adult_patients AS (
    SELECT *
    FROM patient_ages
    WHERE age >= 18
)
INSERT INTO PerPracticeData (prac_code, prac_name, region, infect_externa_bl)
SELECT
    prac_code,
    prac_name,
    region,
    COUNT(*) AS infect_externa_bl
FROM adult_patients
GROUP BY
    prac_code,
    prac_name,
    region
ORDER BY
    prac_code,
    prac_name,
    region;
