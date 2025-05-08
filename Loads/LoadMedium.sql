USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/* Load new media types into Medium dimension */
MERGE dbo.Medium AS tgt
USING (
    SELECT DISTINCT
        [TypeOfMedium] AS Type_Of_Medium,
        [ad location]  AS Ad_Location
    FROM DataWarehouses.dbo.Medium
) AS src
ON tgt.Type_Of_Medium = src.Type_Of_Medium
   AND tgt.Ad_Location    = src.Ad_Location
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Type_Of_Medium, Ad_Location)
    VALUES (src.Type_Of_Medium, src.Ad_Location);
GO

Select * from Medium