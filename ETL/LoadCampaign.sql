/*  File:     LoadCampaign.sql
    Purpose:  Dimension load from operational AdCampaign table
*/
USE AdCampaign2DB;
GO

MERGE dbo.Campaign AS tgt
USING (
    SELECT DISTINCT 
           [Campaign Name]       AS Campaign_Name,
           CAST([Target Audience] AS VARCHAR(32)) AS Target_Audience
    FROM   DataWarehouses.dbo.AdCampaign
) AS src
ON   tgt.Campaign_Name = src.Campaign_Name
WHEN NOT MATCHED BY TARGET THEN
     INSERT (Campaign_Name, Target_Audience)
     VALUES (src.Campaign_Name, src.Target_Audience);
