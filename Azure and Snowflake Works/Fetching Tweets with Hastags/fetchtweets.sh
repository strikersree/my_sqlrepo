#!/bin/bash
##created_by: Srinivas Kannan
##Pre-requsites: 1. Azure account with Container 2.Twitter Developer Account and App tokens generated
now=$(date +%m_%d_%y_%H_%M)
echo "Setting directory"
cd /
cd mnt/e/eiadata
echo "Fetching trends from Twitter API............."
curl --location --request GET 'https://api.twitter.com/1.1/search/tweets.json?q=EIA2020' --header 'Authorization: Bearer AAAAAAAAAAAAAAAAAAAAAEtDGgEAAAAAFkIDkArBU31EF%2BJobDP6L0PWb8A%3DvS1odaZExoEskcaBtb1teYXKPln0OhJw4Ax56jmlVtJurchxzm' --header 'Cookie: personalization_id="v1_tABgBBlLkxhJQmMkekTAqg=="; guest_id=v1%3A159654998151629260' | python -mjson.tool > EIA2020_${now}.json 
echo "Fetch Complete......."
echo "Uploading Tweets to blob...................."
# az storage blob upload -f /mnt/e/eiadata.json --account-name genpurposedisk  -c blobcontainer  -n EIA2020.json
az storage blob upload-batch -d blobcontainer -s /mnt/e/eiadata  --account-name genpurposedisk 
echo "Upload complete....."
echo "Proceeding to Snowflake..."
exit 0


