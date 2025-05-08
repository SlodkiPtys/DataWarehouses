-- loadFacts.sql: Load Conduct_a_campaign and Views_Clicks facts

USE AdCampaign;
GO

-- 1) Usuñ stare fakty w zale¿noœci od kolejnoœci
DELETE FROM dbo.InterestLog;            -- ju¿ za³adowany powy¿ej, ale dla porz¹dku
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- 2) Zresetuj identity
DBCC CHECKIDENT('dbo.Views_Clicks',      RESEED, 0);
DBCC CHECKIDENT('dbo.Conduct_a_campaign',RESEED, 0);
GO

-- 3) Za³aduj Conduct_a_campaign
INSERT INTO dbo.Conduct_a_campaign
  (Campaign_ID, Medium_ID, OContract_ID, CContract_ID,
   StartDate_ID, EndDate_ID, Duration, Profit, Expense)
SELECT
  C.Campaign_ID,
  M.Medium_ID,
  O.Owner_ID      AS OContract_ID,
  CL.Client_ID    AS CContract_ID,
  SD.Date_ID      AS StartDate_ID,
  ED.Date_ID      AS EndDate_ID,
  DATEDIFF(DAY, A.[Start Date], A.[End Date]) AS Duration,
  OC.[Owner Revenue]                     AS Profit,
  CC.Expense                             AS Expense
FROM DataWarehouses.dbo.AdCampaign      AS A
JOIN DataWarehouses.dbo.OwnerContract   AS OC ON A.OContractID = OC.OContractID
JOIN dbo.Owner                          AS O  ON OC.OwnerID   = O.Owner_ID
JOIN DataWarehouses.dbo.ClientContract  AS CC ON A.CContractID = CC.CContractID
JOIN dbo.Client                         AS CL ON CC.ClientID  = CL.Client_ID
OUTER APPLY(
    SELECT TOP 1 V.MediumID
    FROM DataWarehouses.dbo.ViewsClicks AS V
    WHERE V.OContractID = A.OContractID
)                                         AS V
JOIN DataWarehouses.dbo.Medium          AS Msrc ON V.MediumID    = Msrc.MediumID
JOIN dbo.Medium                          AS M    ON Msrc.TypeOfMedium = M.Type_Of_Medium
                                           AND Msrc.[ad location] = M.Ad_Location
JOIN dbo.Campaign                        AS C    ON A.[Campaign Name] = C.Campaign_Name
JOIN dbo.Date                            AS SD   ON A.[Start Date]    = SD.[Date]
JOIN dbo.Date                            AS ED   ON A.[End Date]      = ED.[Date];
GO

-- 4) Za³aduj Views_Clicks
INSERT INTO dbo.Views_Clicks
  (Campaign_ID, View_Click, Click_Profit, User_ID,
   Time_ID, Date_ID, OContract_ID, CContract_ID)
SELECT
  C.Campaign_ID,
  CASE WHEN V.[Views/Clicks] = 1 THEN 1 ELSE 0 END       AS View_Click,
  CASE WHEN V.[Views/Clicks] = 1 THEN CC.[Click Profit] ELSE 0 END AS Click_Profit,
  U.User_ID                                            AS User_ID,
  T.Time_ID                                            AS Time_ID,
  D.Date_ID                                            AS Date_ID,
  O.Owner_ID                                           AS OContract_ID,
  CL.Client_ID                                         AS CContract_ID
FROM DataWarehouses.dbo.ViewsClicks    AS V
JOIN DataWarehouses.dbo.OwnerContract AS OC ON V.OContractID = OC.OContractID
JOIN dbo.Owner                        AS O  ON OC.OwnerID   = O.Owner_ID
JOIN DataWarehouses.dbo.AdCampaign    AS A  ON V.OContractID = A.OContractID
   AND CAST(V.[Timestamp] AS DATE) BETWEEN A.[Start Date] AND A.[End Date]
JOIN dbo.Campaign                      AS C  ON A.[Campaign Name] = C.Campaign_Name
JOIN DataWarehouses.dbo.ClientContract AS CC ON A.CContractID = CC.CContractID
JOIN dbo.Client                        AS CL ON CC.ClientID  = CL.Client_ID
JOIN dbo.[User]                        AS U  ON V.UserID     = U.User_ID
JOIN dbo.Time                          AS T  ON DATEPART(HOUR, V.[Timestamp]) = T.[Hour]
JOIN dbo.Date                          AS D  ON CAST(V.[Timestamp] AS DATE)    = D.[Date];
GO