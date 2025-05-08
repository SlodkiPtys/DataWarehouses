USE AdCampaign2DB;
GO

IF OBJECT_ID('InterestLog', 'U') IS NOT NULL
    DROP TABLE InterestLog;

-- Najpierw faktowe (bo maj¹ FK do wymiarowych)
IF OBJECT_ID('Views_Clicks', 'U') IS NOT NULL
    DROP TABLE Views_Clicks;

IF OBJECT_ID('Conduct_a_campaign', 'U') IS NOT NULL
    DROP TABLE Conduct_a_campaign;

-- Potem wymiarowe
IF OBJECT_ID('Campaign', 'U') IS NOT NULL
    DROP TABLE Campaign;

IF OBJECT_ID('Medium', 'U') IS NOT NULL
    DROP TABLE Medium;

IF OBJECT_ID('Interests', 'U') IS NOT NULL
    DROP TABLE Interests;

IF OBJECT_ID('Date', 'U') IS NOT NULL
    DROP TABLE Date;

IF OBJECT_ID('Time', 'U') IS NOT NULL
    DROP TABLE Time;

IF OBJECT_ID('[User]', 'U') IS NOT NULL
    DROP TABLE [User];

IF OBJECT_ID('Client', 'U') IS NOT NULL
    DROP TABLE Client;

IF OBJECT_ID('Owner', 'U') IS NOT NULL
    DROP TABLE Owner;