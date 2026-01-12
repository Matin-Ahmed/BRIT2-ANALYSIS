------------------------------------------------------------
-- Cough infection events
------------------------------------------------------------
;WITH cough_events AS (
    SELECT
        A.PK_Patient_ID             AS Patient_ID,
        CAST(med.EventDate AS DATE) AS event_date,
        B.Region                    AS Region
    FROM [BRIT].[Patient] A
    INNER JOIN [BRIT].[Reference_GP_Practice] B
        ON B.PK_Reference_GP_Practice_ID = A.FK_Reference_GP_Practice_ID
    INNER JOIN [BRIT].[patient_link] pl
        ON A.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.GP_Events med
        ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.Reference_SnomedCT snomed
        ON snomed.PK_Reference_SnomedCT_ID = med.FK_Reference_SnomedCT_ID
    WHERE
        med.EventDate BETWEEN '2024-05-01' AND '2025-05-01'
        AND snomed.ConceptID IN (
            '161929000','28743005','272039006','49727002',
            '961781000006103','135883003','11833005',
            '284523002','161923004','161924005',
            '161925006','27836007'
        )
)
INSERT INTO [BRIT].[PatientLevelData] (Patient_ID, infect, event_date, Region)
SELECT Patient_ID, 'cough', event_date, Region
FROM cough_events;
