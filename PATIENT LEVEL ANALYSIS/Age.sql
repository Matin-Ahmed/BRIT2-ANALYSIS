--------------------
-- Age  
-- At consultation  
-- Age (years) of patient at infection consultation date
--------------------

WITH patient_ages AS (
    SELECT
        P.Patient_ID,
        P.event_date,
        DATEDIFF(YEAR, A.dob, P.event_date)
          - CASE
              WHEN MONTH(A.dob) > MONTH(P.event_date)
                OR (MONTH(A.dob) = MONTH(P.event_date)
                    AND DAY(A.dob) > DAY(P.event_date))
              THEN 1
              ELSE 0
            END AS Age
    FROM [BRIT].[PatientLevelData] P
    INNER JOIN [BRIT].[Patient] A
        ON A.PK_Patient_ID = P.Patient_ID
)
UPDATE PLD
SET PLD.Age = pa.Age
FROM [BRIT].[PatientLevelData] PLD
INNER JOIN patient_ages pa
    ON pa.Patient_ID = PLD.Patient_ID
   AND pa.event_date = PLD.event_date;
