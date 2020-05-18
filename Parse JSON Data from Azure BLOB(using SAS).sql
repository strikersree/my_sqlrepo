														/* PARSE JSON BLOB DATA FROm AZURE USING SHARED ACCESS SIGNATURE*/


--CREATED BY : SRINIVAS KANNAN
--CREATED DATE: 2020-APR-20



--STEP 1: Create a 'Storage Account' in Azure Portal 
--STEP 2: Create a 'Container' Inside the 'Storage Account'
--STEP 3: Upload the desired JSON File into the Container
--STEP 4: Modify the Container Permissions to Read and Write. 
--STEP 5: Go to Json File Properties and Generate SAS(Shared Access Signature)

/*FOLLOW THE BELOW STEPS ONCE THE SAS IS READY*/


--STEP 6: Create Shared Access Signature 
CREATE DATABASE SCOPED CREDENTIAL [Azure-Storage-Credentials]
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'sp=rw&st=2020-04-20T16:04:56Z&se=2020-04-21T00:04:56Z&spr=https&sv=2019-02-02&sr=b&sig=ufM35fJDl%2BfxiMPG5Qt2YFq163bY6rtImjsaHi9nL5U%3D'
--The secret key is the SAS you generate from Azure Portal 


--STEP 7: Create Master Encryption Key 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Your Password';


--STEP 8:
--Upload JSON into your Azure Blob Storage And fetch the Location URL.
--Create External Data Source
CREATE EXTERNAL DATA SOURCE 
[Azure-Storage]
WITH
(
TYPE = BLOB_STORAGE,
LOCATION= 'https://storageforblob.blob.core.windows.net',
CREDENTIAL = [Azure-Storage-Credentials]
)

--DROP EXTERNAL DATA SOURCE [Azure-Storage]


--STEP 9: PARSE JSON DATA
WITH JSONFROMBLOB AS
(
	SELECT CAST(Bulkcolumn AS NVARCHAR(MAX)) AS JSONDATA

	FROM 

	OPENROWSET(BULK 'jsonbcontainer/pm_project_01.json', DATA_SOURCE = 'Azure-Storage', SINGLE_CLOB) AS Azure_BLOB
)

SELECT Shadow,
Opex_ForeCast_Cost,
Phase_Type,
Upon_Reject,
sys_updated_on,
Forecast_Cost,
Discount_Rate,
Time_Card_Preference
FROM 
JSONFROMBLOB
CROSS APPLY
OPENJSON(JSONFROMBLOB.JSONDATA, '$.result')
 
WITH 
(
Shadow nvarchar(20) '$.shadow',
Opex_ForeCast_Cost nvarchar(20) '$.opex_forecast_cost',
Phase_Type nvarchar(20) '$.phase_type',
Upon_Reject nvarchar(20) '$.upon_reject',
sys_updated_on datetime2 '$.sys_updated_on',
Forecast_Cost nvarchar(20) '$.forecast_cost',
Discount_Rate nvarchar(20) '$.discount_rate',
Time_Card_Preference nvarchar(20) '$.time_card_preference'
)



--Method 2: Insert Json data into the table and then parse
CREATE TABLE dbo.[JSON]
(Val NVARCHAR(MAX) NOT NULL)

BULK INSERT dbo.[JSON]
FROM 'pm_project_01.json'
WITH (DATA_SOURCE = 'Azure-Storage');



https://storageforblob.blob.core.windows.net/jsonbcontainer/pm_project_01.json
