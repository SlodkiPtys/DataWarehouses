-- LoadConduct_a_campaign.sql
USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/*
  1. Z Database1 (DataWarehouses) bierzemy:
     - AdCampaign: CampaignID, OContractID, CContractID, [Start Date], [End Date]
     - ViewsClicks: ViewClickID, MediumID, OContractID
     - OwnerContract: OContractID, OwnerID
     - ClientContract: CContractID, ClientID, [Click Profit], Expense

  2. Łączymy je w jednym CTE, żeby wyciągnąć per Campaign najnowsze MediumID,
     oraz powiązane OContractID i CContractID.

  3. W drugim CTE mapujemy te surowe klucze na surrogate keys z targetowych dim:
     Campaign, Medium, Owner, Client, Date.

  4. Robimy MERGE do dbo.Conduct_a_campaign.
*/

;WITH Chain AS (
    SELECT
      ac.CampaignID,
      ac.OContractID,
      ac.CContractID,
      ac.[Start Date],
      ac.[End Date],
      vc.MediumID,
      ROW_NUMBER() OVER(
        PARTITION BY ac.CampaignID
        ORDER BY vc.ViewClickID DESC
      ) AS rn
    FROM DataWarehouses.dbo.AdCampaign AS ac
    JOIN DataWarehouses.dbo.ViewsClicks AS vc
      ON vc.OContractID = ac.OContractID      -- łączymy po OContractID
    JOIN DataWarehouses.dbo.OwnerContract AS oc
      ON oc.OContractID = ac.OContractID      -- żeby mieć OwnerID jeśli potrzebne
    JOIN DataWarehouses.dbo.ClientContract AS cc
      ON cc.CContractID = ac.CContractID      -- żeby mieć profit/expense
),
Enriched AS (
    SELECT
      ch.CampaignID,
      camp_dim.Campaign_ID      AS Campaign_ID,
      m_dim.Medium_ID           AS Medium_ID,
      o_dim.Owner_ID            AS OContract_ID,
      cl_dim.Client_ID          AS CContract_ID,
      ch.[Start Date]           AS Start_Date,
      ch.[End Date]             AS End_Date,
      DATEDIFF(DAY, ch.[Start Date], ch.[End Date]) AS Duration,
      cc.[Click Profit]         AS Profit,
      cc.Expense                AS Expense
    FROM Chain AS ch
      -- tylko najnowszy MediumID
    JOIN (
      SELECT * FROM Chain WHERE rn = 1
    ) AS latest ON latest.CampaignID = ch.CampaignID AND latest.rn = 1

    -- mapowanie Campaign → dim.Campaign
    JOIN dbo.Campaign AS camp_dim
      ON camp_dim.Campaign_Name = (
           SELECT [Campaign Name]
           FROM DataWarehouses.dbo.AdCampaign
           WHERE CampaignID = ch.CampaignID
         )

    -- direct numeric MediumID → dim.Medium
    LEFT JOIN dbo.Medium AS m_dim
      ON m_dim.Medium_ID = ch.MediumID

    -- OwnerContract → Owner → dim.Owner (po NIP)
    JOIN DataWarehouses.dbo.OwnerContract AS oc
      ON oc.OContractID = ch.OContractID
    JOIN DataWarehouses.dbo.Owner         AS o_src
      ON o_src.OwnerID = oc.OwnerID
    JOIN dbo.Owner                        AS o_dim
      ON o_dim.NIP = CAST(o_src.NIP AS VARCHAR(32))

    -- ClientContract → Client → dim.Client (po NIP)
    JOIN DataWarehouses.dbo.ClientContract AS cc
      ON cc.CContractID = ch.CContractID
    JOIN DataWarehouses.dbo.Client         AS c_src
      ON c_src.ClientID = cc.ClientID
    JOIN dbo.Client                        AS cl_dim
      ON cl_dim.NIP = CAST(c_src.NIP AS VARCHAR(32))
)
MERGE dbo.Conduct_a_campaign AS tgt
USING (
    SELECT
      e.Campaign_ID,
      e.Medium_ID,
      e.OContract_ID,
      e.CContract_ID,
      ds.Date_ID   AS StartDate_ID,
      de.Date_ID   AS EndDate_ID,
      e.Duration,
      e.Profit,
      e.Expense
    FROM Enriched AS e
    JOIN dbo.[Date] AS ds
      ON ds.[Date] = e.Start_Date
    JOIN dbo.[Date] AS de
      ON de.[Date] = e.End_Date
) AS src
ON  tgt.Campaign_ID   = src.Campaign_ID
AND tgt.OContract_ID  = src.OContract_ID
AND tgt.CContract_ID  = src.CContract_ID

WHEN NOT MATCHED BY TARGET THEN
  INSERT (
    Campaign_ID, Medium_ID, OContract_ID, CContract_ID,
    StartDate_ID, EndDate_ID, Duration, Profit, Expense
  )
  VALUES (
    src.Campaign_ID, src.Medium_ID, src.OContract_ID, src.CContract_ID,
    src.StartDate_ID, src.EndDate_ID, src.Duration, src.Profit, src.Expense
  )

WHEN MATCHED AND (
      ISNULL(tgt.Profit,0)   <> ISNULL(src.Profit,0)   OR
      ISNULL(tgt.Expense,0)  <> ISNULL(src.Expense,0)
) THEN
  UPDATE SET
    Profit  = src.Profit,
    Expense = src.Expense
;
GO

-- Sprawdzenie
SELECT * FROM dbo.Conduct_a_campaign;
