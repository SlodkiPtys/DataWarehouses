USE AdCampaign2DB;
GO

IF OBJECT_ID('vETLDimClient') IS NOT NULL DROP VIEW vETLDimClient;
GO

-- Create the staging view
CREATE VIEW vETLDimClient AS
SELECT DISTINCT
    C.[Name] + ' ' + C.[Surname] AS NameAndSurname,
    CAST(C.[NIP] AS VARCHAR(32)) AS NIP
FROM DataWarehouses.dbo.Client AS C;
GO

-- Merge using NIP as business key
MERGE INTO dbo.Client AS TT
USING vETLDimClient AS ST
ON TT.NIP = ST.NIP
WHEN NOT MATCHED BY TARGET THEN
    INSERT (NameAndSurname, NIP)
    VALUES (ST.NameAndSurname, ST.NIP);
GO

-- Drop the staging view
DROP VIEW vETLDimClient;
GO

-- Check result
SELECT * FROM dbo.Client;
