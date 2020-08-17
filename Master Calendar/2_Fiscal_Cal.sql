/* GET FISCAL MONTH AND QUARTER FUNCTION */
--FUNCTION NAME: dbo.Fiscal_Cal(@startmonth)
--CREATED BY: SRINIVAS KANNAN
--CREATED ON: 2020-05-18
--UPDATED BY: SRINIVAS KANNAN
--UPDATED ON: 2020-08-12
/*DESCRIPTION: The function fetches Fiscal Year attributes with starting month as input parameter. The function utilizes 
the existing master calendar(dbo.Dim_MasterCalendar). For more info on creating Master calendar, please browse the other
 sql snippets from my repo. */
CREATE OR ALTER FUNCTION [dbo].[FISCAL_CAL] (@StartMonth INT)
RETURNS TABLE
    WITH SCHEMABINDING
        , ENCRYPTION
AS
RETURN (
        WITH TEMP AS (
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
                FROM dbo.Dim_MasterCalendar c
                )
        SELECT T.DATE [Date]
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
        FROM TEMP T
        )
GO

-- DROP FUNCTION [dbo].[FISCAL_CAL]
-- SELECT DATENAME(month, GETUTCDATE())
-- SELECT FORMAT(GETUTCDATE(), 'MMM')
-- SELECT SUBSTRING(CONVERT(nvarchar(6),getdate(), 112),5,2)
