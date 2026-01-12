------------------------------------------------------------
-- Otitis media infection events
------------------------------------------------------------
;WITH otmedia_events AS (
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
            '194290005','7271000119107','194288009','52353000',
            '1088061000119105','1090681000119105','359609001',
            '194240006','270490007','194289001','77478005',
            '194281003','14948001','86279000','194282005',
            '49252004','194286008','267756004','29350000',
            '129127001','270491006','78868004','275481002',
            '194237006','164236006','65363002','81564005',
            '13420004','39288006','194287004','80327007'
        )
)
INSERT INTO [BRIT].[PatientLevelData] (Patient_ID, infect, event_date, Region)
SELECT Patient_ID, 'otMedia', event_date, Region
FROM otmedia_events;
