USE AdCampaign2DB;
GO

-- 1) Usuń tymczasową tabelę, jeśli istnieje
IF OBJECT_ID('tempdb..#VC_Staging','U') IS NOT NULL
    DROP TABLE #VC_Staging;

-- 2) Przygotuj dane w stagingu: wybierz tylko najnowszy rekord na ViewClickID
;WITH LatestViewClicks AS (
    SELECT
        vc.ViewClickID AS ViewClickID,                               -- źródłowy ID
        CAST(vc.[Views/Clicks] AS TINYINT) AS View_Click,            -- BIT -> TINYINT
        CASE WHEN vc.[Views/Clicks] = 1 
             THEN cc.[Click Profit] 
             ELSE 0 
        END AS Click_Profit,                                         -- wyliczone profit
        ac.[Campaign Name] AS Campaign_Name,                         -- nazwa kampanii
        o.NIP           AS Owner_NIP,                                -- NIP właściciela
        c.NIP           AS Client_NIP,                               -- NIP klienta
        su.[E-mail]     AS UserEmail,                                -- email użytkownika
        DATEPART(HOUR, vc.[Timestamp]) AS TimestampHour,             -- godzina
        CAST(vc.[Timestamp] AS date)     AS TimestampDate,           -- data
        ROW_NUMBER() OVER (
            PARTITION BY vc.ViewClickID 
            ORDER BY vc.[Timestamp] DESC
        ) AS rn                                                     -- kolejność wg daty
    FROM DataWarehouses.dbo.ViewsClicks AS vc
    JOIN DataWarehouses.dbo.AdCampaign      AS ac ON vc.OContractID = ac.OContractID
    JOIN DataWarehouses.dbo.ClientContract  AS cc ON ac.CContractID = cc.CContractID
    JOIN DataWarehouses.dbo.Client          AS c  ON cc.ClientID     = c.ClientID
    JOIN DataWarehouses.dbo.OwnerContract   AS oc ON vc.OContractID = oc.OContractID
    JOIN DataWarehouses.dbo.Owner          AS o   ON oc.OwnerID      = o.OwnerID
    JOIN Staging.Users                     AS su ON su.UserID       = vc.UserID
)
SELECT
    lvc.ViewClickID,
    dimC.Campaign_ID    AS Campaign_ID,
    lvc.View_Click,
    lvc.Click_Profit,
    dimU.User_ID        AS User_ID,
    dimT.Time_ID        AS Time_ID,
    dimD.Date_ID        AS Date_ID,
    dimO.Owner_ID       AS OContract_ID,
    dimCl.Client_ID     AS CContract_ID
INTO #VC_Staging
FROM LatestViewClicks AS lvc
INNER JOIN dbo.Campaign    AS dimC  ON dimC.Campaign_Name = lvc.Campaign_Name
INNER JOIN dbo.Owner       AS dimO  ON dimO.NIP           = CAST(lvc.Owner_NIP  AS VARCHAR(32))
INNER JOIN dbo.Client      AS dimCl ON dimCl.NIP          = CAST(lvc.Client_NIP AS VARCHAR(32))
INNER JOIN dbo.[User]      AS dimU  ON dimU.Email         = lvc.UserEmail
INNER JOIN dbo.[Time]      AS dimT  ON dimT.Hour          = lvc.TimestampHour
INNER JOIN dbo.[Date]      AS dimD  ON dimD.[Date]        = lvc.TimestampDate
WHERE lvc.rn = 1;  -- bierzemy tylko ostatni (rn=1) wpis dla każdego ViewClickID:contentReference[oaicite:4]{index=4}

GO

-- 3) Włącz możliwość wpisywania wartości do kolumny IDENTITY
SET IDENTITY_INSERT dbo.Views_Clicks ON;

-- 4) Połącz i wstaw/aktualizuj dane docelowe
MERGE dbo.Views_Clicks AS Target
USING #VC_Staging AS Src
    ON Target.ViewClick_ID = Src.ViewClickID
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ViewClick_ID, Campaign_ID, View_Click, Click_Profit, User_ID, Time_ID, Date_ID, OContract_ID, CContract_ID)
    VALUES (Src.ViewClickID, Src.Campaign_ID, Src.View_Click, Src.Click_Profit, Src.User_ID, Src.Time_ID, Src.Date_ID, Src.OContract_ID, Src.CContract_ID)
WHEN MATCHED AND 
    (Target.View_Click <> Src.View_Click 
     OR ISNULL(Target.Click_Profit,0) <> Src.Click_Profit) 
THEN
    UPDATE SET
        View_Click   = Src.View_Click,
        Click_Profit = Src.Click_Profit
-- (Można też aktualizować inne kolumny, jeśli to potrzebne)
;

SET IDENTITY_INSERT dbo.Views_Clicks OFF;  -- wyłączamy tryb wstawiania do IDENTITY

-- 5) Wynik (ostatnie 100 wierszy tabeli docelowej)
SELECT TOP(100) * 
FROM dbo.Views_Clicks
ORDER BY ViewClick_ID DESC;
GO
