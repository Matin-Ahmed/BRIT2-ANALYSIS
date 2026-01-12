--------------------
-- Age_Cat
-- At consultation
-- Age category (Ali-style)
--------------------

UPDATE PLD
SET PLD.Age_Cat =
    CASE
        WHEN PLD.Age BETWEEN 18 AND 24 THEN '18-24'
        WHEN PLD.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN PLD.Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN PLD.Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN PLD.Age BETWEEN 55 AND 64 THEN '55-64'
        WHEN PLD.Age BETWEEN 65 AND 74 THEN '65-74'
        WHEN PLD.Age >= 75 THEN '75+'
        ELSE NULL
    END
FROM [BRIT].[PatientLevelData] PLD;
