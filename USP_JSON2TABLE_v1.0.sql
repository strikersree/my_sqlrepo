
--Created Date: 2020-09-05
--Created by: Srinivas Kannan

/*Description: The Following procedure parses the JSON data into SQL Columns without using FOR JSON function
This can be really helpful for SQL Server versions where the compatability level is less than 130. 
The proc uses multiple CTEs and built in CHARINDEX and SUBSTRING functions to extract the required fields. Also, it uses a user defined function names CHARINDEXPlus to extract the nTH 
Occurences of a particular string in JSON.  */


ALTER PROCEDURE usp_JSON2TABLE 
@JSON NVARCHAR(MAX)

AS

SET NOCOUNT, XACT_ABORT ON;

BEGIN 

	BEGIN TRY

	
	WITH [Parse]
		AS
		(
		SELECT 'transactionType":"' [TransactionType], 
		'transactionSource":"' [Source],
		'uniqueID":"' [UniqueID],
		'title":"' [Title],
		'deliveryMethod":"' [DeliveryMethod],
		'programType":"' [ProgramType],
		'isOldQAS":"' [isOldQAS],
		'"type":"' [Credit_Type],
		'"unitAmt":"' [Credit_UnitAmt],
		'provider":"' [provider],
		'sponsorID":"' [SponsorID],
		'jurisdiction":[' [Jurisdiction],
		'"qid":"' [NASBAQuestionID],
		'"value":"' [NASBAValue],
		'requestType":"' [RequestType],
		'definitionStatus":"' [DefinitionStatus]

		),

		StringSearch AS
		(
		SELECT 
		CHARINDEX(p.[TransactionType], @JSON) AS [Start],
		LEN(p.[TransactionType]) AS [Length],

		CHARINDEX(p.[Source], @JSON) AS [Start_1],
		LEN(p.[Source]) AS [Length_1],

		CHARINDEX(p.[UniqueID], @JSON) AS [Start_2],
		LEN(p.[UniqueID]) AS [Length_2],

		CHARINDEX(p.[Title], @JSON) AS [Start_3],
		LEN(p.[Title]) AS [Length_3],

		CHARINDEX(p.[DeliveryMethod], @JSON) AS [Start_4],
		LEN(p.[DeliveryMethod]) AS [Length_4],

		CHARINDEX(p.[ProgramType], @JSON) AS [Start_5],
		LEN(p.[ProgramType]) AS [Length_5],

		CHARINDEX(p.[isOldQAS], @JSON) AS [Start_6],
		LEN(p.[isOldQAS]) AS [Length_6],

		--using udf to find the starting position and length of the nested elements 
		--Start Credit and Types
		dbo.CHARINDEXPLUS(p.[Credit_Type] COLLATE Latin1_General_CS_AS, @JSON,1) AS [Start_7],
		LEN(p.[Credit_Type]) AS [Length_7],

		dbo.CHARINDEXPLUS(p.[Credit_UnitAmt], @JSON,1) AS [Start_8],
		LEN(p.[Credit_UnitAmt]) AS [Length_8],

		dbo.CHARINDEXPLUS(p.[Credit_Type] COLLATE Latin1_General_CS_AS, @JSON,2) AS [Start_9],
		LEN(p.[Credit_Type]) AS [Length_9],

		dbo.CHARINDEXPLUS(p.[Credit_UnitAmt], @JSON,2) AS [Start_10],
		LEN(p.[Credit_UnitAmt]) AS [Length_10],

		dbo.CHARINDEXPLUS(p.[Credit_Type] COLLATE Latin1_General_CS_AS, @JSON,3) AS [Start_11],
		LEN(p.[Credit_Type]) AS [Length_11],

		dbo.CHARINDEXPLUS(p.[Credit_UnitAmt], @JSON,3) AS [Start_12],
		LEN(p.[Credit_UnitAmt]) AS [Length_12],
		--Ends

		CHARINDEX(p.[provider], @JSON) AS [Start_13],
		LEN(p.[provider]) AS [Length_13],

		CHARINDEX(p.[SponsorID], @JSON) AS [Start_14],
		LEN(p.[SponsorID]) AS [Length_14],

		CHARINDEX(p.[Jurisdiction], @JSON) AS [Start_15],
		LEN(p.[Jurisdiction]) AS [Length_15],


		--Parsing NASBA Questions & Values 
		dbo.CHARINDEXPLUS(p.[NASBAQuestionID] COLLATE Latin1_General_CS_AS, @JSON, 1) AS [Start_16],
		LEN(p.[NASBAQuestionID]) AS [Length_16],

		dbo.CHARINDEXPLUS(p.[NASBAValue] COLLATE Latin1_General_CS_AS, @JSON, 1) AS [Start_17],
		LEN(p.[NASBAValue]) AS [Length_17],

		dbo.CHARINDEXPLUS(p.[NASBAQuestionID] COLLATE Latin1_General_CS_AS, @JSON, 2) AS [Start_18],
		LEN(p.[NASBAQuestionID]) AS [Length_18],

		dbo.CHARINDEXPLUS(p.[NASBAValue] COLLATE Latin1_General_CS_AS, @JSON, 2) AS [Start_19],
		LEN(p.[NASBAValue]) AS [Length_19],

		CHARINDEX(p.[RequestType], @JSON) AS [Start_20],
		LEN(p.[RequestType]) AS [Length_20],

		CHARINDEX(p.[DefinitionStatus], @JSON) AS [Start_21],
		LEN(p.[DefinitionStatus]) AS [Length_21]

		FROM [Parse] p
		)


		SELECT CASE S.[Start] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start] + S.[Length]), CHARINDEX('"', @JSON, S.[Start] + S.[Length]) - (S.[Start] + S.[Length])
					) 
					END AS [TransactionType],


				CASE S.[Start_1] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_1] + S.[Length_1]), CHARINDEX('"', @JSON, S.[Start_1] + S.[Length_1]) - (S.[Start_1] + S.[Length_1])
					) 
					END AS [Source],

		
				CASE S.[Start_2] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_2] + S.[Length_2]), CHARINDEX('"', @JSON, S.[Start_2] + S.[Length_2]) - (S.[Start_2] + S.[Length_2])
					) 
					END AS [UniqueID],

		
				CASE S.[Start_3] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_3] + S.[Length_3]), CHARINDEX('"', @JSON, S.[Start_3] + S.[Length_3]) - (S.[Start_3] + S.[Length_3])
					) 
					END AS [Title],

		
				CASE S.[Start_4] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_4] + S.[Length_4]), CHARINDEX('"', @JSON, S.[Start_4] + S.[Length_4]) - (S.[Start_4] + S.[Length_4])
					) 
					END AS [DeliveryMethod],

		
				CASE S.[Start_5] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_5] + S.[Length_5]), CHARINDEX('"', @JSON, S.[Start_5] + S.[Length_5]) - (S.[Start_5] + S.[Length_5])
					) 
					END AS [ProgramType],

		
				CASE S.[Start_6] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_6] + S.[Length_6]), CHARINDEX('"', @JSON, S.[Start_6] + S.[Length_6]) - (S.[Start_6] + S.[Length_6])
					) 
					END AS [isOldQAS],

		
				CASE S.[Start_7] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_7] + S.[Length_7]), CHARINDEX('"', @JSON, S.[Start_7] + S.[Length_7]) - (S.[Start_7] + S.[Length_7])
					) 
					END AS [CreditType_1],

		
				CASE S.[Start_8] 
					WHEN 0 THEN NULL
					ELSE
					CONVERT(DECIMAL(19,2),
					SUBSTRING(@JSON, (S.[Start_8] + S.[Length_8]), CHARINDEX('"', @JSON, S.[Start_8] + S.[Length_8]) - (S.[Start_8] + S.[Length_8])
					) )
					END AS [Credit_UnitAmt_1],

				CASE S.[Start_9] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_9] + S.[Length_9]), CHARINDEX('"', @JSON, S.[Start_9] + S.[Length_9]) - (S.[Start_9] + S.[Length_9])
					) 
					END AS [CreditType_2],

		
				CASE S.[Start_10] 
					WHEN 0 THEN NULL
					ELSE
					CONVERT(DECIMAL(19,2),
					SUBSTRING(@JSON, (S.[Start_10] + S.[Length_10]), CHARINDEX('"', @JSON, S.[Start_10] + S.[Length_10]) - (S.[Start_10] + S.[Length_10])
					) )
					END AS [Credit_UnitAmt_2],

				CASE S.[Start_11] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_11] + S.[Length_11]), CHARINDEX('"', @JSON, S.[Start_11] + S.[Length_11]) - (S.[Start_11] + S.[Length_11])
					) 
					END AS [CreditType_3],

		
				CASE S.[Start_12] 
					WHEN 0 THEN NULL
					ELSE
					CONVERT(DECIMAL(19,2),
					SUBSTRING(@JSON, (S.[Start_12] + S.[Length_12]), CHARINDEX('"', @JSON, S.[Start_12] + S.[Length_12]) - (S.[Start_12] + S.[Length_12])
					) )
					END AS [Credit_UnitAmt_3],

		
				CASE S.[Start_13] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_13] + S.[Length_13]), CHARINDEX('"', @JSON, S.[Start_13] + S.[Length_13]) - (S.[Start_13] + S.[Length_13])
					) 
					END AS [provider],

		
				CASE S.[Start_14] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_14] + S.[Length_14]), CHARINDEX('"', @JSON, S.[Start_14] + S.[Length_14]) - (S.[Start_14] + S.[Length_14])
					) 
					END AS [SponsorID],

		
				CASE S.[Start_15] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_15] + S.[Length_15]), CHARINDEX(']', @JSON, S.[Start_15] + S.[Length_15]) - (S.[Start_15] + S.[Length_15])
					) 
					END AS [Jurisdiction],

		
				CASE S.[Start_16] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_16] + S.[Length_16]), CHARINDEX('"', @JSON, S.[Start_16] + S.[Length_16]) - (S.[Start_16] + S.[Length_16])
					) 
					END AS [NASBAQuestionID_1],

				
				CASE S.[Start_17] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_17] + S.[Length_17]), CHARINDEX('"', @JSON, S.[Start_17] + S.[Length_17]) - (S.[Start_17] + S.[Length_17])
					) 
					END AS [NASBAValue_1],

				
				CASE S.[Start_18] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_18] + S.[Length_18]), CHARINDEX('"', @JSON, S.[Start_18] + S.[Length_18]) - (S.[Start_18] + S.[Length_18])
					) 
					END AS [NASBAQuestionID_2],

				
				CASE S.[Start_19] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_19] + S.[Length_19]), CHARINDEX('"', @JSON, S.[Start_19] + S.[Length_19]) - (S.[Start_19] + S.[Length_19])
					) 
					END AS [NASBAValue_2],
		
				CASE S.[Start_20] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_20] + S.[Length_20]), CHARINDEX('"', @JSON, S.[Start_20] + S.[Length_20]) - (S.[Start_20] + S.[Length_20])
					) 
					END AS [RequestType],

		
				CASE S.[Start_21] 
					WHEN 0 THEN NULL
					ELSE
					SUBSTRING(@JSON, (S.[Start_21] + S.[Length_21]), CHARINDEX('"', @JSON, S.[Start_21] + S.[Length_21]) - (S.[Start_21] + S.[Length_21])
					) 
					END AS [DefinitionStatus]

		FROM StringSearch S


	END TRY

	BEGIN CATCH

		THROW 51000, 'The Json could not be parsed', 16;

	END CATCH

END
