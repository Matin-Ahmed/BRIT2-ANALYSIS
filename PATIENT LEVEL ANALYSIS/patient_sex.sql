--------------------
-- Sex  
-- Baseline  
-- Patient sex (male / female / unknown)
--------------------

;WITH patient_sex AS (
    SELECT
        P.Patient_ID,
        P.infect,
        P.event_date,
        CASE
            WHEN A.Sex = 'M' THEN 'male'
            WHEN A.Sex = 'F' THEN 'female'
            ELSE 'unknown'
        END AS Sex
    FROM [BRIT].[PatientLevelData] P
    INNER JOIN [BRIT].[Patient] A
        ON A.PK_Patient_ID = P.Patient_ID
)
UPDATE PLD
SET PLD.Sex = ps.Sex
FROM [BRIT].[PatientLevelData] PLD
INNER JOIN patient_sex ps
    ON ps.Patient_ID = PLD.Patient_ID
   AND ps.infect     = PLD.infect
   AND ps.event_date = PLD.event_date;
