USE DataWarehouses

-------------------------------------------------------------------------------
-- T2 BULK INSERT (same order)
-- We assume you want BOTH T1 and T2 in the same tables for historical reasons.
-- If that's the case, you do NOT TRUNCATE the tables before T2. 
-- T2 references or extends T1 data.
-------------------------------------------------------------------------------

-- 1) Client_T2
BULK INSERT dbo.Client
FROM 'C:\Users\Marta\Client_T2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 2) Owner_T2
BULK INSERT dbo.Owner
FROM 'C:\Users\Marta\Owner_T2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 3) ClientContract_T2
BULK INSERT dbo.ClientContract
FROM 'C:\Users\Marta\ClientContract_T2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 4) OwnerContract_T2
BULK INSERT dbo.OwnerContract
FROM 'C:\Users\Marta\OwnerContract_T2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 5) AdCampaign_T2
BULK INSERT dbo.AdCampaign
FROM 'C:\Users\Marta\AdCampaign_T2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 6) Medium_T2
BULK INSERT dbo.Medium
FROM 'C:\Users\Marta\Medium_T2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

-- 7) ViewsClicks_T2
BULK INSERT dbo.ViewsClicks
FROM 'C:\Users\Marta\ViewsClicks_T2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
