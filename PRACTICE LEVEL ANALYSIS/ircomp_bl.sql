------------
-- ircomp_bl  
-- Baseline 
-- Number of infection-related complications within 30 days of consultation for adult patients during baseline year. Use the consultation 
-- date as the index date from 1st Feb 2023 to identify correct records.  
------------

WITH patient_ages AS (
  SELECT
    PK_Patient_ID,
    med.FK_Patient_Link_ID,
    snomed.PK_Reference_SnomedCT_ID,
    B.OrganisationCode AS prac_code,
    B.Name AS prac_name,
    Region AS region,
    DATEDIFF(YEAR, dob, '2024-05-01') 
      - CASE 
          WHEN MONTH(dob) > 5 OR (MONTH(dob) = 5 AND DAY(dob) > 1) THEN 1 
          ELSE 0 
        END AS age
  FROM 
      [BRIT].[Patient] A 
      INNER JOIN [BRIT].[Reference_GP_Practice] B 
      ON B.PK_Reference_GP_Practice_ID=A.FK_Reference_GP_Practice_ID 
      INNER JOIN [BRIT].[patient_link] pl 
      ON A.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
      INNER JOIN BRIT.GP_Events med  
      ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
      INNER JOIN BRIT.Reference_SnomedCT snomed
      ON snomed.PK_Reference_SnomedCT_ID = med.FK_Reference_SnomedCT_ID
      INNER JOIN BRIT.GP_Appointments appoint
      ON appoint.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
  WHERE
    med.EventDate BETWEEN CAST('2023-02-01 00:00:00' AS DATETIME) and CAST('2024-02-01 00:00:00' AS DATETIME) 
    AND med.EventDate BETWEEN appoint.AppointmentDate AND DATEADD(day, 30, appoint.AppointmentDate)
    AND snomed.ConceptID IN
(
  '60404007',
  '721104000',
  '447843005',
  '448813005',
  '58554001',
  '72102005',
  '192744002',
  '79897009',
  '80640009',
  '386034005',
  '392233007',
  '2858002',
  '449082003',
  '91302008',
  '396234004',
  '3321001',
  '95883001',
  '129128006',
  '371093006',
  '15033003',
  '192741005',
  '164255006',
  '10321002',
  '186327003',
  '186365005',
  '23511006',
  '449504009',
  '448419003',
  '192643004',
  '192644005',
  '192743008',
  '27614006',
  '111538005',
  '52404001',
  '271503005',
  '196067009',
  '128477000',
  '36689008',
  '45816000',
  '27174002',
  '18071005',
  '609485004',
  '40125005',
  '276678006',
  '66696003',
  '240444009',
  '447894003',
  '23754003',
  '312682007',
  '314130008',
  '335846001',
  '28085001',
  '448418006',
  '4089001',
  '372939007',
  '449083008',
  '30437004',
  '447899008',
  '32801008',
  '33631007',
  '271504004',
  '313437008',
  '441806004',
  '4510004',
  '48245008',
  '51169003',
  '568411000000108',
  '601541000000108'
)

),
adult_patients AS (
  SELECT *
  FROM patient_ages
  WHERE age >= 18
)
INSERT INTO PerPracticeData(prac_code,prac_name,region,ircomp_bl)
  SELECT
    prac_code,
    prac_name,
    region,
    COUNT(DISTINCT FK_Patient_Link_ID) AS ircomp_bl
  FROM adult_patients
  GROUP BY prac_code,prac_name,region
  ORDER BY prac_code,prac_name,region
;
