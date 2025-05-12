-- Remove BOM and ensure first line is exactly: USE AdCampaign;
USE AdCampaign2DB;
GO

-- Drop tables in correct dependency order
IF OBJECT_ID('dbo.InterestLog', 'U') IS NOT NULL DROP TABLE dbo.InterestLog;
IF OBJECT_ID('dbo.Views_Clicks', 'U') IS NOT NULL DROP TABLE dbo.Views_Clicks;
IF OBJECT_ID('dbo.Conduct_a_campaign', 'U') IS NOT NULL DROP TABLE dbo.Conduct_a_campaign;
IF OBJECT_ID('dbo.[User]', 'U') IS NOT NULL DROP TABLE dbo.[User];
IF OBJECT_ID('dbo.Time', 'U') IS NOT NULL DROP TABLE dbo.Time;
IF OBJECT_ID('dbo.Date', 'U') IS NOT NULL DROP TABLE dbo.Date;
IF OBJECT_ID('dbo.Interests', 'U') IS NOT NULL DROP TABLE dbo.Interests;
IF OBJECT_ID('dbo.Medium', 'U') IS NOT NULL DROP TABLE dbo.Medium;
IF OBJECT_ID('dbo.Campaign', 'U') IS NOT NULL DROP TABLE dbo.Campaign;
IF OBJECT_ID('dbo.Client', 'U') IS NOT NULL DROP TABLE dbo.Client;
IF OBJECT_ID('dbo.Owner', 'U') IS NOT NULL DROP TABLE dbo.Owner;
GO

-- Dimension tables

-- Campaign
CREATE TABLE Campaign (
    Campaign_ID   INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_Name VARCHAR(32),
    Target_Audience VARCHAR(32)
);

-- Medium
CREATE TABLE Medium (
    Medium_ID     INT IDENTITY(1,1) PRIMARY KEY,
    Type_Of_Medium VARCHAR(32),
    Ad_Location    VARCHAR(32)
);

-- Interests
CREATE TABLE Interests (
    Interest_ID   INT IDENTITY(1,1) PRIMARY KEY,
    Interest_Name VARCHAR(32)
);

-- Date
CREATE TABLE Date (
    Date_ID        INT IDENTITY(1,1) PRIMARY KEY,
    [Date]         DATE,
    [Year]         INT,
    Month          VARCHAR(10),
    MonthNo        INT,
    DayOfWeek      VARCHAR(10),
    DayOfWeekNo    INT,
    WorkingDay     VARCHAR(16),
    Vacation       VARCHAR(20),
    Holiday        VARCHAR(50),
    BeforeHolidayDay VARCHAR(62)
);

-- Time
CREATE TABLE [Time] (
    Time_ID       INT IDENTITY(1,1) PRIMARY KEY,
    [Hour]        INT CHECK ([Hour] BETWEEN 0 AND 23),
    Time_Of_Day   VARCHAR(20)
);

-- User table with surrogate key for SCD2
CREATE TABLE [User] (
    User_Key      INT IDENTITY(1,1) PRIMARY KEY,  -- Surrogate key
    User_ID       INT,                            -- Business key (can repeat)
    Email         VARCHAR(32),
    Age           VARCHAR(32),                    -- Age Group
    Gender        VARCHAR(32),
    Location      VARCHAR(32),
    ValidFrom     DATETIME NOT NULL,
    ValidTo       DATETIME NULL,
    IsCurrent     BIT
);


-- Client
CREATE TABLE Client (
    Client_ID     INT IDENTITY(1,1) PRIMARY KEY,
    NameAndSurname VARCHAR(32),
    NIP           VARCHAR(32)
);

-- Owner
CREATE TABLE Owner (
    Owner_ID      INT IDENTITY(1,1) PRIMARY KEY,
    NameAndSurname VARCHAR(32),
    NIP           VARCHAR(32)
);

-- Fact table: Conduct a Campaign
CREATE TABLE Conduct_a_campaign (
    Conduct_ID    INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_ID   INT        NOT NULL,
    Medium_ID     INT        NOT NULL,
    OContract_ID  INT        NOT NULL,
    CContract_ID  INT        NOT NULL,
    StartDate_ID  INT        NOT NULL,
    EndDate_ID    INT        NOT NULL,
    Duration      INT,
    Profit        MONEY,
    Expense       MONEY,
    FOREIGN KEY (Campaign_ID)   REFERENCES Campaign(Campaign_ID),
    FOREIGN KEY (Medium_ID)     REFERENCES Medium(Medium_ID),
    FOREIGN KEY (OContract_ID)  REFERENCES Owner(Owner_ID),
    FOREIGN KEY (CContract_ID)  REFERENCES Client(Client_ID),
    FOREIGN KEY (StartDate_ID)  REFERENCES Date(Date_ID),
    FOREIGN KEY (EndDate_ID)    REFERENCES Date(Date_ID)
);

-- Fact table: Views/Clicks (UPDATED to use User_Key)
CREATE TABLE Views_Clicks (
    ViewClick_ID  INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_ID   INT        NOT NULL,
    View_Click    INT,
    Click_Profit  MONEY,
    User_Key      INT        NOT NULL,       -- Renamed and updated FK
    Time_ID       INT        NOT NULL,
    Date_ID       INT        NOT NULL,
    OContract_ID  INT        NOT NULL,
    CContract_ID  INT        NOT NULL,
    FOREIGN KEY (Campaign_ID)   REFERENCES Campaign(Campaign_ID),
    FOREIGN KEY (User_Key)       REFERENCES [User](User_Key),    -- SCD2-compliant
    FOREIGN KEY (Time_ID)       REFERENCES [Time](Time_ID),
    FOREIGN KEY (Date_ID)       REFERENCES Date(Date_ID),
    FOREIGN KEY (OContract_ID)  REFERENCES Owner(Owner_ID),
    FOREIGN KEY (CContract_ID)  REFERENCES Client(Client_ID)
);


-- Fact table: InterestLog
CREATE TABLE InterestLog (
    InterestLog_ID INT IDENTITY(1,1) PRIMARY KEY,
    ViewClick_ID   INT NOT NULL,
    Interest_ID    INT NOT NULL,
    FOREIGN KEY (ViewClick_ID) REFERENCES Views_Clicks(ViewClick_ID),
    FOREIGN KEY (Interest_ID)  REFERENCES Interests(Interest_ID)
);
GO