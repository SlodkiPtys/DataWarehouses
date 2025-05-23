USE AdCampaign2DB;
GO

-- Step 1: Clear existing fact records
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- Step 2: Reseed identities
DBCC CHECKIDENT('dbo.Views_Clicks', RESEED, 0);
DBCC CHECKIDENT('dbo.Conduct_a_campaign', RESEED, 0);
GO

-- Step 3: Create staging view for Conduct_a_campaign
IF OBJECT_ID('vETLConductCampaign', 'V') IS NOT NULL DROP VIEW vETLConductCampaign;
GO

CREATE VIEW vETLConductCampaign AS
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
JOIN DataWarehouses.dbo.OwnerContract   AS OC       ON A.OContractID = OC.OContractID
JOIN DataWarehouses.dbo.Owner           AS DW_Owner ON OC.OwnerID = DW_Owner.OwnerID
JOIN dbo.Owner                          AS O        ON DW_Owner.NIP = O.NIP
JOIN DataWarehouses.dbo.ClientContract   AS CC       ON A.CContractID = CC.CContractID
JOIN DataWarehouses.dbo.Client           AS DW_Client ON CC.ClientID  = DW_Client.ClientID
JOIN dbo.Client                          AS CL       ON DW_Client.NIP = CL.NIP
OUTER APPLY (
    SELECT TOP 1 V.MediumID
    FROM DataWarehouses.dbo.ViewsClicks AS V
    WHERE V.OContractID = A.OContractID
)                                       AS V
JOIN DataWarehouses.dbo.Medium          AS Msrc     ON V.MediumID = Msrc.MediumID
JOIN dbo.Medium                         AS M        ON Msrc.TypeOfMedium = M.Type_Of_Medium
                                                AND Msrc.[ad location] = M.Ad_Location
JOIN dbo.Campaign                       AS C        ON A.[Campaign Name] = C.Campaign_Name
JOIN dbo.Date                           AS SD       ON A.[Start Date]    = SD.[Date]
JOIN dbo.Date                           AS ED       ON A.[End Date]      = ED.[Date];
GO

-- Step 4: Load Conduct_a_campaign from view
INSERT INTO dbo.Conduct_a_campaign (
  Campaign_ID, Medium_ID, OContract_ID, CContract_ID,
  StartDate_ID, EndDate_ID, Duration, Profit, Expense)
SELECT *
FROM vETLConductCampaign;
GO

DROP VIEW vETLConductCampaign;
GO

-- Step 5: Create staging view for Views_Clicks
IF OBJECT_ID('vETLViewsClicks', 'V') IS NOT NULL DROP VIEW vETLViewsClicks;
GO

CREATE VIEW vETLViewsClicks AS
SELECT
  C.Campaign_ID,
  CASE WHEN V.[Views/Clicks] = 1 THEN 1 ELSE 0 END AS View_Click,
  CASE WHEN V.[Views/Clicks] = 1 THEN CC.[Click Profit] ELSE 0 END AS Click_Profit,
  U.User_Key,
  T.Time_ID,
  D.Date_ID,
  O.Owner_ID,
  CL.Client_ID
FROM DataWarehouses.dbo.ViewsClicks       AS V
JOIN DataWarehouses.dbo.OwnerContract     AS OC        ON V.OContractID = OC.OContractID
JOIN DataWarehouses.dbo.Owner             AS DW_Owner  ON OC.OwnerID    = DW_Owner.OwnerID
JOIN dbo.Owner                            AS O         ON DW_Owner.NIP  = O.NIP

JOIN DataWarehouses.dbo.AdCampaign        AS A         ON V.OContractID = A.OContractID
   AND CAST(V.[Timestamp] AS DATE) BETWEEN A.[Start Date] AND A.[End Date]
JOIN dbo.Campaign                         AS C         ON A.[Campaign Name] = C.Campaign_Name

JOIN DataWarehouses.dbo.ClientContract    AS CC        ON A.CContractID = CC.CContractID
JOIN DataWarehouses.dbo.Client            AS DW_Client ON CC.ClientID   = DW_Client.ClientID
JOIN dbo.Client                           AS CL        ON DW_Client.NIP = CL.NIP

JOIN dbo.[User]                           AS U         ON V.User_Key    = U.User_Key AND U.IsCurrent = 1
JOIN dbo.Time                             AS T         ON DATEPART(HOUR, V.[Timestamp]) = T.[Hour]
JOIN dbo.Date                             AS D         ON CAST(V.[Timestamp] AS DATE) = D.[Date];
GO

-- Step 6: Load Views_Clicks from view
INSERT INTO dbo.Views_Clicks (
  Campaign_ID, View_Click, Click_Profit, User_Key,
  Time_ID, Date_ID, OContract_ID, CContract_ID)
SELECT *
FROM vETLViewsClicks;
GO

DROP VIEW vETLViewsClicks;
GO

-- Step 7: Optional final check
SELECT * FROM dbo.Conduct_a_campaign;
SELECT * FROM dbo.Views_Clicks;
GO
