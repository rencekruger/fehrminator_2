-------------------------------------
-- Generating Database: TEST
-------------------------------------
CREATE TRANSIENT SCHEMA IF NOT EXISTS schema1 DATA_RETENTION_TIME_IN_DAYS=0;
USE SCHEMA schema1;
CREATE or REPLACE TABLE testdf
AS
SELECT
   randstr(uniform(10,50, random(10002)),uniform(1,1234,random(10002)))::varchar(50) as column41
from table(generator(rowcount => 1000099));
 
