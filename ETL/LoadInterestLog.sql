/*  File:     LoadInterestLog.sql
    Purpose:  Optional helper fact (User x Interest x Date)
              Generates an aggregated "interest‑impression" log for analysis services
*/
USE AdCampaign2DB;
GO

IF OBJECT_ID('dbo.InterestLog','U') IS NULL
BEGIN
    CREATE TABLE dbo.InterestLog (
        InterestLog_ID INT IDENTITY(1,1) PRIMARY KEY,
        User_ID        INT,
        Interest_ID    INT,
        Date_ID        INT,
        Views          INT,
        Clicks         INT
    );
END

MERGE dbo.InterestLog AS tgt
USING (
    SELECT  vc.User_ID,
            vc.Interest_ID,
            vc.Date_ID,
            SUM(CASE WHEN vc.View_Click = 0 THEN 1 ELSE 0 END) AS Views,
            SUM(CASE WHEN vc.View_Click = 1 THEN 1 ELSE 0 END) AS Clicks
    FROM    dbo.Views_Clicks vc
    GROUP BY vc.User_ID, vc.Interest_ID, vc.Date_ID
) AS src
ON  tgt.User_ID     = src.User_ID
AND tgt.Interest_ID = src.Interest_ID
AND tgt.Date_ID     = src.Date_ID
WHEN MATCHED THEN 
     UPDATE SET Views  = src.Views,
                Clicks = src.Clicks
WHEN NOT MATCHED BY TARGET THEN
     INSERT (User_ID, Interest_ID, Date_ID, Views, Clicks)
     VALUES (src.User_ID, src.Interest_ID, src.Date_ID, src.Views, src.Clicks);
