--------------------
-- UTI infection events
--------------------

;WITH uti_events AS (
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
            '68226007','38822007','275412000','267204006','199107005',
            '199106001','199108000','199109008','199110003','197926005',
            '197853008','197927001','314940005','68566005','74741000006107',
            '368991000119100','301011002','1','369001000119100',
            '369011000119102','307534009','609491002','199111004','61373006'
        )
)
INSERT INTO [BRIT].[PatientLevelData] (Patient_ID, infect, event_date, Region)
SELECT
    Patient_ID,
    'uti' AS infect,
    event_date,
    Region
FROM uti_events;
