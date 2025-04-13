USE AdCampaignDB;
GO

-- 📊 Tabele wymiarowe

-- Campaign
CREATE TABLE Campaign (
    Campaign_ID INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_Name VARCHAR(32),
    Target_Audience VARCHAR(32)
);

-- Medium
CREATE TABLE Medium (
    Medium_ID INT IDENTITY(1,1) PRIMARY KEY,
    Type_Of_Medium VARCHAR(32),
    Ad_Location VARCHAR(32)
);

-- Interests
CREATE TABLE Interests (
    Interest_ID INT IDENTITY(1,1) PRIMARY KEY,
    Interest_Name VARCHAR(32)
);

-- Date
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

-- Time
CREATE TABLE Time (
    Time_ID INT IDENTITY(1,1) PRIMARY KEY,
    Hour INT CHECK (Hour BETWEEN 0 AND 23),
    Time_Of_Day VARCHAR(20)
);

-- User
CREATE TABLE [User] (
    User_ID INT IDENTITY(1,1) PRIMARY KEY,
    Email VARCHAR(32),
    Age VARCHAR(32),
    Gender VARCHAR(32),
    Location VARCHAR(32)
);

-- Client (pojedyncze pole NameAndSurname)
CREATE TABLE Client (
    Client_ID INT IDENTITY(1,1) PRIMARY KEY,
    NameAndSurname VARCHAR(32),
    NIP VARCHAR(32)
);

-- Owner (pojedyncze pole NameAndSurname)
CREATE TABLE Owner (
    Owner_ID INT IDENTITY(1,1) PRIMARY KEY,
    NameAndSurname VARCHAR(32),
    NIP VARCHAR(32)
);

-- 📈 Conduct a Campaign – tabela faktów
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
    FOREIGN KEY (OContract_ID) REFERENCES Owner(Owner_ID),
    FOREIGN KEY (CContract_ID) REFERENCES Client(Client_ID),
    FOREIGN KEY (StartDate_ID) REFERENCES Date(Date_ID),
    FOREIGN KEY (EndDate_ID) REFERENCES Date(Date_ID)
);

-- 📉 Views/Clicks – tabela faktów
CREATE TABLE Views_Clicks (
    ViewClick_ID INT IDENTITY(1,1) PRIMARY KEY,
    Campaign_ID INT,
    View_Click BIT,
    Click_Profit MONEY,
    User_ID INT,
    Time_ID INT,
    Date_ID INT,
    OContract_ID INT,
    CContract_ID INT,
    Interest_ID INT,
    FOREIGN KEY (Campaign_ID) REFERENCES Campaign(Campaign_ID),
    FOREIGN KEY (User_ID) REFERENCES [User](User_ID),
    FOREIGN KEY (Time_ID) REFERENCES Time(Time_ID),
    FOREIGN KEY (Date_ID) REFERENCES Date(Date_ID),
    FOREIGN KEY (OContract_ID) REFERENCES Owner(Owner_ID),
    FOREIGN KEY (CContract_ID) REFERENCES Client(Client_ID),
    FOREIGN KEY (Interest_ID) REFERENCES Interests(Interest_ID)
);
