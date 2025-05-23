USE AdCampaign2DB;
GO

-- Step 1: Drop the staging view if it exists
IF OBJECT_ID('vETLDimCampaign') IS NOT NULL 
    DROP VIEW vETLDimCampaign;
GO

-- Step 2: Create staging view with audience size bins
CREATE VIEW vETLDimCampaign AS
SELECT DISTINCT
    A.[Campaign Name] AS Campaign_Name,
    CAST(A.[Target Audience] AS VARCHAR(32)) AS Raw_Target_Audience,
    CASE 
        WHEN TRY_CAST(A.[Target Audience] AS INT) IS NULL THEN 'Unknown'
        WHEN CAST(A.[Target Audience] AS INT) < 10000 THEN 'Tiny Audience'
        WHEN CAST(A.[Target Audience] AS INT) BETWEEN 10000 AND 24999 THEN 'Small Audience'
        WHEN CAST(A.[Target Audience] AS INT) BETWEEN 25000 AND 49999 THEN 'Medium Audience'
        WHEN CAST(A.[Target Audience] AS INT) BETWEEN 50000 AND 74999 THEN 'Large Audience'
        WHEN CAST(A.[Target Audience] AS INT) BETWEEN 75000 AND 99999 THEN 'Very Large Audience'
        ELSE 'Mass Audience'
    END AS Target_Audience_Bin
FROM DataWarehouses.dbo.AdCampaign AS A;
GO


-- Step 3: Merge binned data into Campaign dimension table
MERGE INTO dbo.Campaign AS TT
USING vETLDimCampaign AS ST
ON TT.Campaign_Name = ST.Campaign_Name
   AND TT.Target_Audience = ST.Target_Audience_Bin
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Campaign_Name, Target_Audience)
    VALUES (ST.Campaign_Name, ST.Target_Audience_Bin);
GO

-- Step 4: Drop the staging view
DROP VIEW vETLDimCampaign;
GO

-- Step 5: Check results
SELECT * FROM dbo.Campaign;
GO
