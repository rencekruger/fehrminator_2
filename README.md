# Fehrminator


Fehrminator is a data generation framework to generate random data sets based on a given schema at scale. It was mainly developed to compare performance for a target environment, for instance a new Snowflake DW, against an existing DW environment, while a real world production dataset can not be used.

The idea is to generate a dataset that looks very similar in terms for naming and schema, datasize (i.e. number or rows), and number of rows by column. By taking these values as input parameters, the framework generates a SQL script to generate a randomized dataset of similar size and similar distribution.

One word of caution. Be sure to check the length of VARCHAR columns (and review the documentation below). Generating data for long VARCHAR columns can be time consuming and costly. If you have a spec with several long varchar columns, consider using the max of the actual length of the values in those columns rather than the maximum length defined in the data dictionary.


## Specification

The framework takes the following input schema

1. Schema name
1. Table name
1. Column name
1. Column cardinality (number of distinct values in column)
1. Table cardinality (number of rows in table)
1. Data type
1. Data length
1. Data precision

The Framework supports the following datatypes

1. DATE
1. TIMESTAMP
1. CHAR (LENGTH)
1. VARCHAR (LENGTH)
1. INTEGER
1. BIGINT
1. FLOAT
1. DOUBLE
1. NUMBER (LENGTH, PRECISION)

Please Note:
 * The customer usually can create the required input schema easily by running a meta data query against their existing system. If this is green field development, then take the best guess based on customer requirements.
 * The framework does not generate a database. It expects the database to exist. 
 * The framework generates code to create a schema in case it doesn't exist. Drop the schema manually, if you want to start over completely.
 * The framework generates code to override tables if they exist, i.e. the script can be re-executed against an existing test database.
 * The framework generates code to create TRANSIENT tables to cut down on cost.
 * The number of distinct values per column in the generated table is not an exact value. 
  Example: If a table has 100 rows and a column is defined as having 100 distinct values, then there is a chance that the number if distinct values is slightly below the specified value.
 * The framework primarily relies on numbers that will be randomly generated between a **min** and a **max** value. The distribution is uniform (please see below for the special case of normal distribution), i.e. for a specific column within the a specific tables we have approx. the same number of rows per column values. Example: If a table has 100 rows and a column has 10 distict values, then each vaule has appox. 10 rows (some will have 11 rows, some will have 9 rows).
 * CHAR/VARCHAR will be generated with a specific length from a repeated pattern. Uniqueness is achived by pre-fixing the string with a number. Truly random strings could be used as well but generating random strings using the Snowflake RANDSTR SQL function take consideraly longer time.
 * DATE columns will be generated by adding a random number (as days) to current date.
 * TIMESTAMP columns will be generated by adding a random number (as seconds) to midnight of the current date. In case finer granuality is required, the generated code could be manually modified to divide the added value by i.e. 1000 (milliseconds), 1000000 (microseconds), and so on.
 * Real world customer schemas usually contain multiple tables with primary/foreign key relationships. Simple cases with only single column keys (natural or surrogate keys) are completely covered within the framework, as long as data types between primary/foreign key match and as long as the number of distinct values for the primary key is at least as big as the number of distinct values for the column referencing the primary key. 
 * Requesting Primary/Foreign key meta information is a good practive to validate data type consistentcy, but it's not a requirement for the tool.
 * Creating large CHAR/VARCHAR columns (1k+) can consume a considerable amount of time and space. Review these instances with the customer and consider to limit the size. To be clear, Snowflake can handle bigger sizes but it can be very costly to generate the data.
 * Creating a big dataset, e.g. 100 billion rows, can take a considerable amount of time and should be executed on a sufficiently big cluster. However, smaller dataset, e.g. 1 million rows do not benefit from using a large cluster. Rule of Thumb: Start with an XL or smaller for 1 billion rows and below. If you need to create bigger sets, snowflake scales almost linearly from this point forward, i.e. scaling up one level cuts the time to generate the data by half.
 * When creating a large dataset which consumes a considerable amount of credits, start with a scaled down version of the spec, e.g. 1 million rows (or whatever makes sense) and review the output with the customer in terms of dats distribution and joins. Also record the time it took to create the dataset as well as the size to extrapolate total time and size.   
 * Uniqueness for a column can be achieved by setting the column cardinality for that column to match the table cardinality. Only BIGINT/CHAR/VARCHAR are supported for unique columns. Uniqueness is garuanteed via function seq8().
  
Using the input schema, the framework generates an SQL script to generate data in Snowflake. The SQL script can be generated using the Excel workwork or the python Script.

## Excel Code Generation

1. Request the schema information from the customer
1. Cleanse the schema information, in particular check the data types
1. Copy the customer data onto the formula worksheet
1. Save the worksheet as txt format
1. Run the following command to generate the SQL Script (the awk script assemble.awk is part of this repo)

cat name.txt | sed "s/\\"//g" | sed "s/|/\\"/g" | awk -F"\t" -f assemble.awk

## Python Code Generation

1. Request the schema information from the customer
1. Cleanse the schema information, in particular check the data types
1. Save the worksheet as csv format
1. Run the following command to generate the SQL Script

python snowflake_python_generator.py name.csv

## Advanced Use-Cases

The are 2 additional datapoints that can be requested from the customer to cover special cases in term of data distribution.
1. Number of null values per column
2. Data distribution (uniform vs. normal)

 * Uniform data distribution can be selected ( 1 in column `Normal Dist` ) for data types BIGINT, VARCHAR, CHAR. Please note that the value for column cardinality will be slightly higher, i.e. is not the exactly the value requested. 

Please note:
 * In case of large dataset and sparse distribution of large string columns, it's very benefical to request the number of null values per column. When reviewing the spec, the number of null values divided by table cardinality should be a reasonable percentage valye, i.e. number between 1 and 100. The framework will generate code that will randomly choose to generate a value or null based on the specified distribution.
 * NOT YET IMPLEMENTED IN PYTHON: In some cases the default data distribution, i.e. uniform, does not meet requirements and customers are looking for a more normal (i.e. bell curve) distribution of FACTS for a specific DIMENSION.  Normal distribution only makes sense for fact tables though the framework doesn't limit the usage to fact tables. If a normal distribution is being specified (Distribution=1), then the framework generates code to use a different distribution function.
 

