-- loadInterests.sql: Load Interests dimension directly from Stg_Users

USE AdCampaign;
GO

-- 1) Remove dependent InterestLog fact rows
DELETE FROM dbo.InterestLog;
GO

-- 2) Clear and reseed Interests dimension
DELETE FROM dbo.Interests;
DBCC CHECKIDENT('dbo.Interests', RESEED, 0);
GO

-- 3) Insert distinct interests by splitting the CSV‐derived list
INSERT INTO dbo.Interests (Interest_Name)
SELECT DISTINCT 
    LTRIM(RTRIM(value)) AS InterestName
FROM dbo.Stg_Users
CROSS APPLY STRING_SPLIT(Interests, ';')
WHERE value <> '';
GO

-- 4) Verify loaded interests
SELECT * FROM dbo.Interests;
GO
