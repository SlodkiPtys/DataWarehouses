USE AdCampaign2DB;
GO

-- Step 1: Delete dependent fact data
DELETE FROM dbo.InterestLog;
GO

-- Step 2: Create staging view to extract and split unique interests
IF OBJECT_ID('vETLDimInterests', 'V') IS NOT NULL
    DROP VIEW vETLDimInterests;
GO

CREATE VIEW vETLDimInterests AS
SELECT DISTINCT 
    LTRIM(RTRIM(value)) AS Interest_Name
FROM dbo.Stg_Users
CROSS APPLY STRING_SPLIT(Interests, ';')
WHERE value IS NOT NULL AND LTRIM(RTRIM(value)) <> '';
GO

-- Step 3: Merge new interests into the Interests dimension
MERGE INTO dbo.Interests AS Target
USING vETLDimInterests AS Source
ON Target.Interest_Name = Source.Interest_Name
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Interest_Name)
    VALUES (Source.Interest_Name);
GO

-- Step 4: Drop the staging view
DROP VIEW vETLDimInterests;
GO

-- Step 5: Verify
SELECT * FROM dbo.Interests ORDER BY Interest_Name;
GO
