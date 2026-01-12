--------------------
-- BMI_Score  
-- Most recent record prior to event_date
--------------------

WITH bmi_events AS (
    SELECT
        P.Patient_ID,
        P.infect,
        P.event_date,

        med.EventDate AS bmi_event_date,

        TRY_CONVERT(
            FLOAT,
            TRY_CONVERT(NVARCHAR(MAX), med.Value)
        ) AS BMI
    FROM [BRIT].[PatientLevelData] P
    INNER JOIN [BRIT].[patient_link] pl
        ON P.Patient_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.GP_Events med
        ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.Reference_SnomedCT snomed
        ON snomed.PK_Reference_SnomedCT_ID = med.FK_Reference_SnomedCT_ID
    WHERE
        snomed.ConceptID IN (
            '60621009',
            '140075008',
            '162859006',
            '363807006'
        )
        AND med.EventDate <= P.event_date
),
valid_bmi AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Patient_ID, infect, event_date
               ORDER BY bmi_event_date DESC
           ) AS rn
    FROM bmi_events
    WHERE BMI BETWEEN 10 AND 70
)
UPDATE [BRIT].[PatientLevelData]
SET BMI_Score = vb.BMI
FROM [BRIT].[PatientLevelData]
INNER JOIN valid_bmi vb
    ON vb.Patient_ID = [BRIT].[PatientLevelData].Patient_ID
   AND vb.infect = [BRIT].[PatientLevelData].infect
   AND vb.event_date = [BRIT].[PatientLevelData].event_date
WHERE vb.rn = 1;
