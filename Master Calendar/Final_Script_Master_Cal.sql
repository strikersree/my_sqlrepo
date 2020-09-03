-- CREATE OR ALTER PROCEDURE dbo.USP_GetFiscalCal ( @StartMonth AS INT)
-- AS 
DECLARE @StartDate DATE = '20180701'
    , @NumberOfYears INT = 5
    , @StartMonth INT = 7

--Setting date locale/format to US region
SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

CREATE TABLE #temp (
    [date] DATE PRIMARY KEY
    , [day] AS DATEPART(DAY, [date])
    , [month] AS DATEPART(MONTH, [date])
    , FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0))
    , [MonthName] AS DATENAME(MONTH, [date])
    , [week] AS DATEPART(WEEK, [date])
    , [DayOfWeek] AS DATEPART(WEEKDAY, [date])
    , [quarter] AS DATEPART(QUARTER, [date])
    , [year] AS DATEPART(YEAR, [date])
    , [EOM] AS EOMONTH([date])
    -- , [IsWeekend] AS CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END)
    , [IsHoliday] AS CONVERT(BIT, 0)
    -- , [MonthNameAbbr] AS CONVERT(VARCHAR(3), [MonthName])
    );

INSERT #temp ([date])
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
    , CONVERT(BIT, CASE 
            WHEN [DayOfWeek] IN (1, 7)
                THEN 1
            ELSE 0
            END) AS [IsWeekend]
    , CONVERT(VARCHAR(3), [MonthName]) AS [MonthNameAbbr]
INTO #temp2
FROM #temp;

WITH TEMP_CTE
AS (
    SELECT c.DATE AS [DATE]
        , CASE 
            WHEN (MONTH(c.DATE) - (@StartMonth - 1)) >= 1
                THEN MONTH(c.DATE) - (@StartMonth - 1)
            ELSE MONTH(c.DATE) - (@StartMonth - 1) + 12
            END AS [FISCALMONTH]
        , CASE 
            WHEN (MONTH(c.DATE) - (@StartMonth - 1)) >= 1
                THEN c.YEAR + 1
            ELSE c.YEAR
            END AS [FISCALYEAR]
        , [EOM]
        , [IsHoliday]
        , [IsWeekend]
        , [MonthNameAbbr]
        , [week]
    FROM #temp2 c
    ),

 TEMP_CTE2
