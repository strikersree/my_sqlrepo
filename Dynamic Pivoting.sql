-- AUTHOR : SRINIVAS KANNAN
-- MODIFIED DATE : 06-Jun-2022
-- DESCRIPTION : Performs pivoting in MariaDB and MySQL using store procedure


/* 
mastercolumn - The field that you want to keep / non-pivoted column
pivotcolumn - The field that contain values that will become column headers
tablename - The table from where you want to get the data
agg_col - column being aggregated
agg_func - The aggregate function that you want to apply on the column
filter_col - The field that will be subsitituted in where condition
filter_val - The value to be filtered. 
filter_cond - type of where condition = or <> 
*/

/*
CALL pentaho_dataflows_preprod.dynamic_pivot('account_rep', 'booking_sales_mtn', 'TSG_Cross_Sell', 'SUM', 'local_amount', 
'col_date_year', '2022' , '='); 
*/



CREATE OR REPLACE PROCEDURE `pentaho_dataflows_preprod`.`dynamic_pivot`(IN mastercolumn VARCHAR(1000), IN pivotcolumn VARCHAR(1000), IN tablename VARCHAR(50), IN agg_func CHAR(10), IN agg_col VARCHAR(100), IN filter_col VARCHAR(200), IN filter_val VARCHAR(200), IN filter_cond VARCHAR(10))
BEGIN 
	-- convert pivot column into list
	IF filter_col IS NULL 
	THEN
		EXECUTE IMMEDIATE CONCAT('select GROUP_CONCAT(distinct ',pivotcolumn, ' SEPARATOR ";") , COUNT(distinct `',pivotcolumn,'`) into @cols, @maxx  FROM ',tablename);
	ELSE 
		EXECUTE IMMEDIATE CONCAT('select GROUP_CONCAT(distinct ',pivotcolumn, ' SEPARATOR ";") , COUNT(distinct `',pivotcolumn,'`) into @cols, @maxx  FROM ',tablename, ' WHERE ',filter_col ,' ',filter_cond ,' "',filter_val,'" ;');
	END IF;

	SET @minn = - 1 ;
	SET @factor = -1;
	SET @maxx = @maxx * @factor ;

	EXECUTE IMMEDIATE CONCAT('CREATE TEMPORARY TABLE temp ( `',mastercolumn,'` TEXT NULL )',';');
	
	-- Add pivot columns dynamically 
	WHILE  @minn >= @maxx DO  
	
		EXECUTE IMMEDIATE CONCAT('ALTER TABLE temp ADD COLUMN ', '`', SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`', ' TEXT NULL DEFAULT ''0'' ;');
		SET @minn = @minn - 1 ;	
	
	END WHILE; 

	SET @minn = - 1 ;

--  store pivot data into temp
	WHILE  @minn >= @maxx DO 
	
	IF filter_col IS NULL THEN
	
			IF agg_func = 'COUNT' 
			THEN
				EXECUTE IMMEDIATE CONCAT('INSERT INTO temp( `',mastercolumn,'`,','`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`',')',' SELECT `',mastercolumn,'` ,COUNT(CASE WHEN `',pivotcolumn,'` = "',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'"',' THEN 1 ELSE NULL END) AS ', '`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`',' FROM ',tablename,' GROUP BY `',mastercolumn,'`;');
				SET @minn = @minn - 1 ;
			ELSE 
				EXECUTE IMMEDIATE CONCAT('INSERT INTO temp( `',mastercolumn,'`,','`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`',')',' SELECT `',mastercolumn,'` ,CASE WHEN `',pivotcolumn,'` = "',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'"',' THEN ',agg_func,'(',agg_col,') ELSE NULL END AS ', '`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`',' FROM ',tablename,' GROUP BY `',mastercolumn,'`;');
				SET @minn = @minn - 1 ;
			END IF ;
	ELSE 
			IF agg_func = 'COUNT' 
			THEN
				EXECUTE IMMEDIATE CONCAT('INSERT INTO temp( `',mastercolumn,'`,','`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`',')',' SELECT `',mastercolumn,'` ,COUNT(CASE WHEN `',pivotcolumn,'` = "',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'"',' THEN 1 ELSE NULL END) AS ', '`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`',' FROM ',tablename,' WHERE ',filter_col,' ', filter_cond,' "',filter_val,'"', ' GROUP BY `',mastercolumn,'`;');
				SET @minn = @minn - 1 ;
			ELSE 
				EXECUTE IMMEDIATE CONCAT('INSERT INTO temp( `',mastercolumn,'`,','`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'`',')',' SELECT `',mastercolumn,'` ,CASE WHEN `',pivotcolumn,'` = "',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1),'"',' THEN ',agg_func,'(',agg_col,') ELSE NULL END AS ', '`',SUBSTRING_INDEX(SUBSTRING_INDEX(@cols, ';', @minn), ';', 1), '`',' FROM ',tablename, ' WHERE ',filter_col,' ',filter_cond,' "',filter_val,'"', ' GROUP BY `',mastercolumn,'`;');
				SET @minn = @minn - 1 ;
			END IF ;
	END IF ;
		
	END WHILE;

	DROP TABLE IF EXISTS pivot_results ;

	CREATE OR REPLACE TABLE pivot_results AS (SELECT * FROM temp WHERE 1=2);

	SET @minn = - 1 ;

	SET @groupcolumn = '';
	
	SET @groupquery = CONCAT('SELECT distinct `',mastercolumn,'` ,');

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









