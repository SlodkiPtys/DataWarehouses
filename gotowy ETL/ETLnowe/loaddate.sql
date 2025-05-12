USE AdCampaign2DB;
GO

-- Usu� zale�ne fakty
DELETE FROM dbo.InterestLog;
DELETE FROM dbo.Views_Clicks;
DELETE FROM dbo.Conduct_a_campaign;
GO

-- Wyczy�� i reseed
DELETE FROM dbo.[Date];
DBCC CHECKIDENT('dbo.[Date]', RESEED, 0);
GO

-- Wstaw daty 2025 z oznaczeniem przerw i �wi�t
;WITH DateRange AS (
    SELECT CAST('2025-01-01' AS DATE) AS DateValue
    UNION ALL
    SELECT DATEADD(DAY,1,DateValue)
    FROM DateRange
    WHERE DateValue < '2025-12-31'
), 
HolidayList AS (
    SELECT CAST('2025-01-01' AS DATE) AS HolidayDate, 'Nowy Rok'                             AS HolidayName UNION ALL
    SELECT CAST('2025-01-06' AS DATE) AS HolidayDate, '�wi�to Trzech Kr�li'                AS HolidayName UNION ALL
    SELECT CAST('2025-04-21' AS DATE) AS HolidayDate, 'Poniedzia�ek Wielkanocny'           AS HolidayName UNION ALL
    SELECT CAST('2025-05-01' AS DATE) AS HolidayDate, '�wi�to Pracy'                       AS HolidayName UNION ALL
    SELECT CAST('2025-05-03' AS DATE) AS HolidayDate, '�wi�to Konstytucji 3 Maja'          AS HolidayName UNION ALL
    SELECT CAST('2025-06-09' AS DATE) AS HolidayDate, 'Zes�anie Ducha �wi�tego'            AS HolidayName UNION ALL
    SELECT CAST('2025-08-15' AS DATE) AS HolidayDate, 'Wniebowzi�cie Naj�wi�tszej Maryi Panny' AS HolidayName UNION ALL
    SELECT CAST('2025-11-01' AS DATE) AS HolidayDate, 'Wszystkich �wi�tych'                AS HolidayName UNION ALL
    SELECT CAST('2025-11-11' AS DATE) AS HolidayDate, 'Narodowe �wi�to Niepodleg�o�ci'     AS HolidayName UNION ALL
    SELECT CAST('2025-12-25' AS DATE) AS HolidayDate, 'Bo�e Narodzenie (I dzie�)'          AS HolidayName UNION ALL
    SELECT CAST('2025-12-26' AS DATE) AS HolidayDate, 'Bo�e Narodzenie (II dzie�)'         AS HolidayName
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
    -- WorkingDay = 'No' dla weekend�w lub przerw
    CASE 
      WHEN DATEPART(WEEKDAY,DR.DateValue) IN (1,7)
        OR DR.DateValue BETWEEN '2025-12-25' AND '2025-12-31'
        OR DR.DateValue BETWEEN '2025-01-01' AND '2025-01-06'
      THEN 'No' ELSE 'Yes' END,
    -- Vacation: lato, lub zimowa przerwa (25.12�31.12 oraz 1.01�6.01)
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