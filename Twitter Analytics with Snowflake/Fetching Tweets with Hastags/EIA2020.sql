USE ROLE Accountadmin;

USE DATABASE TWITTER_ANALYTICS;

TRUNCATE TABLE "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets2_Json";

COPY INTO "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets2_Json"
FROM @azure_blob
PATTERN = 'EIA2020.*json';


MERGE INTO "TWITTER_ANALYTICS"."PUBLIC"."RELATED_TWEETS" AS T

USING 
(
   SELECT distinct 
m.value:text::STRING Tweet
--,m.value:retweet_count::NUMBER ReTweets
,m.value:favorite_count::NUMBER Likes
,m.value:name::STRING Name
,m.value:created_at::DATE CREATEDAT
FROM "TWITTER_ANALYTICS"."PUBLIC"."Staging_Tweets2_Json"
,LATERAL FLATTEN(input => TRENDS_RAW:statuses) m 
) AS S

ON S.Tweet = T."Tweet"

WHEN NOT MATCHED THEN INSERT ("Tweet", "Likes", "Name", "CREATEDAT") VALUES (S.Tweet, S.Likes, S.Name, S.CREATEDAT);



SELECT COUNT(*) FROM "TWITTER_ANALYTICS"."PUBLIC"."RELATED_TWEETS";