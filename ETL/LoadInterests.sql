/*  File:     LoadInterests.sql
    Purpose:  Parse unique interests out of Staging.Users and populate dimension
*/
USE AdCampaign2DB;
GO

;WITH DistinctInterest AS (
    SELECT  DISTINCT TRIM(value) AS Interest_Name
    FROM    Staging.Users
    CROSS APPLY STRING_SPLIT(Interests,';')
)
MERGE dbo.Interests AS tgt
USING DistinctInterest AS src
ON  tgt.Interest_Name = src.Interest_Name
WHEN NOT MATCHED BY TARGET THEN
     INSERT (Interest_Name) VALUES (src.Interest_Name);
