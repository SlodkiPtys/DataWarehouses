/*  File:     LoadViews_Clicks.sql
    Purpose:  Grain = one view or one click
*/
USE AdCampaign2DB;
GO

MERGE dbo.Views_Clicks AS tgt
USING (
    SELECT  vc.ViewClickID,
            c_dim.Campaign_ID,
            vc.[Views/Clicks]         AS View_Click,
            NULL                      AS Click_Profit,  -- TODO: if calculable
            u_dim.User_ID,
            t_dim.Time_ID,
            d_dim.Date_ID,
            oc.OwnerID                AS OContract_ID,
            cc.ClientID               AS CContract_ID,
            i_dim.Interest_ID
    FROM    DataWarehouses.dbo.ViewsClicks  vc
    INNER JOIN DataWarehouses.dbo.OwnerContract oc ON oc.OContractID = vc.OContractID
    INNER JOIN DataWarehouses.dbo.AdCampaign  ac ON ac.OContractID = oc.OContractID
    INNER JOIN dbo.Campaign          c_dim ON c_dim.Campaign_Name  = ac.[Campaign Name]
    INNER JOIN dbo.[User]            u_dim ON u_dim.Email          = (SELECT Email FROM Staging.Users WHERE UserID = vc.UserID)
    INNER JOIN dbo.Time              t_dim ON t_dim.Hour           = DATEPART(HOUR, vc.[Timestamp])
    INNER JOIN dbo.[Date]            d_dim ON d_dim.[Date]         = CAST(vc.[Timestamp] AS DATE)
    OUTER APPLY (                    -- pick first listed interest for the user
        SELECT TOP 1 i.Interest_ID
        FROM   dbo.Interests i
        JOIN   STRING_SPLIT((SELECT Interests FROM Staging.Users WHERE UserID = vc.UserID), ';') s  
               ON  i.Interest_Name = TRIM(s.[value])
    ) AS i_dim
    INNER JOIN DataWarehouses.dbo.ClientContract cc ON cc.CContractID = ac.CContractID
) AS src
ON  tgt.ViewClick_ID = src.ViewClickID
WHEN NOT MATCHED BY TARGET THEN
     INSERT (Campaign_ID, View_Click, Click_Profit, User_ID,
             Time_ID, Date_ID, OContract_ID, CContract_ID, Interest_ID)
     VALUES (src.Campaign_ID, src.View_Click, src.Click_Profit, src.User_ID,
             src.Time_ID, src.Date_ID, src.OContract_ID, src.CContract_ID, src.Interest_ID);
