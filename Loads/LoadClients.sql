USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/* Load new advertisers into Client dimension */
MERGE dbo.Client AS tgt
USING (
    SELECT DISTINCT
        CONCAT(c.[Name],' ',c.Surname) AS NameAndSurname,
        CAST(c.NIP AS VARCHAR(32))     AS NIP
    FROM DataWarehouses.dbo.Client AS c
) AS src
ON tgt.NIP = src.NIP
WHEN NOT MATCHED BY TARGET THEN
    INSERT (NameAndSurname, NIP)
    VALUES (src.NameAndSurname, src.NIP);
GO

Select * from Client