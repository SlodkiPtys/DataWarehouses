-- LoadDate.sql
USE AdCampaign2DB;
GO
SET NOCOUNT ON;

/* Ensure helper HolidayCalendar exists */
IF OBJECT_ID('dbo.HolidayCalendar','U') IS NULL
BEGIN
    CREATE TABLE dbo.HolidayCalendar (
        HolidayDate DATE PRIMARY KEY,
        HolidayName VARCHAR(50)
    );
END

/* Determine date range from source fact tables */
DECLARE @MinDate DATE, @MaxDate DATE;
SELECT
    @MinDate = MIN(D), @MaxDate = MAX(D)
FROM (
    SELECT MIN([Timestamp]) FROM DataWarehouses.dbo.ViewsClicks
    UNION ALL
    SELECT MAX([Timestamp]) FROM DataWarehouses.dbo.ViewsClicks
    UNION ALL
    SELECT MIN([Start Date]) FROM DataWarehouses.dbo.AdCampaign
    UNION ALL
    SELECT MAX([End Date])   FROM DataWarehouses.dbo.AdCampaign
) AS x(D);

IF @MinDate IS NULL SET @MinDate = '2025-01-01';
IF @MaxDate IS NULL SET @MaxDate = DATEADD(YEAR,2,@MinDate);

/* Populate fixed-date holidays for each year */
DECLARE @y INT = YEAR(@MinDate);
WHILE @y <= YEAR(@MaxDate)
BEGIN
    INSERT INTO dbo.HolidayCalendar (HolidayDate, HolidayName)
    SELECT d, n
    FROM (VALUES
        (DATEFROMPARTS(@y,1,1),'Nowy Rok'),
        (DATEFROMPARTS(@y,1,6),'Trzech Króli'),
        (DATEFROMPARTS(@y,5,1),'Święto Pracy'),
        (DATEFROMPARTS(@y,5,3),'Konstytucji 3 Maja'),
        (DATEFROMPARTS(@y,8,15),'Wniebowzięcie NMP'),
        (DATEFROMPARTS(@y,11,1),'Wszystkich Świętych'),
        (DATEFROMPARTS(@y,11,11),'Niepodległości'),
        (DATEFROMPARTS(@y,12,25),'Boże Narodzenie 1. dnia'),
        (DATEFROMPARTS(@y,12,26),'Boże Narodzenie 2. dnia')
    ) AS H(d,n)
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.HolidayCalendar hc
        WHERE hc.HolidayDate = H.d
    );
    SET @y += 1;
END

;WITH Calendar AS (
    SELECT @MinDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY,1,[Date]) FROM Calendar WHERE [Date]<@MaxDate
)
MERGE dbo.[Date] AS tgt
USING (
    SELECT
        d.[Date],
        YEAR(d.[Date])           AS [Year],
        DATENAME(month,d.[Date]) AS [Month],
        MONTH(d.[Date])          AS MonthNo,
        DATENAME(weekday,d.[Date])  AS DayOfWeek,
        DATEPART(weekday,d.[Date])  AS DayOfWeekNo,
        CASE 
            WHEN DATEPART(weekday,d.[Date]) IN (1,7)
              OR hc.HolidayDate IS NOT NULL
            THEN 'No' ELSE 'Yes'
        END                       AS WorkingDay,
        CASE 
            WHEN MONTH(d.[Date]) IN (7,8) THEN 'Summer'
            WHEN MONTH(d.[Date]) = 1     THEN 'Winter'
            ELSE NULL
        END                       AS Vacation,
        hc.HolidayName           AS Holiday,
        bh.HolidayName           AS BeforeHolidayDay
    FROM Calendar d
    LEFT JOIN dbo.HolidayCalendar hc ON hc.HolidayDate = d.[Date]
    LEFT JOIN dbo.HolidayCalendar bh ON bh.HolidayDate = DATEADD(DAY,1,d.[Date])
) AS src
ON tgt.[Date] = src.[Date]
WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        [Date],[Year],[Month],MonthNo,DayOfWeek,DayOfWeekNo,
        WorkingDay,Vacation,Holiday,BeforeHolidayDay
    )
    VALUES (
        src.[Date],src.[Year],src.[Month],src.MonthNo,src.DayOfWeek,
        src.DayOfWeekNo,src.WorkingDay,src.Vacation,src.Holiday,
        src.BeforeHolidayDay
    )
WHEN MATCHED AND (
        tgt.WorkingDay       <> src.WorkingDay OR
        ISNULL(tgt.Vacation,'')          <> ISNULL(src.Vacation,'') OR
        ISNULL(tgt.Holiday,'')           <> ISNULL(src.Holiday,'') OR
        ISNULL(tgt.BeforeHolidayDay,'')  <> ISNULL(src.BeforeHolidayDay,'')
)
THEN
    UPDATE SET
        WorkingDay       = src.WorkingDay,
        Vacation         = src.Vacation,
        Holiday          = src.Holiday,
        BeforeHolidayDay = src.BeforeHolidayDay
OPTION (MAXRECURSION 0);
GO

SELECT * FROM dbo.[Date];