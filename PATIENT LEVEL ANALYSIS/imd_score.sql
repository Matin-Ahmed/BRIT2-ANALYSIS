   --------------------
-- IMD_Score  
-- Baseline  
-- Patient IMD category (from IMD rank)
--------------------

WITH patient_imd AS (
    SELECT
        P.Patient_ID,
        P.infect,
        P.event_date,
        CASE
            WHEN A.IMD_Score BETWEEN 1 AND 6568 THEN 'very_unaffluent'
            WHEN A.IMD_Score BETWEEN 6569 AND 13137 THEN 'unaffluent'
            WHEN A.IMD_Score BETWEEN 13138 AND 19706 THEN 'medium'
            WHEN A.IMD_Score BETWEEN 19707 AND 26275 THEN 'affluent'
            WHEN A.IMD_Score BETWEEN 26276 AND 32844 THEN 'very_affluent'
            ELSE 'unknown'
        END AS IMD_Score
    FROM [BRIT].[PatientLevelData] P
    INNER JOIN [BRIT].[Patient] A
        ON A.PK_Patient_ID = P.Patient_ID
)
UPDATE [BRIT].[PatientLevelData]
SET IMD_Score = pi.IMD_Score
FROM [BRIT].[PatientLevelData]
INNER JOIN patient_imd pi
    ON pi.Patient_ID = [BRIT].[PatientLevelData].Patient_ID
   AND pi.infect = [BRIT].[PatientLevelData].infect
   AND pi.event_date = [BRIT].[PatientLevelData].event_date;
