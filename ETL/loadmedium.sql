-- loadMedium.sql: Load Medium dimension

USE AdCampaign;
GO

-- 1) Usu� zale�ne fakty (je�li jeszcze nie czy�ci�e�)
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- 2) Wyczy�� i zresetuj identity w tabeli Medium
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