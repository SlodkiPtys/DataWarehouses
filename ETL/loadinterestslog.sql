-- loadInterestLog.sql: Load InterestLog fact by mapping each view/click event to user profile interests

USE AdCampaign;
GO

-- 1) Remove existing logs and reseed
DELETE FROM dbo.InterestLog;
DBCC CHECKIDENT('dbo.InterestLog', RESEED, 0);
GO

-- 2) Insert one row per (event, interest)
INSERT INTO dbo.InterestLog (ViewClick_ID, Interest_ID)
SELECT
    V.ViewClick_ID,
    I.Interest_ID
FROM dbo.Views_Clicks    AS V
JOIN dbo.Stg_Users       AS U
  ON V.User_ID = U.UserID
CROSS APPLY STRING_SPLIT(U.Interests, ';') AS s
JOIN dbo.Interests       AS I
  ON LTRIM(RTRIM(s.value)) = I.Interest_Name
WHERE s.value <> '';
GO

-- 3) Verify loaded logs
SELECT * FROM dbo.InterestLog;
GO
