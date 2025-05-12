USE DataWarehouses

-- If you already have these tables, optionally drop them first:
DROP TABLE IF EXISTS dbo.ViewsClicks;
DROP TABLE IF EXISTS dbo.Medium;
DROP TABLE IF EXISTS dbo.AdCampaign;
DROP TABLE IF EXISTS dbo.OwnerContract;
DROP TABLE IF EXISTS dbo.ClientContract;
DROP TABLE IF EXISTS dbo.Owner;
DROP TABLE IF EXISTS dbo.Client;

-------------------------------------------------------------------------------
-- 1) Client
-------------------------------------------------------------------------------
CREATE TABLE dbo.Client
(
    ClientID INT IDENTITY(1,1) PRIMARY KEY,
    [Name]       VARCHAR(32) NOT NULL,
    [Surname]    VARCHAR(32) NOT NULL,
    [NIP]        NUMERIC(10,0) NOT NULL UNIQUE
);
-------------------------------------------------------------------------------
-- 2) Owner
-------------------------------------------------------------------------------
CREATE TABLE dbo.Owner
(
    OwnerID INT IDENTITY(1,1) PRIMARY KEY,
    [Name]       VARCHAR(32) NOT NULL,
    [Surname]    VARCHAR(32) NOT NULL,
    [NIP]        NUMERIC(10,0) NOT NULL UNIQUE
);
-------------------------------------------------------------------------------
-- 3) ClientContract
-------------------------------------------------------------------------------
CREATE TABLE dbo.ClientContract
(
    CContractID       INT IDENTITY(1,1) PRIMARY KEY,
    ClientID          INT NOT NULL,
    DateOfCommencement DATE NOT NULL,
    DateOfExpiration   DATE NOT NULL,
    Duration           INT,
    Expense            DECIMAL(10,2),
    [Click Profit]     DECIMAL(10,2),

    FOREIGN KEY (ClientID) REFERENCES dbo.Client(ClientID)
);
-------------------------------------------------------------------------------
-- 4) OwnerContract
-------------------------------------------------------------------------------
CREATE TABLE dbo.OwnerContract
(
    OContractID       INT IDENTITY(1,1) PRIMARY KEY,
    OwnerID           INT NOT NULL,
    DateOfCommencement DATE NOT NULL,
    DateOfExpiration   DATE NOT NULL,
    Duration           INT,
    [Owner Revenue]    DECIMAL(10,2),

    FOREIGN KEY (OwnerID) REFERENCES dbo.Owner(OwnerID)
);
-------------------------------------------------------------------------------
-- 5) AdCampaign
-------------------------------------------------------------------------------
CREATE TABLE dbo.AdCampaign
(
    CampaignID        INT IDENTITY(1,1) PRIMARY KEY,
    OContractID       INT NOT NULL,
    CContractID       INT NOT NULL,
    [Campaign Name]   VARCHAR(64) NOT NULL,
    [Start Date]      DATE NOT NULL,
    [End Date]        DATE NOT NULL,
    [Target Audience] INT,
    [Status]          VARCHAR(16),

    FOREIGN KEY (OContractID) REFERENCES dbo.OwnerContract(OContractID),
    FOREIGN KEY (CContractID) REFERENCES dbo.ClientContract(CContractID)
);
-------------------------------------------------------------------------------
-- 6) Medium
-------------------------------------------------------------------------------
CREATE TABLE dbo.Medium
(
    MediumID        INT IDENTITY(1,1) PRIMARY KEY,
    [TypeOfMedium]  VARCHAR(32) NOT NULL,
    [ad location]   VARCHAR(64) NOT NULL
);
-------------------------------------------------------------------------------
-- 7) ViewsClicks
-------------------------------------------------------------------------------
CREATE TABLE dbo.ViewsClicks
(
    ViewClickID   INT IDENTITY(1,1) PRIMARY KEY,
    MediumID      INT NOT NULL,
    OContractID   INT NOT NULL,
    [Views/Clicks] INT NOT NULL,   -- True (1) for click, False (0) for view
    User_Key        INT NOT NULL,    -- ID of the user interacting (tracked in CSV or optional user table)
    [Timestamp]   DATETIME NOT NULL,

    FOREIGN KEY (MediumID) REFERENCES dbo.Medium(MediumID),
    FOREIGN KEY (OContractID) REFERENCES dbo.OwnerContract(OContractID)
);
