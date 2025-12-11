----------------------------
-- ircomp_bl
-- Baseline
-- Number of infection related complications within 30 days of a common infection consultation for adult patients during baseline.
----------------------------

WITH ci_events AS (
  SELECT
    A.PK_Patient_ID,
    pl.PK_Patient_Link_ID,
    B.OrganisationCode AS prac_code,
    B.Name AS prac_name,
    B.Region AS region,
    med_ci.EventDate AS consult_date,
    DATEDIFF(YEAR, A.dob, '2024-05-01')
      - CASE 
          WHEN MONTH(A.dob) > 5 OR (MONTH(A.dob) = 5 AND DAY(A.dob) > 1) THEN 1
          ELSE 0
        END AS age
  FROM BRIT.Patient A
    INNER JOIN BRIT.Reference_GP_Practice B
      ON B.PK_Reference_GP_Practice_ID = A.FK_Reference_GP_Practice_ID
    INNER JOIN BRIT.patient_link pl
      ON A.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.GP_Events med_ci
      ON med_ci.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.Reference_SnomedCT snomed_ci
      ON snomed_ci.PK_Reference_SnomedCT_ID = med_ci.FK_Reference_SnomedCT_ID
  WHERE
    med_ci.EventDate BETWEEN '2023-02-01' AND '2024-02-01'
    AND snomed_ci.ConceptID IN (
      '161929000','28743005','272039006','49727002','961781000006103',
      '135883003','11833005','284523002','161923004','161924005','161925006',
      '27836007','232212002','54272002','56663002','267665002','30250000',
      '45855004','232214001','402699002','76583009','403432008','403433003',
      '232224009','45431004','95812002','194202008','194204009','33934002',
      '194203003','402697000','86981007','111856000','21954000','3135009',
      '575931000000108','34129005','67832005','91038008','68272006',
      '431231008','15805002','77919000','35923002','73237007','60130002',
      '88850006','40055000','897657000','78737005','88348008','195790000',
      '195788001','36971009','68226007','38822007','275412000','267204006',
      '199107005','199106001','199108000','199109008','199110003','197926005',
      '197853008','197927001','314940005','68566005','74741000006107',
      '368991000119100','301011002','1','369001000119100','369011000119102',
      '307534009','609491002','199111004','61373006','194290005',
      '7271000119107','194288009','52353000','1088061000119105',
      '1090681000119105','359609001','194240006','270490007','194289001',
      '77478005','194281003','14948001','86279000','194282005','49252004',
      '194286008','267756004','29350000','129127001','270491006','78868004',
      '275481002','194237006','164236006','65363002','81564005','13420004',
      '39288006','194287004','80327007','195658003','195671000','195669000',
      '195666007','195667003','399050001','363746003','195656004','195673002',
      '17741008','195657008','195668008','195803003','41188003','162388002',
      '195804009','164256007','162397003','15033003','405737000','195677001',
      '267102003','538331000000101','43878008','85769006','186357007',
      '41582007','90176007','300932000','186963008','232427004','173599005',
      '232417005','195662009'
    )
),

comp_events AS (
  SELECT
    pl.PK_Patient_Link_ID,
    med.EventDate AS comp_date,
    B.OrganisationCode AS prac_code,
    B.Name AS prac_name,
    B.Region AS region,
    BRIT.Reference_SnomedCT.PK_Reference_SnomedCT_ID,
    BRIT.Reference_SnomedCT.ConceptID
  FROM BRIT.Patient A
    INNER JOIN BRIT.Reference_GP_Practice B
      ON B.PK_Reference_GP_Practice_ID = A.FK_Reference_GP_Practice_ID
    INNER JOIN BRIT.patient_link pl
      ON A.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.GP_Events med
      ON med.FK_Patient_Link_ID = pl.PK_Patient_Link_ID
    INNER JOIN BRIT.Reference_SnomedCT
      ON BRIT.Reference_SnomedCT.PK_Reference_SnomedCT_ID = med.FK_Reference_SnomedCT_ID
  WHERE
    med.EventDate BETWEEN '2023-02-01' AND '2024-02-01'
    AND BRIT.Reference_SnomedCT.ConceptID IN (
      '60404007','721104000','447843005','448813005','58554001','72102005',
      '192744002','79897009','80640009','386034005','392233007','2858002',
      '449082003','91302008','396234004','3321001','95883001','129128006',
      '371093006','15033003','192741005','164255006','10321002','186327003',
      '186365005','23511006','449504009','448419003','192643004','192644005',
      '192743008','27614006','111538005','52404001','271503005','196067009',
      '128477000','36689008','45816000','27174002','18071005','609485004',
      '40125005','276678006','66696003','240444009','447894003','23754003',
      '312682007','314130008','335846001','28085001','448418006','4089001',
      '372939007','449083008','30437004','447899008','32801008','33631007',
      '271504004','313437008','441806004','4510004','48245008','51169003',
      '568411000000108','601541000000108'
    )
),

linked_complications AS (
  SELECT DISTINCT
    ci.prac_code,
    ci.prac_name,
    ci.region,
    comp.PK_Patient_Link_ID,
    comp.comp_date,
    comp.PK_Reference_SnomedCT_ID
  FROM ci_events ci
    INNER JOIN comp_events comp
      ON comp.PK_Patient_Link_ID = ci.PK_Patient_Link_ID
     AND comp.comp_date > ci.consult_date
     AND comp.comp_date <= DATEADD(day, 30, ci.consult_date)
  WHERE
    ci.age >= 18
)

INSERT INTO PerPracticeData(prac_code, prac_name, region, ircomp_bl)
SELECT
  prac_code,
  prac_name,
  region,
  COUNT(*) AS ircomp_bl
FROM linked_complications
GROUP BY prac_code, prac_name, region
ORDER BY prac_code, prac_name, region;
