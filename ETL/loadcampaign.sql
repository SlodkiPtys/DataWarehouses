-- loadCampaign.sql: Load Campaign dimension

USE AdCampaign;
GO

-- 1) Usuñ zale¿ne fakty (jeœli jeszcze nie czyœci³eœ)
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- 2) Wyczyœæ i zresetuj identity w tabeli Campaign
DELETE FROM dbo.Campaign;
DBCC CHECKIDENT('dbo.Campaign', RESEED, 0);
GO

-- 3) Wstaw kampanie: nazwa i docelowa grupa (cast z INT na VARCHAR)
INSERT INTO dbo.Campaign (Campaign_Name, Target_Audience)
SELECT 
    A.[Campaign Name]                     AS Campaign_Name,
    CAST(A.[Target Audience] AS VARCHAR(32)) AS Target_Audience
FROM DataWarehouses.dbo.AdCampaign AS A;
GO
