-- LoadTime.sql
USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/* 
  Assumes your dbo.[Time] table is defined as:
    Time_ID     INT IDENTITY(1,1) PRIMARY KEY,
    Hour        INT CHECK (Hour BETWEEN 0 AND 23),
    Time_Of_Day VARCHAR(20)
*/

;WITH Hours AS (
    /* Generate numbers 0–23 */
    SELECT TOP (24) 
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS Hour
    FROM master..spt_values
)
MERGE dbo.[Time] AS tgt
USING (
    SELECT
        Hour,
        CASE 
            WHEN Hour BETWEEN 6  AND 11 THEN 'Morning'
            WHEN Hour BETWEEN 12 AND 17 THEN 'Afternoon'
            WHEN Hour BETWEEN 18 AND 21 THEN 'Evening'
            ELSE 'Night'
        END AS Time_Of_Day
    FROM Hours
) AS src
ON tgt.Hour = src.Hour

WHEN NOT MATCHED BY TARGET THEN
    INSERT (Hour, Time_Of_Day)
    VALUES (src.Hour, src.Time_Of_Day)

WHEN MATCHED AND tgt.Time_Of_Day <> src.Time_Of_Day THEN
    UPDATE SET Time_Of_Day = src.Time_Of_Day
;
GO

SELECT * FROM dbo.[Time];
