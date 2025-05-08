-- loadUser.sql: Safely reload User dimension with CSV staging

USE AdCampaign;
GO

-- 1) Remove dependent facts so we can truncate User
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
GO

-- 2) Clear out User and reseed identity
DELETE FROM dbo.[User];
DBCC CHECKIDENT('dbo.[User]', RESEED, 0);
GO

-- 3) Insert staging users preserving UserID
SET IDENTITY_INSERT dbo.[User] ON;

INSERT INTO dbo.[User] (User_ID, Email, Age, Gender, Location)
SELECT
    UserID,
    Email,
    Age,
    Gender,
    Location
FROM dbo.Stg_Users;

SET IDENTITY_INSERT dbo.[User] OFF;
GO

-- 4) Verify
SELECT * FROM dbo.[User];
GO
