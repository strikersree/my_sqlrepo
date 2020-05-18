--CREATED BY: Srinivas Kannan
--CREATED DATE: 05-MAY-2020

/* DESCRIPTION: This function replicates the same functionality of CHARINDEX() function with a added advanatage of 
getting the nTH occurances of a string. The function is generic and can be used across any SQL versions. 
*/

CREATE FUNCTION dbo.CHARINDEXPLUS 
(
@Char NVARCHAR(100)
,@STRING NVARCHAR(MAX)
,@POS INT
)
RETURNS INT

WITH SCHEMABINDING

AS 

BEGIN	
	DECLARE @Index AS INT = 1

	WHILE @POS <> 0
	BEGIN 
		SET @Index = CHARINDEX(@Char,@String,@Index + 1)
		SET @POS -= 1
	END

	RETURN @Index

END 


SET STATISTICS IO, TIME ON;


