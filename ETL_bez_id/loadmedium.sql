USE AdCampaign2DB;
GO

-- Step 1: Drop the staging view if it exists
IF OBJECT_ID('vETLDimMedium') IS NOT NULL DROP VIEW vETLDimMedium;
GO

-- Step 2: Create staging view from source
CREATE VIEW vETLDimMedium AS
SELECT DISTINCT
    M.[TypeOfMedium] AS Type_Of_Medium,
    M.[ad location]  AS Ad_Location
FROM DataWarehouses.dbo.Medium AS M;
GO

-- Step 3: Merge data into Medium dimension table
MERGE INTO dbo.Medium AS TT
USING vETLDimMedium AS ST
ON TT.Type_Of_Medium = ST.Type_Of_Medium AND TT.Ad_Location = ST.Ad_Location
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Type_Of_Medium, Ad_Location)
    VALUES (ST.Type_Of_Medium, ST.Ad_Location);
GO

-- Step 4: Drop the staging view
DROP VIEW vETLDimMedium;
GO

-- Step 5: Check results
SELECT * FROM dbo.Medium;
GO
