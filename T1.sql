USE DataWarehouses

-------------------------------------------------------------------------------
-- 0) (Optional) If the tables are empty or if you want to re-load data,
--    you can TRUNCATE them before reloading:
-- TRUNCATE TABLE dbo.ViewsClicks;
-- TRUNCATE TABLE dbo.Medium;
-- TRUNCATE TABLE dbo.AdCampaign;
-- TRUNCATE TABLE dbo.OwnerContract;
-- TRUNCATE TABLE dbo.ClientContract;
-- TRUNCATE TABLE dbo.Owner;
-- TRUNCATE TABLE dbo.Client;

-------------------------------------------------------------------------------
-- T1 BULK INSERT (in correct order)
-------------------------------------------------------------------------------

-- 1) Client_T1
BULK INSERT dbo.Client
FROM 'C:\Users\user\PycharmProjects\PythonProject1\.venv\Client_T1.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 2) Owner_T1
BULK INSERT dbo.Owner
FROM 'C:\Users\user\PycharmProjects\PythonProject1\.venv\Owner_T1.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 3) ClientContract_T1
BULK INSERT dbo.ClientContract
FROM 'C:\Users\user\PycharmProjects\PythonProject1\.venv\ClientContract_T1.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 4) OwnerContract_T1
BULK INSERT dbo.OwnerContract
FROM 'C:\Users\user\PycharmProjects\PythonProject1\.venv\OwnerContract_T1.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 5) AdCampaign_T1
BULK INSERT dbo.AdCampaign
FROM 'C:\Users\user\PycharmProjects\PythonProject1\.venv\AdCampaign_T1.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 6) Medium_T1
BULK INSERT dbo.Medium
FROM 'C:\Users\user\PycharmProjects\PythonProject1\.venv\Medium_T1.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 7) ViewsClicks_T1
BULK INSERT dbo.ViewsClicks
FROM 'C:\Users\user\PycharmProjects\PythonProject1\.venv\ViewsClicks_T1.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

