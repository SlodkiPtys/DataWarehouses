/*  File:     LoadClients.sql
    Purpose:  Dimension load for clients (advertisers)
*/
USE AdCampaign2DB;
GO

MERGE dbo.Client AS tgt
USING (
    SELECT DISTINCT 
           CONCAT(c.[Name],' ',c.Surname)       AS NameAndSurname,
           CAST(c.NIP AS VARCHAR(32))           AS NIP
    FROM   DataWarehouses.dbo.Client AS c
) AS src
ON  tgt.NIP = src.NIP
WHEN NOT MATCHED BY TARGET THEN
     INSERT (NameAndSurname, NIP)
     VALUES (src.NameAndSurname, src.NIP);