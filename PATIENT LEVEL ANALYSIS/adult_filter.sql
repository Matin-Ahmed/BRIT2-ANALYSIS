--------------------
-- Adult filter  
-- At consultation  
-- Keep patients aged 18+ at event date
--------------------

WITH underage_events AS (
    SELECT
        Patient_ID,
        infect,
        event_date
    FROM [BRIT].[PatientLevelData]
    WHERE Age < 18
       OR Age IS NULL
)
DELETE PLD
FROM [BRIT].[PatientLevelData] PLD
INNER JOIN underage_events u
    ON u.Patient_ID = PLD.Patient_ID
   AND u.infect = PLD.infect
   AND u.event_date = PLD.event_date;

WITH event_seasons AS (
    SELECT
        Patient_ID,
        infect,
        event_date,
        CASE
            -- Autumn 2024: 22 Sep 2024 to 20 Dec 2024
            WHEN event_date BETWEEN CAST('2024-09-22' AS DATE)
                                 AND CAST('2024-12-20' AS DATE)
            THEN 'autumn'

            -- Winter 2024/25: 21 Dec 2024 to 19 Mar 2025
            WHEN event_date BETWEEN CAST('2024-12-21' AS DATE)
                                 AND CAST('2025-03-19' AS DATE)
            THEN 'winter'

            -- Spring 2024 + Spring 2025
            WHEN event_date BETWEEN CAST('2024-05-01' AS DATE)
                                 AND CAST('2024-06-19' AS DATE)
              OR event_date BETWEEN CAST('2025-03-20' AS DATE)
                                 AND CAST('2025-04-30' AS DATE)
            THEN 'spring'

            -- Summer 2024: 20 Jun 2024 to 21 Sep 2024
            WHEN event_date BETWEEN CAST('2024-06-20' AS DATE)
                                 AND CAST('2024-09-21' AS DATE)
            THEN 'summer'
        END AS Season
    FROM [BRIT].[PatientLevelData]
)
UPDATE PLD
SET PLD.Season = es.Season
FROM [BRIT].[PatientLevelData] PLD
INNER JOIN event_seasons es
    ON es.Patient_ID = PLD.Patient_ID
   AND es.infect = PLD.infect
   AND es.event_date = PLD.event_date;
