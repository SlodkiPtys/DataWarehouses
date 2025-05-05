/*  File:     LoadTime.sql
    Purpose:  Fill the 24‑row Time‑of‑day dimension
*/
USE AdCampaign2DB;
GO

;WITH Hours AS (
    SELECT TOP (24) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Hour
    FROM sys.columns   -- any sufficiently large catalog view
)
MERGE dbo.[Time] AS tgt
USING (
    SELECT  Hour,
            CASE 
                 WHEN Hour BETWEEN 6  AND 11 THEN 'Morning'
                 WHEN Hour BETWEEN 12 AND 17 THEN 'Afternoon'
                 WHEN Hour BETWEEN 18 AND 21 THEN 'Evening'
                 ELSE 'Night'
            END AS Time_Of_Day
    FROM Hours
) AS src
ON  tgt.Hour = src.Hour
WHEN NOT MATCHED BY TARGET THEN
    INSERT (Hour, Time_Of_Day) VALUES (src.Hour, src.Time_Of_Day);
