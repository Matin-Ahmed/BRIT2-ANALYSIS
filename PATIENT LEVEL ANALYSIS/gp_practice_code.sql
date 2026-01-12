--------------------
-- GP Practice Code  
-- Baseline  
-- Registered GP practice code at time of extract
--------------------

;WITH patient_gp_practice AS (
    SELECT
        P.Patient_ID,
        P.infect,
        P.event_date,
        A.GPPracticeCode AS GP_Practice_Code
    FROM [BRIT].[PatientLevelData] P
    INNER JOIN [BRIT].[Patient] A
        ON A.PK_Patient_ID = P.Patient_ID
)
UPDATE PLD
SET PLD.GP_Practice_Code = pgp.GP_Practice_Code
FROM [BRIT].[PatientLevelData] PLD
INNER JOIN patient_gp_practice pgp
    ON pgp.Patient_ID = PLD.Patient_ID
   AND pgp.infect     = PLD.infect
   AND pgp.event_date = PLD.event_date;
