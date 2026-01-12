------------------------------------------------------------
-- BMI_Cat
-- Derived from BMI_Score
-- Clinical BMI categories
------------------------------------------------------------

UPDATE PLD
SET PLD.BMI_Cat =
    CASE
        WHEN PLD.BMI_Score IS NULL THEN 'Unknown'
        WHEN PLD.BMI_Score < 18.5 THEN 'Underweight'
        WHEN PLD.BMI_Score < 25.0 THEN 'Healthy weight'
        WHEN PLD.BMI_Score < 30.0 THEN 'Overweight'
        WHEN PLD.BMI_Score < 40.0 THEN 'Obese'
        ELSE 'Severely obese'
    END
FROM [BRIT].[PatientLevelData] PLD;
