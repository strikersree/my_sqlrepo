##Created By: Srinivas Kannan
##Set up a twitter developer account to fetch data from API

USE ROLE Accountadmin;

USE DATABASE TWITTER_ANALYTICS;

--Create Azure Stage
CREATE or REPLACE stage azure_blob
  url='azure://genpurposedisk.blob.core.windows.net/blobcontainer/'
  credentials=(azure_sas_token='?sv=2019-12-12&ss=bfqt&srt=sco&sp=rwdlacupx&se=2020-12-30T21:59:06Z&st=2020-08-09T13:59:06Z&spr=https&sig=M5LuWKhrHo4bI%2FxUe2St7CLzZ3%2FKXa3tlp%2B6t6%2B1%2Fzo%3D')
  file_format = TWEETS_JSON; 


--Create Staging Table in Snowflake
CREATE OR REPLACE TABLE "Staging_Tweets_Json"
(
  "TRENDS_RAW" VARIANT
);


--Create Target Table in Snowflake
CREATE OR REPLACE TABLE "TWITTER_ANALYTICS"."PUBLIC"."Trending_Tweets"
( 
  Hashtag string,
  Tweet_Count number, 
  CREATEDAT string
);


--Task 1
CREATE OR REPLACE TASK truncate_stage
warehouse = COMPUTE_WH
SCHEDULE = '7 minutes'
AS
TRUNCATE TABLE "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets_Json";

--Task 2
CREATE OR REPLACE TASK fetch_raw
warehouse = COMPUTE_WH
SCHEDULE = '5 minutes'
AS

COPY INTO "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets_Json"
FROM @azure_blob
PATTERN = 'Twitter.*json';


--Task 3
CREATE OR REPLACE TASK raw_to_table
warehouse = COMPUTE_WH
SCHEDULE = '10 minutes'
AS

MERGE INTO "TWITTER_ANALYTICS"."PUBLIC"."Trending_Tweets" T
USING
(
  SELECT 
m.value:name::STRING HashTag
,m.value:tweet_volume::NUMBER Tweet_Count
,TRENDS_RAW:created_at::STRING CREATEDAT
FROM "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets_Json"
,LATERAL FLATTEN(input => TRENDS_RAW:trends) m 
WHERE m.value:tweet_volume::STRING IS NOT NULL
ORDER BY 2 DESC
) S

ON T.HashTag = S.HashTag

WHEN MATCHED THEN UPDATE SET T.Tweet_Count = S.Tweet_Count, T.Createdat = S.Createdat

WHEN NOT MATCHED THEN INSERT (Hashtag, Tweet_Count, Createdat) VALUES (S.HashTag, S.Tweet_Count, S.Createdat)

;


SHOW TASKS

SELECT * FROM "TWITTER_ANALYTICS"."PUBLIC"."Trending_Tweets"
ORDER BY 2 DESC





ALTER TASK FETCH_RAW RESUME;

ALTER TASK RAW_TO_TABLE RESUME;

ALTER TASK TRUNCATE_STAGE RESUME;

