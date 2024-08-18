-------------------------------------
-- Generating Database: TEST
-------------------------------------
CREATE TRANSIENT SCHEMA IF NOT EXISTS schema1 DATA_RETENTION_TIME_IN_DAYS=0;
USE SCHEMA schema1;
CREATE or REPLACE TABLE testdf
AS
SELECT
   dateadd(day, uniform(1, 1234, random(10002)), date_trunc(day, current_date))::date as column1,
   (date_part(epoch_second, current_date) + (uniform(1, 1234, random(10003))))::timestamp as column2,
   randstr(uniform(1,10, random(10004)),uniform(1,1234,random(10004)))::varchar(10) as column3,
   rpad(uniform(1, 1234, random(10005))::varchar,10, 'abcdefghifklmnopqrstuvwxyz')::char(10) as column4
from table(generator(rowcount => 10000));
 
