#!/bin/bash
##created_by: Srinivas Kannan
##Pre-requsites: 1. Snowflake Account 2. External Stage set up inside snowflake. 3. Snowsql installed on your computer. 4. Passwordless authentication for accessing SnowSQL through CLI
echo "Setting directory"
cd /
cd mnt/e/Snowflake
echo "starting Snowflake"
snowsql -c myconn -f EIA2020.sql
exit 0