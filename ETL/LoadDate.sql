/*  File:     LoadDate.sql
    Purpose:  Populate / maintain the Date dimension (dbo.Date)
*/
USE AdCampaign2DB;
GO

DECLARE @MinDate DATE, @MaxDate DATE;

/* Pull the smallest / largest date we might ever need */
SELECT  @MinDate = MIN(D), 
        @MaxDate = MAX(D)
FROM (
        SELECT MIN([Timestamp])   AS D, MAX([Timestamp])   AS D FROM DataWarehouses.dbo.ViewsClicks
        UNION ALL
        SELECT MIN([Start Date])  AS D, MAX([End Date])    AS D FROM DataWarehouses.dbo.AdCampaign
     ) AS t;

/* Fall‑back range if staging is still empty */
IF @MinDate IS NULL SET @MinDate = '2025-01-01';
IF @MaxDate IS NULL SET @MaxDate = DATEADD(YEAR, 2, @MinDate);

/* Calendar spine */
;WITH cte AS (
    SELECT @MinDate AS [Date]
    UNION ALL
    SELECT DATEADD(DAY, 1, [Date])
    FROM   cte
    WHERE  [Date] < @MaxDate
)
MERGE dbo.[Date] AS tgt
USING (
    SELECT  d.[Date],
            YEAR(d.[Date])                              AS [Year],
            DATENAME(month , d.[Date])                  AS [Month],
            MONTH(d.[Date])                             AS MonthNo,
            DATENAME(weekday, d.[Date])                 AS DayOfWeek,
            DATEPART(weekday, d.[Date])                 AS DayOfWeekNo,
            CASE WHEN DATEPART(weekday,d.[Date]) IN (1,7) THEN 'No' ELSE 'Yes' END  AS WorkingDay,
            NULL  AS Vacation,              -- TODO: plug‑in holiday calendar
            NULL  AS Holiday,
            NULL  AS BeforeHolidayDay
    FROM   cte d
) AS src
ON  tgt.[Date] = src.[Date]
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Date], Year, Month, MonthNo, DayOfWeek, DayOfWeekNo, WorkingDay,
            Vacation, Holiday, BeforeHolidayDay)
    VALUES (src.[Date], src.[Year], src.[Month], src.[MonthNo], src.DayOfWeek,
            src.DayOfWeekNo, src.WorkingDay, src.Vacation, src.Holiday, src.BeforeHolidayDay)
OPTION (MAXRECURSION 0);