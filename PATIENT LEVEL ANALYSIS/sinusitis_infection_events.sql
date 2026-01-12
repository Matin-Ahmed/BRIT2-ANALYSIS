------------------------------------------------------------
-- Sinusitis infection events
------------------------------------------------------------
;WITH sinus_events AS (
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
            '67832005','91038008','68272006','431231008','15805002',
            '77919000','35923002','73237007','60130002','88850006',
            '40055000','897657000','78737005','88348008','195790000',
            '195788001','36971009'
        )
)
INSERT INTO [BRIT].[PatientLevelData] (Patient_ID, infect, event_date, Region)
SELECT Patient_ID, 'sinusitis', event_date, Region
FROM sinus_events;
