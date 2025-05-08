USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/* Load new owners into Owner dimension */
MERGE dbo.Owner AS tgt
USING (
    SELECT DISTINCT
        CONCAT(o.[Name],' ',o.Surname) AS NameAndSurname,
        CAST(o.NIP AS VARCHAR(32))     AS NIP
    FROM DataWarehouses.dbo.Owner AS o
) AS src
ON tgt.NIP = src.NIP
WHEN NOT MATCHED BY TARGET THEN
    INSERT (NameAndSurname, NIP)
    VALUES (src.NameAndSurname, src.NIP);
GO

Select * from Owner