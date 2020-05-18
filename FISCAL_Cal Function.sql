
									/* GET FISCAL MONTH AND QUARTER FUNCTION */

--CREATED BY: SRINIVAS KANNAN
--CREATED DATE: 2020-05-18
/*DESCRIPTION: The function fetches Fiscal month and quarter numbers with starting month as input parameter. The function utilizes 
the already created master calendar(dbo.gregorian_calendar). For more info on creating Master calendar, please browse the other
 sql snippets of my repo. */



CREATE OR ALTER  FUNCTION [dbo].[FISCAL_CAL] (@StartMonth INT)

RETURNS TABLE 

AS

RETURN 

(
WITH Temp AS

    ( 
        SELECT c.date AS [DATE], 
            CASE 
            WHEN (c.month - (@StartMonth - 1)) >= 1 
            THEN c.month - (@StartMonth - 1)
            ELSE c.month - (@StartMonth - 1) + 12
        END AS [FISCALMONTH]
        FROM dbo.Gregorian_Calendar c
    )


SELECT T.DATE, T.FISCALMONTH, 
CASE 
WHEN T.FISCALMONTH in (1,2,3) THEN 1
WHEN T.FISCALMONTH in (4,5,6) THEN 2
WHEN T.FISCALMONTH in (7,8,9) THEN 3
ELSE 4 
END AS [FISCALQUARTER]

FROM Temp T

)
GO


