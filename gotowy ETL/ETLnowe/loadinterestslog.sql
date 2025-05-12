USE AdCampaign2DB;
GO

-- Step 1: Clear the InterestLog fact table
DELETE FROM dbo.InterestLog;
DBCC CHECKIDENT('dbo.InterestLog', RESEED, 0);
GO

-- Step 2: Create a staging view that expands interests per user per event
IF OBJECT_ID('vETLFactInterestLog', 'V') IS NOT NULL
    DROP VIEW vETLFactInterestLog;
GO

CREATE VIEW vETLFactInterestLog AS
SELECT
    V.ViewClick_ID,
    I.Interest_ID
FROM dbo.Views_Clicks    AS V
JOIN dbo.Stg_Users       AS U
  ON V.User_Key = U.UserID
CROSS APPLY STRING_SPLIT(U.Interests, ';') AS s
JOIN dbo.Interests       AS I
  ON LTRIM(RTRIM(s.value)) = I.Interest_Name
WHERE s.value IS NOT NULL AND LTRIM(RTRIM(s.value)) <> '';
GO

-- Step 3: Insert data from staging view
INSERT INTO dbo.InterestLog (ViewClick_ID, Interest_ID)
SELECT 
    ViewClick_ID,
    Interest_ID
FROM vETLFactInterestLog;
GO

-- Step 4: Drop the staging view
DROP VIEW vETLFactInterestLog;
GO

-- Step 5: Verify
SELECT * FROM dbo.InterestLog ORDER BY ViewClick_ID, Interest_ID;
GO


