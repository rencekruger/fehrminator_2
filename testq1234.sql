-------------------------------------
-- Generating Database: TEST
-------------------------------------
CREATE TRANSIENT SCHEMA IF NOT EXISTS schema1 DATA_RETENTION_TIME_IN_DAYS=0;
USE SCHEMA schema1;
CREATE or REPLACE TABLE testdf
AS
SELECT
   randstr(uniform(10,50, random(10002)),uniform(1,1234,random(10002)))::varchar(50) as column41,
   dateadd(day, uniform(1, 365, random(10003)), date_trunc(day, current_date))::date as column11,
   (date_part(epoch_second, current_date) + (uniform(1, 1234, random(10004))))::timestamp as column21,
   randstr(uniform(1,10, random(10005)),uniform(1,1234,random(10005)))::varchar(10) as column31,
   rpad(uniform(1, 1234, random(10006))::varchar,10, 'abcdefghifklmnopqrstuvwxyz')::char(10) as column41
from table(generator(rowcount => 1000099));
 
CREATE or REPLACE TABLE testt1
AS
SELECT
   rpad(uniform(1, 1234, random(10007))::varchar,10, 'abcdefghifklmnopqrstuvwxyz')::char(10) as column1,
   rpad(uniform(1, 1234, random(10008))::varchar,10, 'abcdefghifklmnopqrstuvwxyz')::char(10) as column2,
   uniform(1,1234 , random(10009))::bigint as column3,
   uniform(1,1234 , random(10010))::integer as column4,
   randstr(uniform(16,128, random(10011)),uniform(1,1234,random(10011)))::varchar(128) as column5
from table(generator(rowcount => 1000099));
 
