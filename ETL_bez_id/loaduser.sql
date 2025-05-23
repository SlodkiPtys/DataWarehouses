USE AdCampaign2DB;
GO

-- Drop foreign key constraints referencing dbo.[User]
DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql += 'ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name)
             + ' DROP CONSTRAINT ' + QUOTENAME(f.name) + ';' + CHAR(13)
FROM sys.foreign_keys f
JOIN sys.tables t ON f.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE f.referenced_object_id = OBJECT_ID('dbo.[User]');
EXEC sp_executesql @sql;
GO

-- Drop and create Staging table
IF OBJECT_ID('dbo.Stg_Users', 'U') IS NOT NULL DROP TABLE dbo.Stg_Users;
GO
CREATE TABLE dbo.Stg_Users (
    UserID     INT,
    Email      VARCHAR(255),
    Gender     VARCHAR(20),
    Location   VARCHAR(255),
    Interests  VARCHAR(500),
    BirthYear  INT,
    Age        INT
);
GO

-- Load T1 CSV
TRUNCATE TABLE dbo.Stg_Users;
GO
BULK INSERT dbo.Stg_Users
FROM 'C:\Users\Marta\user_ad_interactions_T1.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
GO

-- Drop and create main User dimension
IF OBJECT_ID('dbo.[User]', 'U') IS NOT NULL DROP TABLE dbo.[User];
GO
CREATE TABLE dbo.[User] (
    User_Key   INT IDENTITY(1,1) PRIMARY KEY,
    User_ID    INT NOT NULL,
    Email      VARCHAR(255),
    Age        VARCHAR(50),  -- stores AgeGroup label now
    Gender     VARCHAR(20),
    Location   VARCHAR(255),
    ValidFrom  DATETIME NOT NULL DEFAULT GETDATE(),
    ValidTo    DATETIME NULL,
    IsCurrent  BIT NOT NULL DEFAULT 1
);
GO

-- Create view for transforming staging data using Age only
IF OBJECT_ID('vETLDimUserData') IS NOT NULL DROP VIEW vETLDimUserData;
GO
CREATE VIEW vETLDimUserData AS
SELECT DISTINCT
    UserID,
    Email,
    CASE
        WHEN Age IS NULL THEN 'Unknown'
        WHEN Age < 18 THEN 'Teen'
        WHEN Age BETWEEN 18 AND 21 THEN 'Young Adult 18-21'
        WHEN Age BETWEEN 22 AND 34 THEN 'Adult 22-34'
        WHEN Age BETWEEN 35 AND 49 THEN 'Middle-Aged 35-49'
        WHEN Age BETWEEN 50 AND 64 THEN 'Senior 50-64'
        ELSE 'Senior 65+'
    END AS AgeGroup,
    Gender,
    Location
FROM dbo.Stg_Users;
GO

-- Initial load (no merge needed)
INSERT INTO dbo.[User] (User_ID, Email, Age, Gender, Location, ValidFrom, ValidTo, IsCurrent)
SELECT 
    UserID, Email, AgeGroup, Gender, Location,
    GETDATE(), NULL, 1
FROM vETLDimUserData;
GO

-- Drop view (optional cleanup)
DROP VIEW vETLDimUserData;
GO

SELECT *
FROM dbo.[User];
