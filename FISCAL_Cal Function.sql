/* GET FISCAL MONTH AND QUARTER FUNCTION */
--CREATED BY: SRINIVAS KANNAN
--CREATED DATE: 2020-05-18
/*DESCRIPTION: The function fetches Fiscal month and quarter numbers with starting month as input parameter. The function utilizes 
the existing master calendar(dbo.gregorian_calendar). For more info on creating Master calendar, please browse the other
 sql snippets from my repo. */
CREATE
    OR

ALTER FUNCTION [dbo].[FISCAL_CAL] (@StartMonth INT)
RETURNS TABLE
    WITH SCHEMABINDING
        , ENCRYPTION
AS
RETURN (
        WITH TEMP AS (
                SELECT c.DATE AS [DATE]
                    , CASE 
                        WHEN (c.month - (@StartMonth - 1)) >= 1
                            THEN c.month - (@StartMonth - 1)
                        ELSE c.month - (@StartMonth - 1) + 12
                        END AS [FISCALMONTH]
                    , CASE 
                        WHEN (c.month - (@StartMonth - 1)) >= 1
                            THEN c.YEAR + 1
                        ELSE c.YEAR
                        END AS [FISCALYEAR]
                FROM dbo.Gregorian_Calendar c
                )
        SELECT T.DATE
            , T.FISCALMONTH
            , CASE 
                WHEN T.FISCALMONTH IN (1, 2, 3)
                    THEN 1
                WHEN T.FISCALMONTH IN (4, 5, 6)
                    THEN 2
                WHEN T.FISCALMONTH IN (7, 8, 9)
                    THEN 3
                ELSE 4
                END AS [FISCALQUARTER]
            , T.[FISCALYEAR]
        FROM TEMP T
        )
GO


