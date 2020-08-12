#!/bin/bash
##created_by: Srinivas Kannan
##Pre-requsites: 1. Azure account with Container 2.Twitter Developer Account and App tokens generated
echo "Setting directory"
cd /
cd mnt/e
echo "Fetching trends from Twitter API............."
curl --location --request GET 'https://api.twitter.com/1.1/trends/place.json?id=23424848' --header 'Authorization: Bearer AAAAAAAAAAAAAAAAAAAAAEtDGgEAAAAAFkIDkArBU31EF%2BJobDP6L0PWb8A%3DvS1odaZExoEskcaBtb1teYXKPln0OhJw4Ax56jmlVtJurchxzm' --header 'Cookie: personalization_id="v1_tABgBBlLkxhJQmMkekTAqg=="; guest_id=v1%3A159654998151629260' | python -mjson.tool > twitter.json
echo "Fetch Complete......."
echo "Uploading trends to blob...................."
az storage blob upload -f /mnt/e/Twitter.json --account-name genpurposedisk  -c blobcontainer -n Twitter.json
echo "Blob Upload complete....."
echo "Processing to Snowflake from Azure..."
bash Update_Snowflake_1.sh
exit 0
# cd Snowflake
# snowsql -a kt29897.east-us-2.azure -u strikersree
# Azure@2020

#  snowsql -a kt29897.east-us-2.azure -u strikersree -f trendupdate.sql



