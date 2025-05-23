-- loadtime.sql: Load Time dimension (0–23 hours)

USE AdCampaign2DB;
GO

-- 1) Usuñ zale¿ne fakty odnosz¹ce siê do Time
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
GO

-- 2) Wyczyœæ i zresetuj identity w tabeli Time
DELETE FROM dbo.[Time];
DBCC CHECKIDENT('dbo.[Time]', RESEED, 0);
GO

-- 3) Wstaw 24 godziny
INSERT INTO dbo.[Time] ([Hour], Time_Of_Day)
VALUES
  (0,  '12 AM'),
  (1,  '1 AM'),
  (2,  '2 AM'),
  (3,  '3 AM'),
  (4,  '4 AM'),
  (5,  '5 AM'),
  (6,  '6 AM'),
  (7,  '7 AM'),
  (8,  '8 AM'),
  (9,  '9 AM'),
  (10, '10 AM'),
  (11, '11 AM'),
  (12, '12 PM'),
  (13, '1 PM'),
  (14, '2 PM'),
  (15, '3 PM'),
  (16, '4 PM'),
  (17, '5 PM'),
  (18, '6 PM'),
  (19, '7 PM'),
  (20, '8 PM'),
  (21, '9 PM'),
  (22, '10 PM'),
  (23, '11 PM');
GO

Select * from Time