-- loadClient.sql: Load Client dimension

USE AdCampaign;
GO

-- 1) Usu� zale�ne fakty (je�li jeszcze nie czy�ci�e�)
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- 2) Wyczy�� i zresetuj identity w tabeli Client
DELETE FROM dbo.Client;
DBCC CHECKIDENT('dbo.Client', RESEED, 0);
GO

-- 3) Wstaw klient�w: po��cz imi� i nazwisko, skonwertuj NIP na varchar
INSERT INTO dbo.Client (NameAndSurname, NIP)
SELECT 
    C.[Name] + ' ' + C.[Surname]   AS NameAndSurname,
    CAST(C.[NIP] AS VARCHAR(32))   AS NIP
FROM DataWarehouses.dbo.Client AS C;
GO

Select * from Client