USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/* 1. Ensure staging table */
IF OBJECT_ID('Staging.Users','U') IS NULL
BEGIN
    CREATE TABLE Staging.Users (
        UserID     INT,
        [E-mail]   VARCHAR(100),
        Gender     VARCHAR(20),
        Location   VARCHAR(50),
        Interests  VARCHAR(255),
        BirthYear  INT,
        Age        INT
    );
END

/* 2. Reload CSV via BULK INSERT (path must be adjusted) */
TRUNCATE TABLE Staging.Users;
BULK INSERT Staging.Users
FROM 'C:\Users\user\PycharmProjects\T1\.venv\user_ad_interactions_T1.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    CODEPAGE        = '65001',
    TABLOCK
);

/* 3. Cleanse data */
UPDATE S
SET
    [E-mail]  = LTRIM(RTRIM(REPLACE([E-mail],'"',''))),
    Gender    = CASE
                   WHEN Gender IN ('M','Male','male')   THEN 'Male'
                   WHEN Gender IN ('F','Female','female') THEN 'Female'
                   ELSE 'Other'
                END,
    Location  = NULLIF(LTRIM(RTRIM(REPLACE(Location,'"',''))), ''),
    Interests = NULLIF(LTRIM(RTRIM(REPLACE(Interests,'"',''))), '')
FROM Staging.Users AS S;

/* 4. Merge into dbo.[User] */
IF OBJECT_ID('dbo.[User]','U') IS NULL
BEGIN
    CREATE TABLE dbo.[User] (
        User_ID INT IDENTITY(1,1) PRIMARY KEY,
        Email   VARCHAR(100) NOT NULL UNIQUE,
        Age     INT,
        Gender  VARCHAR(20),
        Location VARCHAR(50),
        Load_Dtm DATETIME NOT NULL DEFAULT GETDATE()
    );
END

;WITH Clean AS (
    SELECT
        LTRIM(RTRIM([E-mail])) AS Email,
        COALESCE(
            NULLIF(Age,0),
            CASE WHEN BirthYear BETWEEN 1900 AND YEAR(GETDATE())
                 THEN DATEDIFF(YEAR, DATEFROMPARTS(BirthYear,1,1),
                               CAST(GETDATE() AS date))
            END
        ) AS Age,
        Gender,
        Location,
        ROW_NUMBER() OVER (
            PARTITION BY LTRIM(RTRIM([E-mail]))
            ORDER BY UserID DESC
        ) AS rn
    FROM Staging.Users
    WHERE [E-mail] IS NOT NULL
)
MERGE dbo.[User] AS tgt
USING (
    SELECT Email, Age, Gender, Location
    FROM Clean WHERE rn = 1
) AS src
ON tgt.Email = src.Email
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Email, Age, Gender, Location)
    VALUES (src.Email, src.Age, src.Gender, src.Location)
WHEN MATCHED AND (
        ISNULL(tgt.Age,-1)     <> ISNULL(src.Age,-1)    OR
        ISNULL(tgt.Gender,'')  <> ISNULL(src.Gender,'') OR
        ISNULL(tgt.Location,'')<> ISNULL(src.Location,'')
)
THEN
    UPDATE SET
        Age      = src.Age,
        Gender   = src.Gender,
        Location = src.Location;
GO

Select * from [User]