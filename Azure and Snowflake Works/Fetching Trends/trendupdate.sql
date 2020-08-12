USE ROLE Accountadmin;

USE DATABASE TWITTER_ANALYTICS;

TRUNCATE TABLE "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets_Json";


COPY INTO "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets_Json"
FROM @azure_blob
PATTERN = 'Twitter.*json';

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


WHEN NOT MATCHED THEN INSERT (Hashtag, Tweet_Count, Createdat) VALUES (S.HashTag, S.Tweet_Count, S.Createdat)

WHEN MATCHED AND T.CREATEDAT < convert_timezone('Asia/Tokyo', current_date()) THEN DELETE 

WHEN MATCHED THEN UPDATE SET T.Tweet_Count = S.Tweet_Count, T.Createdat = S.Createdat;


SELECT * FROM "TWITTER_ANALYTICS"."PUBLIC"."Trending_Tweets"
ORDER BY 2 DESC;