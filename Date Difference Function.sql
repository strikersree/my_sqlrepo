/***** DATE DIFFERENCE FUNCTION***** */
--DESCRIPTION: To find the number of days between two intervals excluding public holidays and weekends
--AUTHOR: SRINIVAS KANNAN
--DATE: 2020-09-03

CREATE OR ALTER FUNCTION dbo.datediff
(@StartDate DATETIME, @EndDate DATETIME)

RETURNS INTEGER

WITH SCHEMABINDING AS

BEGIN 

DECLARE @DayCount INT;
 

SELECT  @DayCount = 

(
    SELECT DATEDIFF(DD, @StartDate, @EndDate)  
    - (SELECT COUNT([Date]) FROM dbo.Dim_FiscalCalendar WHERE [Date] BETWEEN @StartDate AND @EndDate 
    AND IsHoliday = 1)
    - (SELECT COUNT([Date]) FROM dbo.Dim_FiscalCalendar WHERE [Date] BETWEEN @StartDate AND @EndDate 
    AND IsWeekend = 1 )

)

RETURN @DayCount

END;


-- DECLARE @StartDate DATETIME = '2020-09-01',
-- @EndDate DATETIME = '2020-09-30';




--     SELECT DATEDIFF(DD, @StartDate, @EndDate)  
--     - (SELECT COUNT([Date]) FROM dbo.Dim_FiscalCalendar WHERE [Date] BETWEEN @StartDate AND DATEADD(d,1, @EndDate) 
--     AND IsHoliday = 1)
--     - (SELECT COUNT([Date]) FROM dbo.Dim_FiscalCalendar WHERE [Date] BETWEEN @StartDate AND DATEADD(d,1, @EndDate) 
--     AND IsWeekend = 1 )




-- SELECT [dbo].[datediff] (
--    '2020-09-01'
--   ,'2020-09-30')

-- SELECT [dbo].[datediff]('2020-08-01', '2020-08-31');




-- SELECT COUNT([Date]) FROM dbo.Dim_FiscalCalendar WHERE [Date] BETWEEN '2020-09-01' AND '2020-09-30' 
--    AND IsHoliday = 1 
--    AND 
--      IsWeekend = 1
