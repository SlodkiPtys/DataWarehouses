-- loadOwner.sql: Load Owner dimension

USE AdCampaign;
GO

-- 1) Usu� zale�ne fakty (je�li jeszcze nie czy�ci�e�)
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- 2) Wyczy�� i zresetuj identity w tabeli Owner
DELETE FROM dbo.Owner;
DBCC CHECKIDENT('dbo.Owner', RESEED, 0);
GO

-- 3) Wstaw w�a�cicieli: po��cz imi� i nazwisko, skonwertuj NIP na varchar
INSERT INTO dbo.Owner (NameAndSurname, NIP)
SELECT 
    O.[Name] + ' ' + O.[Surname]   AS NameAndSurname,
    CAST(O.[NIP] AS VARCHAR(32))   AS NIP
FROM DataWarehouses.dbo.Owner AS O;
GO

select * from Owner