------------------------------------------------------------
-- Apply 14 day rule
-- Per Patient_ID + infect: keep first event, then drop events
-- occurring within 14 days (<=14) of the previous event.
------------------------------------------------------------

WITH ordered AS (
    SELECT
        Patient_ID,
        infect,
        event_date,
        LAG(event_date) OVER (
            PARTITION BY Patient_ID, infect
            ORDER BY event_date
        ) AS prev_event_date
    FROM [BRIT].[PatientLevelData]
),
to_remove AS (
    SELECT Patient_ID, infect, event_date
    FROM ordered
    WHERE prev_event_date IS NOT NULL
      AND DATEDIFF(DAY, prev_event_date, event_date) <= 14
)
DELETE P
FROM [BRIT].[PatientLevelData] P
INNER JOIN to_remove r
    ON r.Patient_ID = P.Patient_ID
   AND r.infect     = P.infect
   AND r.event_date = P.event_date;
