/*  File:     LoadConduct_a_Campaign.sql
    Purpose:  Fact table for every campaign / contract pairing
*/
USE AdCampaign2DB;
GO

MERGE dbo.Conduct_a_campaign AS tgt
USING (
    SELECT  ac.CampaignID,
            m_dim.Medium_ID,
            oc.OwnerID,
            cc.ClientID,
            d_start.Date_ID     AS StartDate_ID,
            d_end.Date_ID       AS EndDate_ID,
            DATEDIFF(DAY, ac.[Start Date], ac.[End Date]) AS Duration,
            oc.[Owner Revenue]  AS Profit,
            cc.Expense
    FROM    DataWarehouses.dbo.AdCampaign      ac
    INNER JOIN DataWarehouses.dbo.OwnerContract oc  ON ac.OContractID = oc.OContractID
    INNER JOIN DataWarehouses.dbo.ClientContract cc ON ac.CContractID = cc.CContractID
    /*  OPTIONAL: if Campaign↔Medium lives only via ViewsClicks, use MAX() etc.             */
    LEFT  JOIN DataWarehouses.dbo.ViewsClicks  vc  ON vc.OContractID = ac.OContractID
    LEFT  JOIN dbo.Medium            m_dim ON m_dim.Type_Of_Medium = 'N/A'  -- TODO: map properly
    INNER JOIN dbo.Campaign          c_dim ON c_dim.Campaign_Name  = ac.[Campaign Name]
    INNER JOIN dbo.[Date]            d_start ON d_start.[Date] = ac.[Start Date]
    INNER JOIN dbo.[Date]            d_end   ON d_end.[Date]   = ac.[End Date]
) AS src
ON  tgt.Campaign_ID  = src.CampaignID
AND tgt.OContract_ID = src.OwnerID
AND tgt.CContract_ID = src.ClientID
WHEN NOT MATCHED BY TARGET THEN
     INSERT (Campaign_ID, Medium_ID, OContract_ID, CContract_ID, 
             StartDate_ID, EndDate_ID, Duration, Profit, Expense)
     VALUES (src.CampaignID, src.Medium_ID, src.OwnerID, src.ClientID,
             src.StartDate_ID, src.EndDate_ID, src.Duration, src.Profit, src.Expense);
