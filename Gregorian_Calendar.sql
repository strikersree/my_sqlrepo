/*********************GREGORIAN CALENDAR*************/
--TABLE NAME: dbo.Gregorian_Calendar
--CREATED ON: 2019-11-03
--CREATED BY: SRINIVAS KANNAN
--UPDATED ON:
--UPDATED BY:
/*DESCRIPTION: This is a generic set of steps to create a calendar table for any range of years in SQL Server.  */
DECLARE @StartDate DATE = '20190701'
    , @NumberOfYears INT = 20

--Setting date locale/format to US region
SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

CREATE TABLE dbo.Gregorian_Calendar (
    [date] DATE PRIMARY KEY
    , [day] AS DATEPART(DAY, [date])
    , [month] AS DATEPART(MONTH, [date])
    , FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0))
    , [MonthName] AS DATENAME(MONTH, [date])
    , [week] AS DATEPART(WEEK, [date])
    , [DayOfWeek] AS DATEPART(WEEKDAY, [date])
    , [quarter] AS DATEPART(QUARTER, [date])
    , [year] AS DATEPART(YEAR, [date])
    );

INSERT dbo.Gregorian_Calendar ([date])
SELECT d
FROM (
    SELECT d = DATEADD(DAY, rn - 1, @StartDate)
    FROM (
        SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) rn = ROW_NUMBER() OVER (
                ORDER BY s1.[object_id]
                )
        FROM sys.all_objects AS s1
        CROSS JOIN sys.all_objects AS s2
        ORDER BY s1.[object_id]
        ) AS x
    ) AS y;

SELECT *
FROM dbo.Gregorian_Calendar;
    -- DROP TABLE dbo.Gregorian_Calendar
