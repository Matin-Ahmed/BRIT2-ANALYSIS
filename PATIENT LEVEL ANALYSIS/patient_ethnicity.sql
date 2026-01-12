--------------------
-- Ethnicity  
-- Baseline  
-- Patient ethnicity group: white / non_white / unknown
--------------------

;WITH patient_ethnicity AS (
    SELECT
        P.Patient_ID,
        P.infect,
        P.event_date,
        EthnicMainGroup AS Ethnicity
    FROM [BRIT].[PatientLevelData] P
    INNER JOIN [BRIT].[patient_link] A
        ON A.PK_Patient_Link_ID = P.Patient_ID

)
UPDATE PLD
SET PLD.Ethnicity = pe.Ethnicity
FROM [BRIT].[PatientLevelData] PLD
INNER JOIN patient_ethnicity pe
    ON pe.Patient_ID = PLD.Patient_ID
   AND pe.infect     = PLD.infect
   AND pe.event_date = PLD.event_date;
