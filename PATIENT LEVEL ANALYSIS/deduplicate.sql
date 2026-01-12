------------------------------------------------------------
-- DEDUPLICATE: one row per patient × infection × day
------------------------------------------------------------
WITH duplicate_events AS (
    SELECT
        Patient_ID,
        infect,
        event_date,
        ROW_NUMBER() OVER (
            PARTITION BY Patient_ID, infect, event_date
            ORDER BY Patient_ID
        ) AS rn
    FROM [BRIT].[PatientLevelData]
)
DELETE P
FROM [BRIT].[PatientLevelData] P
INNER JOIN duplicate_events d
    ON d.Patient_ID = P.Patient_ID
   AND d.infect = P.infect
   AND d.event_date = P.event_date
WHERE d.rn > 1;
