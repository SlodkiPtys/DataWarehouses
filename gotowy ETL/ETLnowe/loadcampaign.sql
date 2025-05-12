USE AdCampaign2DB;
GO

-- Step 1: Drop the staging view if it exists
IF OBJECT_ID('vETLDimCampaign') IS NOT NULL DROP VIEW vETLDimCampaign;
GO

-- Step 2: Create staging view from the source, excluding the identity column (CampaignID is auto-generated)
CREATE VIEW vETLDimCampaign AS
SELECT DISTINCT
    A.[Campaign Name] AS Campaign_Name,
    CAST(A.[Target Audience] AS VARCHAR(32)) AS Target_Audience
FROM DataWarehouses.dbo.AdCampaign AS A;
GO

-- Step 3: Merge data into Campaign dimension table based on non-identity columns
MERGE INTO dbo.Campaign AS TT
USING vETLDimCampaign AS ST
ON TT.Campaign_Name = ST.Campaign_Name
   AND TT.Target_Audience = ST.Target_Audience
WHEN MATCHED THEN
    -- If records match, update if necessary
    UPDATE SET
        TT.Campaign_Name = ST.Campaign_Name,
        TT.Target_Audience = ST.Target_Audience
WHEN NOT MATCHED BY TARGET THEN
    -- If the record doesn't exist, insert a new record (SQL Server will auto-generate CampaignID)
    INSERT (Campaign_Name, Target_Audience)
    VALUES (ST.Campaign_Name, ST.Target_Audience);
GO

-- Step 4: Drop the staging view
DROP VIEW vETLDimCampaign;
GO

-- Step 5: Check results
SELECT * FROM dbo.Campaign;
GO
