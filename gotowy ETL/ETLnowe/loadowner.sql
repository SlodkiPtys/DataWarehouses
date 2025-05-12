USE AdCampaign2DB;
GO

-- Step 1: Drop staging view if it exists
IF OBJECT_ID('vETLOwner') IS NOT NULL DROP VIEW vETLOwner;
GO

-- Step 2: Create staging view
CREATE VIEW vETLOwner AS
SELECT DISTINCT
    O.[Name] + ' ' + O.[Surname] AS NameAndSurname,
    CAST(O.[NIP] AS VARCHAR(32)) AS NIP
FROM DataWarehouses.dbo.Owner AS O;
GO

-- Step 3: Merge data into dimension table
MERGE INTO dbo.Owner AS TT
USING vETLOwner AS ST
ON TT.NIP = ST.NIP
WHEN NOT MATCHED BY TARGET THEN
    INSERT (NameAndSurname, NIP)
    VALUES (ST.NameAndSurname, ST.NIP);
GO

-- Step 4: Drop the staging view
DROP VIEW vETLOwner;
GO

-- Step 5: Verify load
SELECT * FROM dbo.Owner;
GO
