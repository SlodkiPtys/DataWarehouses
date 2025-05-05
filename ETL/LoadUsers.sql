/*  File:     LoadUsers.sql
    Purpose:  Load the User dimension
              — assumes CSV is first BULK‑inserted into Staging.Users                    */
USE AdCampaignDB;
GO

MERGE dbo.[User] AS tgt
USING (
    SELECT  Email          ,
            CAST(Age AS VARCHAR(32))    AS Age ,
            Gender        ,
            Location
    FROM    Staging.Users               -- <- created via BULK INSERT/ADF/SSIS Flat‑file source
) AS src
ON  tgt.Email = src.Email
WHEN NOT MATCHED BY TARGET THEN
     INSERT (Email, Age, Gender, Location)
     VALUES (src.Email, src.Age, src.Gender, src.Location);
