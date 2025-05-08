USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/* Ensure Interests dimension exists */
IF OBJECT_ID('dbo.Interests','U') IS NULL
BEGIN
    CREATE TABLE dbo.Interests (
        Interest_ID   INT IDENTITY(1,1) PRIMARY KEY,
        Interest_Name VARCHAR(100) NOT NULL UNIQUE
    );
END

/* Merge new interests from staging */
;WITH DistinctInterest AS (
    SELECT DISTINCT TRIM(value) AS Interest_Name
    FROM Staging.Users
    CROSS APPLY STRING_SPLIT(Interests,';')
    WHERE Interests IS NOT NULL
)
MERGE dbo.Interests AS tgt
USING DistinctInterest AS src
ON tgt.Interest_Name = src.Interest_Name
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Interest_Name)
    VALUES (src.Interest_Name);
GO

Select * from Interests