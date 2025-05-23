USE AdCampaign2DB;
GO

-- Usuñ zale¿ne fakty
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- Wyczyœæ i reseed
DELETE FROM dbo.[Date];
DBCC CHECKIDENT('dbo.[Date]', RESEED, 0);
GO

-- Wstaw daty 2025 z oznaczeniem przerw i œwi¹t
;WITH DateRange AS (
    SELECT CAST('2025-01-01' AS DATE) AS DateValue
    UNION ALL
    SELECT DATEADD(DAY,1,DateValue)
    FROM DateRange
    WHERE DateValue < '2025-12-31'
), 
HolidayList AS (
    SELECT CAST('2025-01-01' AS DATE) AS HolidayDate, 'Nowy Rok'                             AS HolidayName UNION ALL
    SELECT CAST('2025-01-06' AS DATE) AS HolidayDate, 'Œwiêto Trzech Króli'                AS HolidayName UNION ALL
    SELECT CAST('2025-04-21' AS DATE) AS HolidayDate, 'Poniedzia³ek Wielkanocny'           AS HolidayName UNION ALL
    SELECT CAST('2025-05-01' AS DATE) AS HolidayDate, 'Œwiêto Pracy'                       AS HolidayName UNION ALL
    SELECT CAST('2025-05-03' AS DATE) AS HolidayDate, 'Œwiêto Konstytucji 3 Maja'          AS HolidayName UNION ALL
    SELECT CAST('2025-06-09' AS DATE) AS HolidayDate, 'Zes³anie Ducha Œwiêtego'            AS HolidayName UNION ALL
    SELECT CAST('2025-08-15' AS DATE) AS HolidayDate, 'Wniebowziêcie Najœwiêtszej Maryi Panny' AS HolidayName UNION ALL
    SELECT CAST('2025-11-01' AS DATE) AS HolidayDate, 'Wszystkich Œwiêtych'                AS HolidayName UNION ALL
    SELECT CAST('2025-11-11' AS DATE) AS HolidayDate, 'Narodowe Œwiêto Niepodleg³oœci'     AS HolidayName UNION ALL
    SELECT CAST('2025-12-25' AS DATE) AS HolidayDate, 'Bo¿e Narodzenie (I dzieñ)'          AS HolidayName UNION ALL
    SELECT CAST('2025-12-26' AS DATE) AS HolidayDate, 'Bo¿e Narodzenie (II dzieñ)'         AS HolidayName
)
INSERT INTO dbo.[Date]
    ([Date],[Year],Month,MonthNo,DayOfWeek,DayOfWeekNo,
     WorkingDay,Vacation,Holiday,BeforeHolidayDay)
SELECT
    DR.DateValue,
    YEAR(DR.DateValue),
    DATENAME(MONTH,DR.DateValue),
    MONTH(DR.DateValue),
    DATENAME(WEEKDAY,DR.DateValue),
    DATEPART(WEEKDAY,DR.DateValue),
    -- WorkingDay = 'No' dla weekendów lub przerw
    CASE 
      WHEN DATEPART(WEEKDAY,DR.DateValue) IN (1,7)
        OR DR.DateValue BETWEEN '2025-12-25' AND '2025-12-31'
        OR DR.DateValue BETWEEN '2025-01-01' AND '2025-01-06'
      THEN 'No' ELSE 'Yes' END,
    -- Vacation: lato, lub zimowa przerwa (25.12–31.12 oraz 1.01–6.01)
    CASE 
      WHEN MONTH(DR.DateValue) IN (7,8) THEN 'Summer Break'
      WHEN DR.DateValue BETWEEN '2025-12-25' AND '2025-12-31'
        OR DR.DateValue BETWEEN '2025-01-01' AND '2025-01-06'
      THEN 'Winter Break'
      ELSE 'No' END,
    H.HolidayName,
    BH.NextHolidayName
FROM DateRange DR
LEFT JOIN HolidayList H
  ON DR.DateValue = H.HolidayDate
OUTER APPLY (
    SELECT HL.HolidayName AS NextHolidayName
    FROM HolidayList HL
    WHERE HL.HolidayDate = DATEADD(DAY,1,DR.DateValue)
) BH
OPTION (MAXRECURSION 366);
GO

select * from Date