------------
-- infect_total_bl  Baseline  Total number of common-infection-coded GP event rows from adult patients during baseline year.
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
            -- cough
            '161929000',
            '28743005',
            '272039006',
            '49727002',
            '961781000006103',
            '135883003',
            '11833005',
            '284523002',
            '161923004',
            '161924005',
            '161925006',
            '27836007',

            -- externa
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
            '34129005',

            -- sinus
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
            '36971009',

            -- uti
            '68226007',
            '38822007',
            '275412000',
            '267204006',
            '199107005',
            '199106001',
            '199108000',
            '199109008',
            '199110003',
            '197926005',
            '197853008',
            '197927001',
            '314940005',
            '68566005',
            '74741000006107',
            '368991000119100',
            '301011002',
            '1',
            '369001000119100',
            '369011000119102',
            '307534009',
            '609491002',
            '199111004',
            '61373006',

            -- media
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
            '80327007',

            -- throat
            '195658003',
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
            '195662009'
      )
),
adult_patients AS (
    SELECT *
    FROM patient_ages
    WHERE age >= 18
)
INSERT INTO PerPracticeData (prac_code, prac_name, region, infect_total_bl)
SELECT
    prac_code,
    prac_name,
    region,
    COUNT(*) AS infect_total_bl
FROM adult_patients
GROUP BY
    prac_code,
    prac_name,
    region
ORDER BY
    prac_code,
    prac_name,
    region;
