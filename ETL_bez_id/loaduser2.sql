USE AdCampaign2DB;
GO

-- 1. Load T2 into staging
TRUNCATE TABLE dbo.Stg_Users;
GO

BULK INSERT dbo.Stg_Users
FROM 'C:\Users\Marta\user_ad_interactions_T2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',', 
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
GO

-- 2. Create transformation view (only Age used, no BirthYear)
IF OBJECT_ID('vETLDimUserData') IS NOT NULL DROP VIEW vETLDimUserData;
GO

CREATE VIEW vETLDimUserData AS
SELECT DISTINCT
    UserID,
    Email,
    CASE
        WHEN TRY_CAST(Age AS INT) IS NULL THEN 'Unknown'
        WHEN TRY_CAST(Age AS INT) < 18 THEN 'Teen'
        WHEN TRY_CAST(Age AS INT) BETWEEN 18 AND 21 THEN 'Young Adult 18-21'
        WHEN TRY_CAST(Age AS INT) BETWEEN 22 AND 34 THEN 'Adult 22-34'
        WHEN TRY_CAST(Age AS INT) BETWEEN 35 AND 49 THEN 'Middle-Aged 35-49'
        WHEN TRY_CAST(Age AS INT) BETWEEN 50 AND 64 THEN 'Senior 50-64'
        ELSE 'Senior 65+'
    END AS AgeGroup,
    Gender,
    Location
FROM dbo.Stg_Users;
GO

-- 3. Expire rows where AgeGroup changed (using Email)
UPDATE u
SET u.ValidTo = GETDATE(), u.IsCurrent = 0
FROM dbo.[User] u
JOIN vETLDimUserData s ON u.Email = s.Email
WHERE u.IsCurrent = 1 AND u.Age <> s.AgeGroup;
GO

-- 4. Insert new versions for changed users
INSERT INTO dbo.[User] (User_ID, Email, Age, Gender, Location, ValidFrom, ValidTo, IsCurrent)
SELECT 
    s.UserID, s.Email, s.AgeGroup, s.Gender, s.Location,
    GETDATE(), NULL, 1
FROM vETLDimUserData s
JOIN dbo.[User] u ON s.Email = u.Email
WHERE u.IsCurrent = 0  -- just expired
  AND NOT EXISTS (
      SELECT 1 FROM dbo.[User] u2
      WHERE u2.Email = s.Email AND u2.IsCurrent = 1
  );
GO

-- 5. Insert new users
INSERT INTO dbo.[User] (User_ID, Email, Age, Gender, Location, ValidFrom, ValidTo, IsCurrent)
SELECT 
    s.UserID, s.Email, s.AgeGroup, s.Gender, s.Location,
    GETDATE(), NULL, 1
FROM vETLDimUserData s
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.[User] u
    WHERE u.Email = s.Email
);
GO

-- 6. Clean up
DROP VIEW vETLDimUserData;
GO

-- 7. Verify
SELECT * FROM dbo.[User]
ORDER BY Email, ValidFrom DESC;
