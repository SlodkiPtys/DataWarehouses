-- loadMedium.sql: Load Medium dimension

USE AdCampaign;
GO

-- 1) Usuñ zale¿ne fakty (jeœli jeszcze nie czyœci³eœ)
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- 2) Wyczyœæ i zresetuj identity w tabeli Medium
DELETE FROM dbo.Medium;
DBCC CHECKIDENT('dbo.Medium', RESEED, 0);
GO

-- 3) Wstaw rekordy medium: typ i lokalizacja reklamy
INSERT INTO dbo.Medium (Type_Of_Medium, Ad_Location)
SELECT 
    M.[TypeOfMedium]   AS Type_Of_Medium,
    M.[ad location]    AS Ad_Location
FROM DataWarehouses.dbo.Medium AS M;
GO

Select * from Medium