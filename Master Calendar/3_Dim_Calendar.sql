SELECT * INTO #Temp
FROM dbo.FISCAL_CAL(7); -- Change this starting month according to your need. 


SELECT * INTO dbo.Dim_Calendar
FROM #Temp T
WHERE T.[Fiscal Year] IN ('2019', '2020', '2021')
AND T.[Date] = EOMONTH(T.[Date]);





