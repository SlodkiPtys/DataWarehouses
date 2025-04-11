-- Baza
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AdCampaignDB')
BEGIN
    CREATE DATABASE AdCampaignDB;
END
GO

USE AdCampaignDB;
GO

-- Tabele wymiarowe (Dimensional Tables)

CREATE TABLE Campaign (
    Campaign_ID INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_Name VARCHAR(32),
    Target_Audience VARCHAR(32)
);

CREATE TABLE Medium (
    Medium_ID INT IDENTITY(1,1) PRIMARY KEY,
    Type_Of_Medium VARCHAR(32),
    Ad_Location VARCHAR(32)
);

CREATE TABLE Date (
    Date_ID INT IDENTITY(1,1) PRIMARY KEY,
    [Date] DATE,
    Year INT,
    Month VARCHAR(10),
    MonthNo INT,
    DayOfWeek VARCHAR(10),
    DayOfWeekNo INT,
    WorkingDay VARCHAR(16),
    Vacation VARCHAR(20),
    Holiday VARCHAR(50),
    BeforeHolidayDay VARCHAR(62)
);

CREATE TABLE Time (
    Time_ID INT IDENTITY(1,1) PRIMARY KEY,
    Hour INT,
    Time_Of_Day VARCHAR(20)
);

CREATE TABLE [User] (
    User_ID INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(32),
    Age VARCHAR(32),
    Gender VARCHAR(32),
    Location VARCHAR(32),
    Interests VARCHAR(96)
);

CREATE TABLE Client (
    Client_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(32),
    Surname VARCHAR(32),
    NIP VARCHAR(32)
);

CREATE TABLE Owner (
    Owner_ID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(32),
    Surname VARCHAR(32),
    NIP VARCHAR(32)
);

-- Tabela faktów: Conduct a campaign
CREATE TABLE Conduct_a_campaign (
    Conduct_ID INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_ID INT,
    Medium_ID INT,
    OContract_ID INT,
    CContract_ID INT,
    StartDate_ID INT,
    EndDate_ID INT,
    Duration INT,
    Profit MONEY,
    Expense MONEY,
    FOREIGN KEY (Campaign_ID) REFERENCES Campaign(Campaign_ID),
    FOREIGN KEY (Medium_ID) REFERENCES Medium(Medium_ID),
    FOREIGN KEY (StartDate_ID) REFERENCES Date(Date_ID),
    FOREIGN KEY (EndDate_ID) REFERENCES Date(Date_ID)
    -- Kontrakty z w³aœcicielem i klientem jako numery (domyœlnie, bo brak tabeli Contract)
);

-- Tabela faktów: Views/Clicks
CREATE TABLE Views_Clicks (
    ViewClick_ID INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_ID INT,
    View_Click BIT, -- 0 = click, 1 = view
    Click_Profit MONEY,
    User_ID INT,
    Time_ID INT,
    Date_ID INT,
    OContract_ID INT,
    CContract_ID INT,
    FOREIGN KEY (Campaign_ID) REFERENCES Campaign(Campaign_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID),
    FOREIGN KEY (Time_ID) REFERENCES Time(Time_ID),
    FOREIGN KEY (Date_ID) REFERENCES Date(Date_ID)
);