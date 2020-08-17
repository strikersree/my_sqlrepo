#!/bin/bash
##created_by: Srinivas Kannan
##created_by: Srinivas Kannan
##Pre-requsites: 1. Snowflake Account 2. External Stage set up inside snowflake. 3. Snowsql installed on your computer.
echo "Setting directory"
cd /
cd mnt/e/Snowflake
echo "starting Snowflake"
snowsql -c myconn -f trendupdate.sql
exit 0