-- loadClient.sql: Load Client dimension

USE AdCampaign;
GO

-- 1) Usuñ zale¿ne fakty (jeœli jeszcze nie czyœci³eœ)
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- 2) Wyczyœæ i zresetuj identity w tabeli Client
DELETE FROM dbo.Client;
DBCC CHECKIDENT('dbo.Client', RESEED, 0);
GO

-- 3) Wstaw klientów: po³¹cz imiê i nazwisko, skonwertuj NIP na varchar
INSERT INTO dbo.Client (NameAndSurname, NIP)
SELECT 
    C.[Name] + ' ' + C.[Surname]   AS NameAndSurname,
    CAST(C.[NIP] AS VARCHAR(32))   AS NIP
FROM DataWarehouses.dbo.Client AS C;
GO

Select * from Client