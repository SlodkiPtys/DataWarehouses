-- File: LoadInterestLog.sql

USE AdCampaign2DB;
GO
SET NOCOUNT ON;

--------------------------------------------------------------------
-- 0. Ensure the InterestLog table exists (with proper constraints)
--------------------------------------------------------------------
IF OBJECT_ID('dbo.InterestLog','U') IS NULL
BEGIN
    CREATE TABLE dbo.InterestLog
    (
        InterestLog_ID INT IDENTITY(1,1) PRIMARY KEY,
        ViewClick_ID   INT NOT NULL,
        Interest_ID    INT NOT NULL,
        Load_Dtm       DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT UQ_InterestLog UNIQUE(ViewClick_ID, Interest_ID),
        CONSTRAINT FK_IL_ViewClick FOREIGN KEY(ViewClick_ID)
            REFERENCES dbo.Views_Clicks(ViewClick_ID),
        CONSTRAINT FK_IL_Interest FOREIGN KEY(Interest_ID)
            REFERENCES dbo.Interests(Interest_ID)
    );
END
GO

--------------------------------------------------------------------
-- 1. Stage each (ViewClick × Interest) pair by splitting Staging.Users.Interests
--------------------------------------------------------------------
IF OBJECT_ID('tempdb..#IL_Source','U') IS NOT NULL
    DROP TABLE #IL_Source;
GO

;WITH UserInterests AS (
    -- split each user's semicolon-separated Interests
    SELECT
      su.UserID,
      TRIM(value) AS Interest_Name
    FROM Staging.Users AS su
    CROSS APPLY STRING_SPLIT(su.Interests, ';')
    WHERE su.Interests IS NOT NULL
),
InterestPairs AS (
    -- join each viewclick to its user, then to each of their interests
    SELECT DISTINCT
      vc.ViewClick_ID,
      i_dim.Interest_ID
    FROM dbo.Views_Clicks AS vc
    JOIN UserInterests      AS ui
      ON ui.UserID = vc.User_ID
    JOIN dbo.Interests      AS i_dim
      ON i_dim.Interest_Name = ui.Interest_Name
)
SELECT
  ViewClick_ID,
  Interest_ID
INTO #IL_Source
FROM InterestPairs;
GO

--------------------------------------------------------------------
-- 2. (Optional) Sanity check: how many pairs are we staging?
--------------------------------------------------------------------
SELECT COUNT(*) AS StagedPairs
FROM #IL_Source;
GO

--------------------------------------------------------------------
-- 3. Merge new pairs into InterestLog (avoid duplicates)
--------------------------------------------------------------------
MERGE dbo.InterestLog AS tgt
USING #IL_Source AS src
  ON tgt.ViewClick_ID = src.ViewClick_ID
 AND tgt.Interest_ID  = src.Interest_ID
WHEN NOT MATCHED BY TARGET THEN
  INSERT (ViewClick_ID, Interest_ID)
  VALUES (src.ViewClick_ID, src.Interest_ID);
GO

--------------------------------------------------------------------
-- 4. Clean up the staging table
--------------------------------------------------------------------
DROP TABLE #IL_Source;
GO

--------------------------------------------------------------------
-- 5. Verify results (optional)
--------------------------------------------------------------------
SELECT *
FROM dbo.InterestLog
ORDER BY InterestLog_ID;
GO
