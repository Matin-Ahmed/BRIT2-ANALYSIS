
------------------------------------------------------------
-- Sore throat infection events
------------------------------------------------------------
;WITH throat_events AS (
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
            '195658003','195671000','195669000','195666007','195667003',
            '399050001','363746003','195656004','195673002','17741008',
            '195657008','195668008','195803003','41188003','162388002',
            '195804009','164256007','162397003','15033003','405737000',
            '195677001','267102003','538331000000101','43878008','85769006',
            '186357007','41582007','90176007','300932000','186963008',
            '232427004','173599005','232417005','195662009'
        )
)
INSERT INTO [BRIT].[PatientLevelData] (Patient_ID, infect, event_date, Region)
SELECT Patient_ID, 'throat', event_date, Region
FROM throat_events;
