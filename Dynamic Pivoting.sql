
-- AUTHOR : SRINIVAS KANNAN
-- MODIFIED DATE : 06-Jun-2022
-- DESCRIPTION : Performs pivoting in MariaDB and MySQL based on user inputs


/* 
mastercolumn - The field that you want to keep / non-pivoted column
pivotcolumn - The field that contain values that will become column headers
tablename - The table from where you want to get the data
agg_col - column being aggregated
agg_func - The aggregate function that you want to apply on the column
*/

/*
CALL dynamic_pivot('account_rep','booking_sales_mtn','TSG_Cross_Sell', 'SUM','local_amount');
*/

CREATE OR REPLACE PROCEDURE `dynamic_pivot`(IN mastercolumn VARCHAR(70), IN pivotcolumn VARCHAR(100), IN tablename VARCHAR(50), IN agg_func CHAR(10), IN agg_col VARCHAR(20) )

BEGIN 
	-- convert pivot column into list
	EXECUTE IMMEDIATE CONCAT('select GROUP_CONCAT(distinct ',pivotcolumn, ' SEPARATOR ";") into @cols FROM ',tablename);

	EXECUTE IMMEDIATE CONCAT('select COUNT(distinct `',pivotcolumn,'`) INTO @maxx FROM ',tablename,' ;');

	SET @minn = - 1 ;
	SET @factor = -1;
	SET @maxx = @maxx * @factor ;

	EXECUTE IMMEDIATE CONCAT('CREATE TEMPORARY TABLE temp ( `',mastercolumn,'` VARCHAR(100) NULL )',';');
	
	-- Add pivot columns dynamically 
	WHILE  @minn >= @maxx DO  
	
		EXECUTE IMMEDIATE CONCAT('ALTER TABLE temp ADD COLUMN ', '`', SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`', ' VARCHAR(200) NULL DEFAULT ''0'' ;');
		SET @minn = @minn - 1 ;	
	
	END WHILE; 

	SET @minn = - 1 ;

--  store pivot data into temp
	WHILE  @minn >= @maxx DO 
	
		IF agg_func = 'COUNT' 
		THEN
			EXECUTE IMMEDIATE CONCAT('INSERT INTO temp( `',mastercolumn,'`,','`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`',')',' SELECT distinct `',mastercolumn,'` ,COUNT(CASE WHEN `',pivotcolumn,'` = "',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'"',' THEN 1 ELSE NULL END) AS ', '`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`',' FROM ',tablename,' GROUP BY `',mastercolumn,'`;');
			SET @minn = @minn - 1 ;
		ELSE 
			EXECUTE IMMEDIATE CONCAT('INSERT INTO temp( `',mastercolumn,'`,','`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`',')',' SELECT distinct `',mastercolumn,'` ,CASE WHEN `',pivotcolumn,'` = "',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'"',' THEN ',agg_func,'(',agg_col,') ELSE NULL END AS ', '`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`',' FROM ',tablename,' GROUP BY `',mastercolumn,'`;');
			SET @minn = @minn - 1 ;
		END IF ;
	
	END WHILE;

	CREATE TEMPORARY TABLE pivot_results AS (SELECT * FROM temp WHERE 1=2);

	SET @minn = - 1 ;

	SET @groupcolumn = '';
	
	SET @groupquery = CONCAT('SELECT `',mastercolumn,'` ,');

	WHILE  @minn >= @maxx DO 
		IF @minn = @maxx THEN 
			SET @groupcolumn = CONCAT('MAX(`', SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`) AS `',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'` FROM temp GROUP BY `',mastercolumn, '`;') ;
		ELSE 
			SET @groupcolumn = CONCAT('MAX(`', SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`) AS `',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`,') ;
		END IF ;
		SET @groupquery = CONCAT(@groupquery,@groupcolumn) ;
		SET @minn = @minn - 1 ;
	END WHILE; 

	EXECUTE IMMEDIATE CONCAT('INSERT INTO pivot_results ', @groupquery); 

	EXECUTE IMMEDIATE 'DROP TABLE temp';

	EXECUTE IMMEDIATE 'SELECT * FROM pivot_results ;';


END