AS 
(   
SELECT 
--CASE WHEN 
ROW_NUMBER() OVER (PARTITION BY T.FISCALYEAR ORDER BY T.DATE) 
--END 
AS [ROW NO]
,T.DATE [Date]
    , CASE 
        WHEN T.week IN (1, 2, 3, 4, 5, 6, 7, 8, 9)
            THEN CONCAT (
                    T.FISCALYEAR
                    , '-'
                    , '0', 
                    T.week
                    )
        ELSE CONCAT (
                T.FISCALYEAR
                , '-'
                ,T.week
                )
        END AS [Week]
    , CASE 
        WHEN T.FISCALMONTH IN (10, 11, 12)
            THEN CONCAT (
                    T.FISCALYEAR
                    , '-'
                    , T.FISCALMONTH
                    )
        ELSE CONCAT (
                T.FISCALYEAR
                , '-'
                , '0'
                , T.FISCALMONTH
                )
        END AS [Fiscal Month Num]
    , CONCAT (
        CONVERT(VARCHAR(1000), T.FISCALYEAR)
        , '-'
        , FORMAT(T.DATE, 'MMM')
        ) [Fiscal Month]
    , CASE 
        WHEN T.FISCALMONTH IN (1, 2, 3)
            THEN CONCAT (
                    T.FISCALYEAR
                    , '-'
                    , 'Q1'
                    )
        WHEN T.FISCALMONTH IN (4, 5, 6)
            THEN CONCAT (
                    T.FISCALYEAR
                    , '-'
                    , 'Q2'
                    )
        WHEN T.FISCALMONTH IN (7, 8, 9)
            THEN CONCAT (
                    T.FISCALYEAR
                    , '-'
                    , 'Q3'
                    )
        ELSE CONCAT (
                T.FISCALYEAR
                , '-'
                , 'Q4'
                )
        END AS [Fiscal Quarter]
    , T.FISCALYEAR [Fiscal Year]
    , T.[EOM] [End Of Month]
    , CASE 
        -- New Year's Day
        WHEN DATEPART(MM, T.DATE) = 1
            AND DATEPART(DD, T.DATE) = 1
            AND DATEPART(DW, T.DATE) IN (2, 3, 4, 5, 6)
            THEN '1'
        WHEN DATEPART(MM, T.DATE) = 12
            AND DATEPART(DD, T.DATE) = 31
            AND DATEPART(DW, T.DATE) = 6
            THEN '1'
        WHEN DATEPART(MM, T.DATE) = 1
            AND DATEPART(DD, T.DATE) = 2
            AND DATEPART(DW, T.DATE) = 2
            THEN '1'
                -- Memorial Day (last Monday in May)
        WHEN DATEPART(MM, T.DATE) = 5
            AND DATEPART(DD, T.DATE) BETWEEN 25 AND 31
            AND DATEPART(DW, T.DATE) = 2
            THEN '1'
                -- Independence Day
        WHEN DATEPART(MM, T.DATE) = 7
            AND DATEPART(DD, T.DATE) = 4
            AND DATEPART(DW, T.DATE) IN (2, 3, 4, 5, 6)
            THEN '1'
        WHEN DATEPART(MM, T.DATE) = 7
            AND DATEPART(DD, T.DATE) = 3
            AND DATEPART(DW, T.DATE) = 6
            THEN '1'
        WHEN DATEPART(MM, T.DATE) = 7
            AND DATEPART(DD, T.DATE) = 5
            AND DATEPART(DW, T.DATE) = 2
            THEN '1'
                -- Labor Day (first Monday in September)
        WHEN DATEPART(MM, T.DATE) = 9
            AND DATEPART(DD, T.DATE) BETWEEN 1 AND 7
            AND DATEPART(DW, T.DATE) = 2
            THEN '1'
                -- Thanksgiving Day (fourth Thursday in November)
        WHEN DATEPART(MM, T.DATE) = 11
            AND DATEPART(DD, T.DATE) BETWEEN 22 AND 28
            AND DATEPART(DW, T.DATE) = 5
            THEN '1'
                -- Black Friday (day after Thanksgiving)
        WHEN DATEPART(MM, T.DATE) = 11
            AND DATEPART(DD, T.DATE) BETWEEN 23 AND 29
            AND DATEPART(DW, T.DATE) = 6
            THEN '1'
                -- Christmas Day
        WHEN DATEPART(MM, T.DATE) = 12
            AND DATEPART(DD, T.DATE) = 25
            AND DATEPART(DW, T.DATE) IN (2, 3, 4, 5, 6)
            THEN '1'
        WHEN DATEPART(MM, T.DATE) = 12
            AND DATEPART(DD, T.DATE) = 24
            AND DATEPART(DW, T.DATE) = 6
            THEN '1'
        WHEN DATEPART(MM, T.DATE) = 12
            AND DATEPART(DD, T.DATE) = 26
            AND DATEPART(DW, T.DATE) = 2
            THEN '1'
        ELSE '0'
        END AS [IsHoliday]
    , T.[IsWeekend]
--, T.[MonthNameAbbr]

--INTO dbo.Dim_MasterCalendar
FROM TEMP_CTE T
)

, TEMP_CTE3
AS 
(
SELECT [Date] 
,CASE 
WHEN [ROW NO] % 7 = 0 THEN [ROW NO] / 7
ELSE [ROW NO] / 7 + 1
END AS [Week No]
--,Week
,[Fiscal Month Num]
,[Fiscal Month]
,[Fiscal Quarter]
,[Fiscal Year]
,[End of Month]
,[IsHoliday]
,[IsWeekend]
FROM TEMP_CTE2
),

FINAL_CTE
AS
(

SELECT [Date] 
,CASE 
WHEN [Week No] = 53 THEN 52
ELSE [Week No]
END AS [Week]
--,Week
,[Fiscal Month Num]
,[Fiscal Month]
,[Fiscal Quarter]
,[Fiscal Year]
,[End of Month]
,[IsHoliday]
,[IsWeekend]
FROM TEMP_CTE3
)

SELECT [Date] 
,CASE 
WHEN [Week] in (1, 2, 3, 4, 5, 6, 7, 8, 9) THEN CONCAT([Fiscal Year], '-', '0', [Week])
ELSE CONCAT([Fiscal Year],'-', [Week])
END AS [Fiscal Week No]
--,Week
,[Fiscal Month Num]
,[Fiscal Month]
,[Fiscal Quarter]
,[Fiscal Year]
,[End of Month]
,[IsHoliday]
,[IsWeekend]
INTO  dbo.Dim_FiscalCalendar--dbo.Dim_MasterCalendar
FROM FINAL_CTE;

GO

-- SELECT * FROM dbo.Dim_MasterCalendar WHERE IsHoliday = 1
--         EXEC dbo.USP_GetFiscalCal @StartMonth = 7
-- DROP TABLE Dim_MasterCalendar;
-- DROP FUNCTION FISCAL_CAL;
-- DROP PROCEDURE USP_GetFiscalCal
-- SELECT DATEPART(WEEK, GETUTCDATE())

SELECT * FROM dbo.Dim_FiscalCalendar


SELECT * FROM #Target